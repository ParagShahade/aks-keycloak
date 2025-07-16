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

```bash
ansible-playbook ansible/playbooks/deploy_namespace.yaml
ansible-playbook ansible/playbooks/deploy_secrets.yaml
ansible-playbook ansible/playbooks/deploy_pvc.yaml
ansible-playbook ansible/playbooks/deploy_postgres.yaml
ansible-playbook ansible/playbooks/deploy_keycloak.yaml
ansible-playbook ansible/playbooks/deploy_web.yaml
ansible-playbook ansible/playbooks/deploy_configmap.yaml
ansible-playbook ansible/playbooks/deploy_rbac.yaml
ansible-playbook ansible/playbooks/deploy_sa.yaml
ansible-playbook ansible/playbooks/deploy_coredns.yaml
ansible-playbook ansible/playbooks/deploy_keycloak-ingress.yaml
ansible-playbook ansible/playbooks/deploy_ingress.yaml
nsible-playbook ansible/playbooks/deploy_oauth.yaml
```

---

## Access

- **Keycloak Admin Console:** `http://keycloak.web.com`
- **Secured Web App:** `http://auth.web.com`

> **Note:** This deployment uses HTTP only. For production, it is strongly recommended to enable TLS/HTTPS using cert-manager or another certificate management solution.

> **DNS/Hosts Note:**
> For local development and testing, you must add entries to your `/etc/hosts` file mapping the AKS LoadBalancer IP to **both** `auth.web.com` and `keycloak.web.com`:
> 
>     123.45.67.89 auth.web.com keycloak.web.com
> 
> This ensures that both the OAuth2 Proxy and your browser can resolve the correct endpoints for OIDC login and callback. Alternatively, use real DNS records for both hostnames in production or shared environments.

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
Azure AKS managed clusters do not allow persistent manual edits to the CoreDNS ConfigMap. Any custom DNS entries (such as for `keycloak.web.com` or `auth.web.com`) are automatically reverted by the AKS addon manager. The Azure-supported custom CoreDNS profile feature is not yet generally available in all regions and may not be available in environment.

### Attempted Solutions
- Manual edits to the CoreDNS ConfigMap (using `hosts` blocks or `import custom.hosts`) are overwritten by AKS.
- Mounting custom ConfigMaps and patching the CoreDNS deployment does not persist.
- Azure CLI-based custom CoreDNS profiles are not available in all clusters/regions.

### Recommendation
- Monitor Azure AKS release notes for the general availability of persistent custom CoreDNS profiles.
- For production, use Ingress or a public DNS name for all OIDC endpoints if possible.

> **Note:**
> The files `kube/coredns-custom.yaml`, `kube/coredns-patch.yaml`, and `kube/coredns-custom-combined.yaml` are **deprecated and not in use** due to AKS CoreDNS limitations. Manual or automated changes to CoreDNS are reverted by the AKS addon manager.

## OIDC, Keycloak, and OAuth2 Proxy: Final Working Solution

### Final Solution Summary
- Keycloak is configured with the `email` client scope assigned as Default to the OIDC client (`test-web-app`).
- The user has a valid email and `Email verified` set to ON.
- The `email` and `email_verified` mappers are present in the `email` client scope and set to add claims to the ID token.
- OAuth2 Proxy is configured with:
  - `--oidc-issuer-url` matching the Keycloak realm URL (e.g., `http://keycloak.web.com/realms/master`)
  - `--scope=openid email profile`
  - `--insecure-oidc-allow-unverified-email` (optional, only needed if users' emails are not verified)
- The AKS pod uses `hostAliases` to resolve `keycloak.web.com` to the correct Keycloak IP for in-cluster OIDC communication.
- The login flow now works end-to-end, and the protected app is accessible after authentication.

### Troubleshooting Lessons Learned
- If you see `Error creating session during OAuth2 callback: neither the id_token nor the profileURL set an email`, ensure:
  - The user has a valid email and no required user actions (like "Verify Email").
  - The `email` client scope is assigned as Default to the client.
  - The `email` and `email_verified` mappers are present and set to add claims to the ID token.
  - The OAuth2 Proxy is requesting the `email` scope.
  - The OIDC issuer URL matches exactly what Keycloak advertises in the token's `iss` claim.
- Use curl with the password grant to directly test token issuance and confirm claims.
- Restart oauth2-proxy after config changes to clear any cached state.
- Use incognito/private browser windows to avoid cookie/caching issues during testing.

### Security Note
- For production, always use HTTPS and ensure all OIDC endpoints are public and DNS-resolvable.
- Remove `--insecure-oidc-allow-unverified-email` if all users have verified emails for better security.

---
