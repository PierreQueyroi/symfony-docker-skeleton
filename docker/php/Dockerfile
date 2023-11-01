FROM php:8.2.6-fpm-alpine3.18 AS app_php_prod

WORKDIR /var/www/

# ----- Upgrade to latest ----

RUN apk update
RUN apk upgrade

#Adding User

RUN adduser projectuser -u 1000 -HD --home /home/projectuser
RUN mkdir /home/projectuser
RUN chown 1000:1000 /home/projectuser
RUN chown 1000:1000 /var/www
RUN rm -rf /var/www/html
# ----- INSTALLING dependencies -----

# persistent / runtime deps
RUN apk add --no-cache \
		acl \
		fcgi \
		file \
		gettext \
		git \
		gnupg \
	;

# PHP Packages Dependencies
RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		icu-data-full \
		icu-dev \
        postgresql-dev \
		libzip-dev \
		zlib-dev \
        freetype-dev \
		libpng-dev\
		libjpeg-turbo-dev\
		libsodium-dev \
		libxslt-dev \
        libgcrypt-dev \
	;
# PHP Package configure
RUN set -eux; \
	docker-php-ext-configure zip;

RUN set -eux; \
	docker-php-ext-configure intl;

RUN set -eux; \
	docker-php-ext-configure gd;
	# --with-gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/;

RUN set-eux; \
	docker-php-ext-install -j$(nproc) zip pdo_pgsql pgsql gd intl sodium opcache xsl;

# Adding acpu
RUN set -eux; \
	pecl install apcu ; \
	docker-php-ext-enable apcu; \
	pecl clear-cache ; \
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .app-phpexts-rundeps $runDeps; \
	apk del .build-deps

# ----- COPYING Parameters Files -----

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY ./conf.d/app.ini $PHP_INI_DIR/conf.d/
COPY ./conf.d/app.prod.ini $PHP_INI_DIR/conf.d/

COPY ./php-fpm.d/*.conf /usr/local/etc/php-fpm.d/
RUN mkdir -p /var/run/php

# ----- Installing COMPOSER -----

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
# ENV COMPOSER_ALLOW_SUPERUSER=1
# ENV PATH="${PATH}:/root/.composer/vendor/bin"

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

#RUN apk del .build-deps

EXPOSE 9000

USER root

# Adding HEALTHCHECK

COPY ./docker-healthcheck.sh /usr/local/bin/docker-healthcheck
RUN chmod +x /usr/local/bin/docker-healthcheck
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD ["docker-healthcheck"]

# Adding Entrypoint

COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint
RUN chown 1000:www-data /usr/local/bin/docker-entrypoint

USER 1000

ENTRYPOINT ["docker-entrypoint"]
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

EXPOSE 5173
