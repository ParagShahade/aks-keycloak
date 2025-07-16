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

## AKS CoreDNS Custom DNS Limitation and Workaround

### Issue
Azure AKS managed clusters do not allow persistent manual edits to the CoreDNS ConfigMap. Any custom DNS entries (such as for `keycloak.web.com` or `auth.web.com`) are automatically reverted by the AKS addon manager. The Azure-supported custom CoreDNS profile feature is not yet generally available in all regions and may not be available in your environment.

### Attempted Solutions
- Manual edits to the CoreDNS ConfigMap (using `hosts` blocks or `import custom.hosts`) are overwritten by AKS.
- Mounting custom ConfigMaps and patching the CoreDNS deployment does not persist.
- Azure CLI-based custom CoreDNS profiles are not available in all clusters/regions.

### Current Workaround
- **OIDC issuer URL in OAuth2 Proxy is set to the hardcoded Keycloak service ClusterIP** (e.g., `http://10.0.6.199:8080/realms/master`).
- This allows in-cluster OIDC communication without relying on custom DNS.
- **Caveat:** This is not OIDC spec-compliant and is only recommended as a last-resort workaround for dev/test. Browsers and external clients must still use the public DNS (`keycloak.web.com`) for redirects.

### Recommendation
- Monitor Azure AKS release notes for the general availability of persistent custom CoreDNS profiles.
- For production, use Ingress or a public DNS name for all OIDC endpoints if possible.

> **Note:**
> The files `kube/coredns-custom.yaml`, `kube/coredns-patch.yaml`, and `kube/coredns-custom-combined.yaml` are **deprecated and not in use** due to AKS CoreDNS limitations. Manual or automated changes to CoreDNS are reverted by the AKS addon manager. See the section above for details and the current workaround.
