Azure resources you expect to create - Azurer services which will be required here are Azure container apps for deploying the frontend and backend containers. Azure PostgresSQL DB for hosting the DB [ Need to check if we can use HA for production scenario], Azure Container Registry where we will store our images and pipeline integration with the ACR using service principal, Azure monitoring insights,alerts,Log analytics workspace.
How the frontend and backend will run in Azure Container Apps

How container images will be stored and accessed from Azure Container Registry\
We can use the action azure/docker-login@v1 to access the container registry and push the image.Also the user in azure needs the role ACR push and ACR pull for doing these tasks. 

Frontend, backend, and PostgreSQL traffic flow - We can create a VNET and create two subnets one for the DB and one which will consist of the frontend and backend containers. Will use NSG at the subnet level tpo control the traffic.

Which endpoints the browser, frontend, backend, and database need to use -  
How the backend should reach PostgreSQL - Via the NSG which will allow only the backend to reach the DB and also we need to add rules to control the flow of network traffic.
Where PostgreSQL should live in the development architecture - 
Any hostname, URL, port, or configuration assumptions required for the services to communicate - 
How Container Apps should authenticate when pulling images from ACR
What basic platform logging or monitoring should exist for the environment
How Terraform should organize and manage the environment
Runtime assumptions
Risks or missing information
Questions you would ask before a production deployment