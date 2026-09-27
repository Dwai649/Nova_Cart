FROM nginx:1.27-alpine

COPY index.html /usr/share/nginx/html/index.html
COPY app.js /usr/share/nginx/html/app.js
COPY styles.css /usr/share/nginx/html/styles.css


COPY nginx.conf.template /etc/nginx/templates/nginx.conf.template


EXPOSE 8081

CMD ["/bin/sh", "-c", \
"envsubst '$BACKEND_HOST $BACKEND_PORT' /etc/nginx/templates/nginx.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]

