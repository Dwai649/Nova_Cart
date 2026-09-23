1. Architecture

Deployment is split into two decoupled pipeline families rather than one monolithic pipeline:

Infrastructure pipeline (terraform-*.yml) — owns the Azure platform resources (VNet, NSGs, Postgres, the ACA environment, and the container app definitions) via Terraform.
Application pipelines (backend-*.yml, frontend-*.yml) — build a container image, push it to Azure Container Registry (ACR), and roll it out to the existing container app with az containerapp update.

They are intentionally not chained. Path filters mean each pipeline only runs when the code it owns changes (**.tf/**.tfvars vs. novacart/backend/** / novacart/frontend/**).


2. Infrastructure pipeline (terraform-plan-apply.yml)

Triggers: pull_request and push to main, scoped to **.tf, **.tfvars, and the workflow file itself.

plan job (runs on PR and push):

terraform fmt -check -recursive, terraform init, terraform validate
terraform plan, captured rather than allowed to silently pass:
Output is posted as a PR comment (pull-requests: write permission is actually used for this).
If the plan fails, the job now fails explicitly instead of being masked by continue-on-error.

apply job (push to main only, environment: dev for approval/audit):

Re-runs terraform init / plan / apply against the current state (deliberately re-plans rather than reusing the PR's plan file, since the image tag variable may have moved on since the PR was opened).

3. Application pipelines (e.g. backend-validate-build.yml)

Triggers: pull_request and push to main, scoped to novacart/backend/**.

Steps, in order:

Checkout, set up Python, install deps.
Run the test suite (pytest) — on every PR and push, regardless of whether a deploy will follow.
Compute an image tag: v1.0.0-<git-sha>.
PR runs stop here. Login to ACR, image build/push, Azure login, and the ACA update step are all gated on github.event_name != 'pull_request' — a PR can no longer attempt to deploy an image it never built.
Push-to-main runs continue:
Log in to ACR, build the image, push it as <ACR_LOGIN_SERVER>/my-backend:<tag>.
az containerapp update --name backend --resource-group RG-NOVACART-DEV --image <ACR_LOGIN_SERVER>/my-backend:<tag> — this is the actual deploy step; it updates the running revision to the new image immediately.

5. Credentials

All credentials live in GitHub Actions secrets/variables, not in source:

Name	Type	Used by	Purpose
ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID	Secret	Both pipelines	Service principal for Terraform provider auth and azure/login
ACR_LOGIN_SERVER, ACR_USERNAME, ACR_PASSWORD	Secret	App pipelines	ACR admin credentials for docker login/push
PG_ADMIN_PASSWORD	Secret	Infra pipeline	Postgres admin password (TF_VAR_administrator_password)
BACKEND_IMAGE_TAG / FRONTEND_IMAGE_TAG	Repo variable	Infra pipeline	Initial/baseline image tag Terraform uses when (re)creating the container app


