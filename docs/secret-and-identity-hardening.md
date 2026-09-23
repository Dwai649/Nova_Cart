what secrets exist -
  Secrets used here are mostly the enviroenment variables used for the backend container apps and rest are secrets for the Azure environment itself.

where they are stored  - Secrets are stores in Github Actions Secrets and are applied during runtime.

how the application receives them - The application (backend and frontend ) recieves them using github secrets. 

how deployment authentication works - This is done via firtsly logging into the Azure environment using a dedicated service principal and later the container apps use a managed identity to authenticate and pull the secrets from the ACR.

which identities are used by which components - Service Principal used for authentication to azure and deploying the resources using terraform. The managed identity is used by the container apps to pll the latest images stored in the container registry.

how access is limited to what the app actually needs - Just providing the required roles which are needed via RBAC. 

how secret rotation would happen without source-code changes - Secrets are currently stored in actions and need to be rotated manually which is a design flaw and later will setup Azure Key vault for storing the secrets which will be used to pull the secrets and also we can rotate the secrets.

