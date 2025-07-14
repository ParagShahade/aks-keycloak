# AKS Keycloak Deployment

This project deploys a secure authentication system on Azure Kubernetes Service (AKS) using Keycloak, OAuth2 Proxy, PostgreSQL, and a static web app. All infrastructure is managed with Terraform, configuration is automated with Ansible, and CI/CD is handled by GitHub Actions.

---

**Components:**
- **Keycloak:** Open-source identity and access management (IAM)
- **PostgreSQL:** Database for Keycloak
- **OAuth2 Proxy:** Secures the web app using OIDC with Keycloak
- **NGINX Ingress Controller:** Routes and load-balances traffic
- **Static Web App:** Example app protected by OIDC
- **Terraform:** Provisions all Azure infrastructure
- **Ansible:** Automates Kubernetes resource deployment
- **GitHub Actions:** CI/CD for rollout, configuration, and teardown
---

## CI/CD Workflows

- **Rollout:** Provisions infrastructure (Terraform) and deploys apps (Ansible).
- **Configure:** Updates app configs, secrets, or rolling updates (Ansible).
- **Disassemble:** Destroys all infrastructure (`terraform destroy`).

Workflows are triggered via GitHub Actions (`.github/workflows/`).

---

## Deployment

### 1. Provision Infrastructure

```bash
cd aks-cluster
terraform init
terraform apply
```

### 2. Deploy Applications

GitHub Actions will automatically deploy on push.
Manual deployment (if needed):

```bash
ansible-playbook ansible/playbooks/deploy_namespace.yaml
ansible-playbook ansible/playbooks/deploy_postgres.yaml
ansible-playbook ansible/playbooks/deploy_keycloak.yaml
ansible-playbook ansible/playbooks/deploy_web.yaml
ansible-playbook ansible/playbooks/deploy_configmap.yaml
ansible-playbook ansible/playbooks/deploy_rbac.yaml
ansible-playbook ansible/playbooks/deploy_sa.yaml
ansible-playbook ansible/playbooks/deploy_ingress.yaml
ansible-playbook ansible/playbooks/deploy_oauth.yaml
```

---

## Access

- **Keycloak Admin Console:** `http://<keycloak-service-ip>:8080`
- **Secured Web App:** `http://auth.web.com`

> **Note:** This deployment uses HTTP only. For production, it is strongly recommended to enable TLS/HTTPS using cert-manager or another certificate management solution.

> **DNS/Hosts Note:**
> For local testing, you must add an entry to your `/etc/hosts` file mapping the AKS LoadBalancer IP to `auth.web.com` (e.g., `123.45.67.89 auth.web.com`).
> Alternatively, use a real DNS record

---

## Cleanup / Disassemble

To destroy all infrastructure and clean up resources:

```bash
cd aks-cluster
terraform destroy
```
Or trigger the **Disassemble** workflow in GitHub Actions.

---

## Security Notes

- Use proper secret management (Azure Key Vault, HashiCorp Vault) for production.
- Implement RBAC, monitoring, and backup strategies.
- **TLS/HTTPS is not enabled by default. For production, always secure endpoints with HTTPS.**

---

## Troubleshooting

- Check pod status: `kubectl get pods -A`
- View logs: `kubectl logs <pod> -n <namespace>`
- Check services: `kubectl get svc -A`
- Verify secrets: `kubectl get secrets -A`
