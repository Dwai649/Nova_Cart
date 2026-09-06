workflow triggers - two seperate workflows for building the frontend and backend. Triggers on pull_request on branches main and push on branches main . 


validation stages - Added validation steps which include the python tests using the test_api.py . If the tests fail then the workflow stops and also PR stays open and the changes cannot be merged.
what is tested or built - the test cases areused as described in the test_api.py and then the docker image is built once the test cases are passed.
what happens when a check fails - The workflow stops and we can check the errors from the github actions workflow run logs
how the workflow integrates with the pull request process - the triigers on: pull_request and push are used to trigger the workflow run . Whenever some new features are developed and pushed to the repo and a PR is created to merge the changes and once we submit the PR the CI job starts and executes the step by step stages. 
how secrets or credentials are handled - Secrets or Credentials are handled via GITHUB Actions Secrets. We have not declared those secrets during build time as we dont want our Docker Image to have those secret values , instead we need to use them during runtime once we deploy the app in any environment.
limitations or checks you would add before using this workflow for production - Add more test cases if possibe , properly use tags to version the docker image as now its using git sha-commit to tag the images, Scan the images using tools like Trivy, use environemnts and variables in github secrets and deploy them accordingly based on the environment values if its developement or staging or production.
