how PostgreSQL connectivity changed -
Previously postgreSQL was in a public network , that means anyone who has an access or if allowed in the firewall can directly connect to  the database endpoint and can directly access critical business application data.

what Azure networking resources were required - VNET ( Virtual Networks ) , Subnets ( Delegated subnets in this case was used were we have two delgated subnets one for the application container environment and another for the postgres DB flexible servers), private DNS Zone, Private link ( For linking the DNS Zone to the VNET)

how the application compute is connected to the network that can reach PostgreSQL - the backend application connects to the postgres DB using its FQDN and default port 5432. The DB subnet has an NSG applied which allows inbound from only backend app on port 5432.

what name-resolution resources were required - Private DNS Zone and privatelink was required .

what changed in the app-to-database path - Previously the application had to be allowed by the DB firewall to reach the DB endpoint and now since its inside a private network the app can access the DB and connect using the FQDN ( Since ip address of the postgres DB servers can change its always better to use a private DNS which helps in resolving the ip address and thus in the backend container app we do not have to explicitly provide the IP_Address rather we use the FQDN)

how you verified the database is no longer public - By trying to use the postgres DB client in my local environment and connect it and also tried using telnet from the local environment which failed. Thus we can conclude its inside a VNET fully private and can be accessed via the resources within azure network (using VNET Peering) and within the VNET.

how you verified the application still works after the change - Tried testing some of the APIs aand it worked perfectly, there were no issues. Also checked the connections from backend app to the DB using telnet and that also worked fine.
