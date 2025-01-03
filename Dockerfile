FROM alpine:3.14
RUN addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && apk add openssl curl ca-certificates \
    && printf "%s%s%s%s\n" "@nginx " "http://nginx.org/packages/alpine/v" `egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release` "/main">
    && curl -o /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
    && openssl rsa -pubin -in /tmp/nginx_signing.rsa.pub -text -noout \
    && mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/ \
    && apk add nginx-module-image-filter@nginx nginx-module-njs@nginx \
# Forward request and error logs to Docker log collector
    && chown -R nginx:nginx /usr/share/nginx/html \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
COPY --chown=nginx:nginx index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
