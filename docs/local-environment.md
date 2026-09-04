How the complete environment is started and stopped  - docker compose up for starting all the 3 components (DB,Backend,frontend) and docker compose down for stopping the components . 
How individual services can be restarted -  docker compose restart <service-name> also tested restarting the frontend after adding some products to the cart and since the data is persisted in DB now the products added to the cart stays
How the frontend container, including any webserver packaged with it, runs as part of the Compose stack -
  The frontend is used like this as written in the yaml  frontend:
    build: ./frontend  --using the Dockerfile we have already which copies the content to the /usr/share/nginx/html
    container_name: frontend
    env_file: ./frontend/.env -- to use the env variables 
    ports:
      - "8081:8081"  -- expose port 8081:8081
    networks:
      - app-network  -- uses the bridged network 
    depends_on:
      - backend   -- for the starup order.

How services discover and communicate with each other - frontend connects to the backend using the http://backend:8080 and the hostname gets resolved via the DNS which gets created when we use the docker network and the backend is connecting to the DB via the DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB} which is stored in the .env files .

How runtime configuration is supplied -> this is done via the env variables which are present in the particular folders for each component and they are being pulled via  env_file: ./frontend/.env . The common env is loacted in the root novacart folder which in this case holds the DB level env variables like username,pass etc.

How database persistence is handled -> Via using docker volumes volumes:
      - postgres_data:/var/lib/postgresql/data

How service health and readiness are determined - 

What happens when an individual service restarts - Data is still persisted once someone places an order . Also I tried testing restarting the frontend and backend and also to check the order history is being preserved. 

Which services and ports are accessible from the host - backend , frontend and DB ports.

Any assumptions, trade-offs, or limitations - DB ports should not be exposed as this is a high security risk in production environments. Need to think of load-balancing approaches and horizontal scaling as well so there is no downtime involved.

