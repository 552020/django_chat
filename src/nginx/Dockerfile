# ARG NGINX_VERSION=1.26.1
# TODO: Make it a variable
FROM nginx:1.26.1

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY /frontend/ /usr/share/nginx/html
COPY /etc/letsencrypt/live/django.sldunit.xyz /etc/ssl/certs/
COPY /etc/letsencrypt/archive/django.sldunit.xyz /etc/letsencrypt/archive/django.sldunit.xyz
