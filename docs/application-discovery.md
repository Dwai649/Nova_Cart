* Application components:  FrontEnd,backend,DB
* Languages and frameworks: Python,JavaScript,HTML5,CSS
* Startup/build commands: python -m uvicorn app.main:app --host 0.0.0.0 --port 8080
* Listening ports: 8080 
* Application dependencies: fastapi==0.128.2 uvicorn==0.48.0 psycopg[binary]>=3.2,<4
* Configuration and environment variables: DB_URL,APP_ENV,API_VERSION,LOG_LEVEL
* Secrets or sensitive configuration: seperate .env file and store these in     Secret manager in future
* Persistence requirements: Persistence Required because order related history,user history need to be stored.
* Database dependencies: PostgresSQL
* Health and readiness behavior: @app.get("/health") API, @app.get("/ready")
* Service-to-service communication: api/prducts, api/orders endpoints are exposed , it can be later used by a payment service or something else maybe.
* Logging behavior: INFO
* External dependencies, if any
* Runtime assumptions
* Risks or missing information
* Questions you would ask the development team before production deployment: what more services will be added later, If new features are going to be shipped very fast and frequency or the project sprint. 
