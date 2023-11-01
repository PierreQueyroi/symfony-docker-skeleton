FROM caddy:2.7-alpine

WORKDIR /var/www

# ----- Upgrade to latest ----
# RUN apk update &&\
# 	apk upgrade &&\
# 	apk install

# ----- Addin certutils ---

RUN apk add --no-cache nss-tools

# Implementing Docker Best Practices (container as non root)

RUN mkdir /data/caddy/pki
RUN adduser projectuser -u 1000 -G www-data -HD
RUN chown 1000:www-data -R /data/caddy/pki/
RUN chown 1000:www-data -R /config/caddy/

#RUN addgroup -g 82 -S www-data

USER 1000

COPY ./Caddyfile /etc/caddy/Caddyfile
CMD caddy run --config /etc/caddy/Caddyfile --adapter caddyfile

EXPOSE 80 443 2019
