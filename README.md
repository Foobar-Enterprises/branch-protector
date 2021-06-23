# Branch Protector
This webapp will place branch protections on the main branch of all new repositories created within your GitHub organization.

# Getting Started
For your convenience, this application has been bundled into a Docker image. The container listens on port 8080. It is not recommended that you pass secrets to a container as environment variables. Instead, the application looks for the secret values in a file named `/run/secrets/github.json`. If you use the provided Terraform script, this JSON snippet should be provided via the `github_secret` variable. The format of the file is as follows:

```
{"personal_access_token":"...","username":"...","webhook_secret":"..."}
```

Click [here](https://docs.github.com/en/developers/webhooks-and-events/webhooks/securing-your-webhooks) for more information about GitHub webhook secrets and [here](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) for help creating a personal access token.

## Terraform
To provide a quick demonstration, I've provided a Terraform script that will deploy the application through an autoscale group behind an application load balancer. This script will create all the resources for you, except it currently assumes you already have a VPC with an internet gateway attached. To spin up your own copy, simply browser to the `./terraform` directory and type `terraform apply`. It will prompt you for a few variables, including, including:

* VPC ID
* AWS region
* Your public SSH key
* Subnets to place your EC2 instances in
* GitHub secrets in JSON format
* AWS access key
* AWS secret key
* Autoscale minimum number of instances
* Autoscale maximum number of instances
* Autoscale desired number of instances

For high availability, the minimum number of instances should be at least two.

When you apply the script, the output will present the webhook URL based on the ALB's DNS.

## Configuring the Webhook
Browse to the following URL, substituting your own organization's name:

```
https://github.com/organizations/${ORGANIZATION}/settings/hooks
```

Click "Add a Webhook." The payload URL is `http://${HOST}:8080/webhook`. If you used the Terraform script, it will be in the output when you run `terraform apply`. For the content type, choose `application/json`. Paste in the secret value you provided to the container. This will be used for HMAC verification. When choosing what events to send, choose "Repositories."

To test it out, create a new repository under your organization. (If you're under a free plan, be sure to make it public.) Almost immediately, the main branch will be protected, and an issue will be filed explaining the protections that were put into place.

# Security Considerations
Disclaimer: All of the scripts included in this repository are meant for demonstrative purposes only and should not be used in a production environment.

## SSH
The provided Terraform script will create a security group that allows SSH connections only from the IP address you deployed from. It will also use the SSH key you provide during the `terraform apply`.

## TLS
The provided Terraform script isn't yet configured to enable TLS. I may add this in the future, but this Terraform script is only meant to serve as an example so you can quickly spin up a copy of this application with nothing but a vanilla AWS account. The provided Dockerfile doesn't enable TLS either.

## Verifying Requests
This application uses HMAC signatures to verify incoming requests using the provided GitHub secret. If you use the provided Terraform script, it will also restrict incoming requests to GitHub's IP ranges, `192.30.252.0/22` and `140.82.112.0/20` (as well as the IP you deployed from).

## Host Header Poisoning
For simplicity, this application responds to requests for any host. This is safe because we never make use of the host header.

# Caveats
* Free tier accounts don't support branch protection for private repositories.
* The provided Terraform script isn't yet configured to enable TLS.
* The Terraform script currently assumes you already have a VPC with an internet gateway attached.
* Both the webapp and the Terraform script currently assume you're using github.com, not a self hosted installation.
