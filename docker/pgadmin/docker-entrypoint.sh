#!/bin/sh
set -e

echo "$DATABASE_HOST:$DATABASE_PORT:$DATABASE_NAME:$DATABASE_USR:$DATABASE_PWD" > /pgadmin4/pgpass
echo "$DATABASE_HOST:$DATABASE_PORT:postgres:$DATABASE_USR:$DATABASE_PWD" >> /pgadmin4/pgpass
echo "{'Servers':{'1':{'Name':'Postgres DB','Port':$DATABASE_PORT,'Username': '$DATABASE_USR','Group':'Servers','Host':'db','SSLMode':'prefer','PassFile':'/pgpass','MaintenanceDB':'$DATABASE_NAME'}}}" > /pgadmin4/servers.json

PGADMIN_USER=${PGADMIN_USER | sed 's/@/_/g'}

mkdir -m 700 /var/lib/pgadmin/storage/${PGADMIN_USER}
chown -R pgadmin:root /var/lib/pgadmin/storage/${PGADMIN_USER}
cp /pgadmin4/pgpass /var/lib/pgadmin/storage/${PGADMIN_USER}/
chmod 600 /var/lib/pgadmin/storage/${PGADMIN_USER}/pgpass
chown pgadmin:root /var/lib/pgadmin/storage/${PGADMIN_USER}/pgpass
sh /entrypoint.sh