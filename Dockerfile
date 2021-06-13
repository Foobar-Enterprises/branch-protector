FROM python:alpine

COPY branch_protector.py   ./
EXPOSE 8080
RUN pip install requests
ENTRYPOINT ["python3", "./branch_protector.py"]
