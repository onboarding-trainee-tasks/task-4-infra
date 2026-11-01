# Onboarding Task 4 — Protected Website with Keycloak and OAuth2 Proxy

This repository provisions AWS infrastructure for a protected Nginx website. Ansible configures Keycloak, OAuth2 Proxy and Nginx; Packer builds the supporting AMIs in `task-4-packer`.

## Architecture

- Ansible controller EC2 in a public subnet; web server EC2 at `10.10.1.111`.
- Public ALB with HTTP → HTTPS redirect and ACM certificate; target group health check at `/health`.
- Route 53 aliases for `app.coinops-d.pp.ua`, `auth.coinops-d.pp.ua` and `github-app.coinops-d.pp.ua`.
- Nginx routes traffic to Keycloak (`127.0.0.1:8080`) and two OAuth2 Proxy services (`127.0.0.1:4180`, `127.0.0.1:4181`).
- Keycloak realm imports test users/roles and GitHub/GitLab identity providers. Sensitive values are retrieved by Ansible from SSM Parameter Store.
- The controller accesses the web server through SSH on the private IP; `ansible_sg` and `web_ssh_sg` restrict incoming SSH access.

## External prerequisites

- AWS credentials for `eu-central-1` and an existing S3 Terraform backend: bucket `tf-backend-task-4`, key `infra/state-t4`.
- Existing Route 53 public hosted zone `coinops-d.pp.ua.` and an issued ACM certificate that matches the configured domains.
- Two EC2 Key Pairs and corresponding **local private keys**: `t4-controller` (workstation → controller) and `t4-web-internal` (controller → web server). The public keys must already be imported into EC2 in `eu-central-1`. Do not commit private keys.
- Ansible controller AMI ID in `packer_ansible_ami` and, after the Packer migration, a Web Server AMI ID in `packer_web_server_ami`.
- SSM `SecureString` parameters read by the Ansible controller role: `/task4/keycloak/admin-password`, `/task4/keycloak/test-user-password`, `/task4/keycloak/oauth2-proxy-client-secret`, `/task4/oauth2/cookie-secret`, `/task4/oauth2/github-client-secret`, `/task4/oauth2/gitlab-client-secret`, `/task4/oauth2/github-second-client-secret`, `/task4/oauth2/github-second-cookie-secret`.

## Start infrastructure

Until all PRs are merged, use the tested `onb-4-infra` branch, which includes the SSM permission for the test-user password. After merging, use `main`.

```bash
git switch onb-4-infra
terraform init
terraform fmt -check -recursive
terraform validate
terraform apply
```

Review replacements and the actual S3 state before applying; avoid running another task with conflicting AWS resource names at the same time. Terraform might replace EC2 instance when changing its AMI.

## Run Ansible (on Ansible controller)

```bash
cd /home/ubuntu/task-4-ansible
ansible-galaxy collection install -r requirements.yml
ssh -i ~/.ssh/ansible_ssh_private_key ubuntu@10.10.1.111 'hostname'
ansible -i inventory.ini web_server -m ansible.builtin.ping
ansible-playbook -i inventory.ini playbook.yml --syntax-check
ansible-playbook -i inventory.ini playbook.yml
```

Until Ansible is merged, the EC2 user-data bootstrap checks out `onb-4-ansible`. After its PR is merged, update the bootstrap to use `main` before merging the infrastructure PR. Preserve the Ansible `PLAY RECAP` for review.

## Verify runtime

Validate HTTPS and authentication. Use the browser to verify authorized vs unauthorized Keycloak users, GitHub/GitLab identity-provider logins and the separate direct GitHub OAuth2 flow. HTTP should redirect to HTTPS; unauthenticated requests should redirect to login. Test with fresh sessions to avoid stale OAuth cookies.