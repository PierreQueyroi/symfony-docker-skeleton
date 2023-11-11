#!/bin/sh
set -e

cd /pgadmin4

export PGADMIN_DEFAULT_EMAIL=${PGADMIN_USER}
export PGADMIN_DEFAULT_PASSWORD=${PGADMIN_PWD}
export PGADMIN_DISABLE_POSTFIX="true"
export PGADMIN_ENABLE_TLS="true"
export PGADMIN_CONFIG_SERVER_MODE="True"

echo "$DATABASE_HOST:$DATABASE_PORT:$DATABASE_NAME:$DATABASE_USR:$DATABASE_PWD" > /pgadmin4/pgpass
echo "$DATABASE_HOST:$DATABASE_PORT:postgres:$DATABASE_USR:$DATABASE_PWD" >> /pgadmin4/pgpass
echo "{\"Servers\":{\"1\":{\"Name\":\"Postgres DB\",\"Port\":$DATABASE_PORT,\"Username\": \"$DATABASE_USR\",\"Group\":\"Servers\",\"Host\":\"db\",\"SSLMode\":\"prefer\",\"PassFile\":\"/pgpass\",\"MaintenanceDB\":\"$DATABASE_NAME\"}}}" > /pgadmin4/servers.json

PGADMIN_DIR=${PGADMIN_USER/@/_}

if [ ! -d /var/lib/pgadmin/storage ]; then
  mkdir /var/lib/pgadmin/storage
fi
if [ ! -d /var/lib/pgadmin/storage/${PGADMIN_DIR} ]; then
  mkdir -m 700 /var/lib/pgadmin/storage/${PGADMIN_DIR}
  chown -R pgadmin:root /var/lib/pgadmin/storage/${PGADMIN_DIR}
fi
cp /pgadmin4/pgpass /var/lib/pgadmin/storage/${PGADMIN_DIR}/
chmod 600 /var/lib/pgadmin/storage/${PGADMIN_DIR}/pgpass
chown pgadmin:root /var/lib/pgadmin/storage/${PGADMIN_DIR}/pgpass
sh /entrypoint.sh