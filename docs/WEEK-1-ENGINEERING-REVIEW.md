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
What does CI validate?
What happens when validation fails?
Which checks are required before merge?
What important checks are still missing?

Production Readiness
Identify the top five real risks you would address before exposing NovaCart to real customers.

For each risk, document:

Problem
Potential impact
Recommended improvement
Priority: High / Medium / Low
Your risks must be based on the environment you actually built, not generic production recommendations.

Recommendation
Finish with one of the following exact recommendations. “READY” means that cloud infrastructure design may begin; it does not mean that NovaCart is safe to expose to real customers.

READY TO PROCEED TO CLOUD INFRASTRUCTURE DESIGN

