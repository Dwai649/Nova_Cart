##) What infrastructure the pipeline manages.

Manages (plan + apply, on every relevant run): the dev stack only — VNet and its three subnets, both NSGs, the Postgres flexible server, the Container Apps environment, and the backend and frontend container apps.

Builds and pushes, but doesn't "manage" as infrastructure: the backend Docker image, via Backend_test.yaml called as a job. Tests run first; the image only gets pushed if they pass and the trigger isn't a PR. So during the PR only the basic tests are concluded and the terraform plan is executed.

The SP and the ACR is created by seperate bootstrap TF code. The state is seperately stored and thus does not collide and the state is stored remotely in the storage account under three different containers.

**********************************************************************************

##) When the infrastructure workflow runs

Triggers on paths **.tf, **.tfvars, and the workflow file itself — not on arbitrary application code changes:

Pull request to main, touching those paths → plan job only. Posts the plan as a PR comment. Never applies.
Push to main (i.e., a merge), same paths → backend-build → plan → apply, in that order.
Manual workflow_dispatch → same chain as push.

A change to application code alone (novacart/backend/**) triggers Backend_test.yaml directly through its own independent pull_request/ push triggers — tests and, on main, a build/push — without touching this workflow or the infrastructure at all, unless a .tf file changed in the same push. But later will also design such that if there are code changes in backend or frontend the CI and CD will run simultaneously after one another.

**********************************************************************************

##) How infrastructure changes are reviewed before being applied

Via the plan as it will first run and if there are errors someone can checka and validate the changes. After checking if there are errors they can pull the recent changes from the repo and again make their nescessary changes and push to the remote and open a PR approval. Once the PR is okay and the terraform plan is successfull and the checks are okay . Then one can deploy the infra as required.

*********************************************************************************

##) How Terraform state is stored and protected

Azure Blob Storage (sttfstatenovacart / RG-TFSTATE), one blob per stack — dev.terraform.tfstate, bootstrap.terraform.tfstate, identity.terraform.tfstate — so a destroy on one stack can't touch another's state. Blob leasing gives automatic locking: a concurrent plan and apply against the same stack can't corrupt each other.



********************************************************************************

##)  How the pipeline authenticates

Worth answering precisely rather than assuming the premise: this pipeline does not currently avoid long-lived credentials. The deliberate choice made here was a service principal with a client secret, not OIDC federated identity — the opposite of credential-free. ARM_CLIENT_SECRET is a static string sitting in GitHub secrets with roughly a one-year expiry (end_date in bootstrap/identity/main.tf), not a token minted fresh per run.

*********************************************************************************

##) What is in place to limit the blast radius of that trade-off:

The secret is never in code or Terraform output visible to a PR author — only in GitHub's encrypted secrets store, referenced by name.
The principal is scoped narrowly: Contributor + RBAC Administrator on the dev resource group only, AcrPush on the registry's resource group only — not subscription-wide.
It was created once, by hand, outside any automated flow, specifically so a compromised CI run can't regenerate its own credential.
Rotation is a documented, deliberate action (bootstrap/identity/README.md), not automatic.

**********************************************************************************

##)  Where workflow results and failures are visible
GitHub Actions tab — the authoritative record: every job, every step, full logs, for both this workflow and Backend_test.yaml.
PR comments — the plan output, automatically, for any PR touching infra. This is the only result surfaced somewhere other than the Actions tab.
terraform output at the end of apply — printed to that job's log only (frontend URL, backend internal FQDN). Not persisted anywhere else, not posted anywhere else.


***********************************************************************************

##) What would be risky to rely on in production

The long-lived client secret, restated from above — the single biggest pipeline-specific item on this list. A leaked secret with a year of validity is a materially worse exposure window than a federated token that's already expired by the time anyone could misuse it.

No smoke test after apply. The pipeline calls the job done when terraform apply exits 0 — which only proves Azure accepted the resource definitions, not that the frontend actually serves a page or the backend actually answers a health check. This gap is not hypothetical: the frontend probe failure surfaced earlier in this project would have sailed through this exact pipeline as a "successful" apply.

One shared identity doing everything. The same principal builds, pushes, and applies infrastructure. Fine for a single dev environment; in production this is usually split by purpose (a narrower push-only identity for CI builds, a separate apply identity, ideally both via OIDC) so a compromise in one pipeline doesn't carry the other's permissions with it.



