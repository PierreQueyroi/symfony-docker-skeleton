FROM php:8.2.6-fpm-alpine3.18 AS app_php_prod

WORKDIR /var/www/

# ----- Upgrade to latest ----

RUN apk update; \
	apk upgrade

# ----- Adding User -----

RUN adduser projectuser -u 1000 -HD --home /home/projectuser; \
	mkdir /home/projectuser; \
	chown 1000:1000 /home/projectuser; \
	chown 1000:1000 /var/www; \
	rm -rf /var/www/html

# ----- Installing persistent / runtime deps

RUN apk add --no-cache \
		acl \
#		fcgi \
#		file \
#		gettext \
		git \
#		gnupg \
	;

# ----- Installing PHP extensions -----

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN install-php-extensions \
        apcu \
        gd \
        intl \
        opcache \
        pdo_pgsql \
        pgsql \
        xsl \
        zip

# ----- Copying parameters files -----

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY ./conf.d/app.ini $PHP_INI_DIR/conf.d/
COPY ./conf.d/app.prod.ini $PHP_INI_DIR/conf.d/

COPY ./php-fpm.d/*.conf /usr/local/etc/php-fpm.d/
RUN mkdir -p /var/run/php

# ----- Installing composer -----

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

USER root

# ----- Adding healthcheck -----

COPY ./docker-healthcheck.sh /usr/local/bin/docker-healthcheck
RUN chmod +x /usr/local/bin/docker-healthcheck
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD ["docker-healthcheck"]

# ----- Adding entrypoint -----

COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint; \
	chown 1000:www-data /usr/local/bin/docker-entrypoint

USER 1000

ENTRYPOINT ["docker-entrypoint"]
EXPOSE 9000
CMD ["php-fpm"]

# --------------- Dev image ------------------
FROM app_php_prod AS app_php_dev

USER root

RUN rm $PHP_INI_DIR/conf.d/app.prod.ini; \
	mv "$PHP_INI_DIR/php.ini" "$PHP_INI_DIR/php.ini-production"; \
	mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

COPY ./conf.d/app.dev.ini $PHP_INI_DIR/conf.d/

RUN set -eux; \
	apk add --no-cache --virtual .build-deps $PHPIZE_DEPS; \
	apk add --update linux-headers; \
	pecl install xdebug; \
	docker-php-ext-enable xdebug; \
	apk del .build-deps;\
	mkdir /tmp/xdebug;\
	touch /tmp/xdebug/xdebug.log;\
	chmod 0777 /tmp/xdebug/xdebug.log;

USER 1000
