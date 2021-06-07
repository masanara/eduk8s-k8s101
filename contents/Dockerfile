FROM quay.io/mnara/ubuntu:latest
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log
COPY index.html /var/www/html/
EXPOSE 80 443
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
