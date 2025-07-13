# AKS Keycloak Deployment

This project deploys a complete Keycloak authentication system on Azure Kubernetes Service (AKS) with OAuth2 proxy integration.

## Architecture

The deployment includes:
- **Keycloak**: Identity and Access Management server
- **PostgreSQL**: Database for Keycloak with persistent storage
- **OAuth2 Proxy**: Authentication proxy for securing web applications
- **Nginx Ingress Controller**: Load balancer and SSL termination
- **Web Application**: Sample secured application

## Prerequisites

- Azure CLI
- Terraform
- kubectl
- Ansible

## Deployment

### 1. Infrastructure Setup

```bash
cd aks-cluster
terraform init
terraform plan
terraform apply
```

### 2. Application Deployment

The application is automatically deployed via GitHub Actions when infrastructure is created.

Manual deployment:
```bash
# Deploy namespaces
ansible-playbook ansible/playbooks/deploy_namespace.yaml

# Deploy secrets
ansible-playbook ansible/playbooks/deploy_secrets.yaml

# Deploy persistent storage
ansible-playbook ansible/playbooks/deploy_pvc.yaml

# Deploy database
ansible-playbook ansible/playbooks/deploy_postgres.yaml

# Deploy Keycloak
ansible-playbook ansible/playbooks/deploy_keycloak.yaml

# Deploy web application
ansible-playbook ansible/playbooks/deploy_web.yaml
ansible-playbook ansible/playbooks/deploy_configmap.yaml

# Deploy RBAC and ingress
ansible-playbook ansible/playbooks/deploy_rbac.yaml
ansible-playbook ansible/playbooks/deploy_sa.yaml
ansible-playbook ansible/playbooks/deploy_ingress.yaml

# Deploy OAuth2 proxy
ansible-playbook ansible/playbooks/deploy_oauth.yaml
```

## Security Features

- **Kubernetes Secrets**: Sensitive data stored in encrypted secrets
- **HTTPS/TLS**: SSL termination with Let's Encrypt certificates
- **Resource Limits**: CPU and memory limits for all containers
- **Health Checks**: Liveness and readiness probes
- **Persistent Storage**: Database data persistence

## Configuration

### Keycloak Admin
- Username: `admin`
- Password: `admin` (stored in Kubernetes secret)

### OAuth2 Proxy
- Client ID: `test-web-app`
- Redirect URL: `https://auth.web.com/oauth2/callback`

## Access Points

- **Keycloak Admin Console**: `http://<keycloak-service-ip>:8080`
- **Secured Web App**: `https://auth.web.com`

## Monitoring

All containers include:
- Resource monitoring
- Health check endpoints
- Logging to stdout/stderr

## Troubleshooting

1. **Check pod status**: `kubectl get pods -n keycloak-app`
2. **View logs**: `kubectl logs <pod-name> -n keycloak-app`
3. **Check services**: `kubectl get svc -n keycloak-app`
4. **Verify secrets**: `kubectl get secrets -n keycloak-app`

## Cleanup

```bash
cd aks-cluster
terraform destroy
```

## Security Notes

⚠️ **Important**: This is a development setup. For production:
- Use proper secret management (Azure Key Vault, HashiCorp Vault)
- Implement proper RBAC
- Use managed databases
- Configure backup strategies
- Implement monitoring and alerting