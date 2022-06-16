FROM nginx

#ARG NGINX_RESOLVER
#ARG NGINX_RESOLVER_TIME_OUT

#ENV MYVARS='$NGINX_RESOLVER:$NGINX_RESOLVER_TIME_OUT'

#ENV appDir /var/www/public
RUN mkdir -p  /var/www
#COPY ./nginx.conf /var/www/public/
COPY nginx.conf /etc/nginx/nginx.conf
COPY . /var/www

#RUN /bin/bash -c "envsubst '$MYVARS' < /var/www/public/nginx.conf > /etc/nginx/nginx.conf"

#RUN mkdir -p  /var/www/public
#WORKDIR ${appDir}

EXPOSE 80
