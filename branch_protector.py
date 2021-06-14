from hmac import compare_digest
from http.server import BaseHTTPRequestHandler, HTTPServer
import hashlib
import hmac
import json
import os
import requests

# Why not just pass environment variables when the container is run? Because
# they're visible outside the container. They become part of the description of
# the container, and this may not be treated as sensitive data.
def getSecrets():
  try:
    with open('/run/secrets/github.json', 'r') as f:
      secrets = json.load(f)
      os.environ['GITHUB_USERNAME'] = secrets['username']
      os.environ['GITHUB_PERSONAL_ACCESS_TOKEN'] = secrets['personal_access_token']
      os.environ['GITHUB_WEBHOOK_SECRET'] = secrets['webhook_secret']
  except Exception as e:
    raise(e)

def protectRepo(request):
  main_branch = 'main'
  repo = request.get('repository', {})
  repo_name = repo.get('full_name', 'DEFAULT')
  headers = {'Accept': 'application/vnd.github.v3+json', 'Content-Type': 'application/json'}
  #TODO: This URL should be configurable
  url = f'https://api.github.com/repos/{repo_name}/branches/{main_branch}/protection'
  data = {
    "required_status_checks": {
      "strict": True,
      "contexts": []
    },
    "enforce_admins": True,
    "required_pull_request_reviews": {
      "dismiss_stale_reviews": True
    },
    "restrictions": None
  }
  response = requests.put(url, data=json.dumps(data), auth=(os.environ['GITHUB_USERNAME'], os.environ['GITHUB_PERSONAL_ACCESS_TOKEN']))
  if response.status_code != 200:
    raise Exception(f'Failed to request branch protection for {repo_name}, branch {main_branch}. Code {response.status_code}, response: {response.text}')

  url = f'https://api.github.com/repos/{repo_name}/issues'
  data = {
    'title': 'Your main branch has been protected.',
    'body': 'The main branch of this project has been protected. You must commit your changes to another branch, submit a pull request, and receive an approval in order to modify it.\n\n@jodawill'
  }
  response = requests.post(url, data=json.dumps(data), auth=(os.environ['GITHUB_USERNAME'], os.environ['GITHUB_PERSONAL_ACCESS_TOKEN']))
  if response.status_code != 201:
    raise Exception(f'Failed to submit issue. Code {response.status_code}, response: {response.text}')

def checkSignature(signature, body):
  secret = os.environ['GITHUB_WEBHOOK_SECRET']
  calculated_signature = 'sha256=' + hmac.new(bytes(secret, 'utf-8'), bytes(body, 'utf-8'), hashlib.sha256).hexdigest()
  return compare_digest(signature, calculated_signature)

def doWebhook(request_handler):
  content_length = int(request_handler.headers['Content-Length'] or 0)
  body = request_handler.rfile.read(content_length).decode('utf-8')

  if not checkSignature(request_handler.headers.get('X-Hub-Signature-256', ''), body):
    request_handler.send_response(403)
    request_handler.send_header('Content-Type', 'application/json')
    request_handler.end_headers()
    request_handler.wfile.write(bytes('{"error": "unauthorized"}', 'utf-8'))
    return

  request = json.loads(body)
  if request.get('action', '') == 'created':
    request_handler.send_response(200)
    request_handler.send_header('Content-Type', 'application/json')
    request_handler.end_headers()
    protectRepo(request)
    request_handler.wfile.write(bytes('{"message": "protected branch"}', 'utf-8'))
  else:
    request_handler.send_response(200)
    request_handler.send_header('Content-Type', 'application/json')
    request_handler.end_headers()
    request_handler.wfile.write(bytes('{"message": "no action taken"}', 'utf-8'))

def do404(request_handler):
  request_handler.send_response(404)
  request_handler.send_header('Content-Type', 'text/html')
  request_handler.end_headers()
  request_handler.wfile.write(bytes('not found', 'utf-8'))

def doHealthcheck(request_handler):
  request_handler.send_response(200)
  request_handler.send_header('Content-Type', 'application/json')
  request_handler.end_headers()
  request_handler.wfile.write(bytes('{"success":true}', 'utf-8'))

class server(BaseHTTPRequestHandler):
  def do_POST(self):
    if self.path == '/webhook':
      doWebhook(self)
    else:
      do404(self)

  def do_GET(self):
    if self.path == '/health':
      doHealthcheck(self)
    else:
      do404(self)

if __name__ == '__main__':
  getSecrets()
  hostname = '0.0.0.0'
  port = 8080
  webServer = HTTPServer((hostname, port), server)
  print(f'Server started http://{hostname}:{port}')

  try:
    webServer.serve_forever()
  except KeyboardInterrupt:
    pass

  webServer.server_close()
