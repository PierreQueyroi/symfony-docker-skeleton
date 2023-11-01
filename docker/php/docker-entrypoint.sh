#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ] || [ "$1" = 'php' ] || [ "$1" = 'bin/console' ]; then

	# ----- PROD Context ----
  if [ $APP_ENV = "prod" ]; then
      echo ""
      echo "Production environnement"
      echo ""
      composer install --no-dev --prefer-dist --no-progress --no-interaction
  fi

  # ----- DEV Context ----
  if [ $APP_ENV = "dev" ]; then
      echo ""
      echo "Development environnement"
      echo ""
      composer install --prefer-dist --no-progress --no-interaction
  fi

	setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX var
	setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX var
fi

echo ""
echo "Starting PHP server"
echo ""
exec docker-php-entrypoint "$@"
