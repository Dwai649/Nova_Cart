How does your Git workflow operate? 
Its a gitflow having three branches main, develop, hotfix
How is main protected?
Its protected using brach rules the main and develop branch are both protected.
How are changes reviewed and validated?
Reviewers are added and its implemented in the branch rules.
How would an emergency fix be handled?
Emergency fixes are handled via hotfix branch.

How is the application packaged?
Seperate DockerFiles for frontend and backend.
How are frontend, backend, and PostgreSQL started?
They are started  in a sequence , where the frontend depends on the backend , the backend depends on the DB. Also added health tests to ensure the services start properly. The backend starts after the DB has been started properly.

How do services discover and communicate with each other?
Services Communicate via docker network and service names which are added in the Docker DNS. In current scenario there is one network under which all the containers are present. But better solution is to divide into two seperate networks where the frontend and backend will be under a common network and the DB and backend in another network .


How is runtime configuration supplied?
Runtime configuration is supplied via environment variables which are never commited to the repo.

Where does persistent data live?
For postgresql DB we have the data voulme which is used to persist the data.

How are health and readiness verified?
 health checks are verified using 
    healthcheck: 
      test: ["CMD-SHELL","pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}"]
      interval: 5s
      timeout: 5s
      retries: 5
So if DB is healthy and after the checks are successful the backend container will start. Unless DB health checks are not successfull the container will not start .

CI
What happens when a pull request is created?
Whenever a pull request is being created the workflows get triggered. This is done by using 
on:
  pull_request:
    branches: ["main"]
  push:
    branches: ["main"]

What does CI validate? 
The CI is used to validate the test cases for the backend app, We use pytest here to check the test cases which ahve been used for validation if the backend is working fine. For the frontend there are some syntax based checks and other test cases which needs to be added.
What happens when validation fails?
If the validation fails we will not be able to merge the changes into main . The nesxt step is to check at which level the worflow has failed from the workflow run logs.
Which checks are required before merge?
If the backend test cases are successfull or not, If for the frontend app JS syntax is fine or not

What important checks are still missing?

Will have to check that.

Production Readiness
Identify the top five real risks you would address before exposing NovaCart to real customers.

For each risk, document:

Problem - Application secrets, database credentials, API keys, or connection strings may be stored in GitHub Secrets, environment files, or container environment variables without centralized secret management.
Potential impact - If someone gets unauthorized access to the repo these credentials will be exposed. This will lead to access to DB and leak customer data.
Recommended improvement - Using of Services like Azure key Vault to store the secrets and credentials 
Priority: High

Problem - Currently we are running single DB instance without HA/DR
Potential impact - If somehow the primary DB crashes this will lead to downtime and thus lead to business loss.
Recommended improvement - Implement HA/DR in postgres DB with resplication enabled so that Data can be replicated to the seconday node and there wont be any data loss.
Priority: High

Problem - Security Scanning of Dockerimages
Potential Impact - Without scanning vulnerable packages may reach production environments.
Recommended improvement - We need to add a step in our GitHub Actions workflow to scan the Dockerimages after they are getiing built. using Security scanner like Trivy to ensure we are compliant with the latest DevSecOps practises.
Priority: High




Recommendation
Finish with one of the following exact recommendations. “READY” means that cloud infrastructure design may begin; it does not mean that NovaCart is safe to expose to real customers.

READY TO PROCEED TO CLOUD INFRASTRUCTURE DESIGN - Yes READY with the infratsructure Design and also more enhancements will be made to the current workflow going forward.

