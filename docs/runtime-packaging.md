Your Docker packaging approach - two seperate containers under one for backend and one for frontend.Used slim and alipne versiobns to miminimize the package size. With the backend image having a total size of 60.5MB and frontend image having a size of 21MB.
How frontend and backend dependencies are handled - Through seperate env files storing usefull information and runtime dependencies . Not hardcodig them in the docker file.
How the frontend is served at runtime, including any webserver such as Nginx - The nginx container is used fro serving the frontend content. All the files are copied into the /usr/share/nginx/html/ folder.

How runtime configuration is supplied - docker run --network app-network --name storefrontapp -p 8081:8081 nginxwebstorefront:v1.0.0 

What database mode is used when running the backend container separately - If we dont set the DATABASE_URL it will automaticaaly use the default SQLlite DB .

Which ports/interfaces are exposed - for the backend port 8080 is exposed and for the frontend container 8081 is being exposed.

How each container image is built - docker build -t fastapiappnovacart . for backend and docker build -t nginxwebstorefront:v1.0.0 . for frontend.

How each application component is started separately as its own container - First the backend starts and then the frontend which. I stopped the backend without stopping the frontend which gave Unable to load products from /api. Start the backend and reload. (HTTP 502).  

What assumptions the runtime environment must satisfy - The backend and the frontend should be inside a common network otherwise DNS resolution does not happen and frontend cannot connect to the backend. The env files should be used while running the frontend and it should clearly state the BACKEND_HOST and BACKEND_PORT Information.

Trade-offs or limitations in your approach - How to loadbalance if there are more traffic incoming, I tried to keep it simple as possible need to learn more optimizations maybe for reducing image size and also reducing build time ( which I took help from your course where you deployed a Python Flask application and also showed how to write the Dockerfile in such a way by copying the requirements.txt first so that it doesnt build everytime we have changes in the code ), Vulnerability checks of my image how to ensure the base images having high CVSS score and scan them before pushing to container registry.

