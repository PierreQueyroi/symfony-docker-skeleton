#!/bin/bash

# Script for a quick launch of the project
# Need a running Docker installation and optionally

set -e

# Extra Display color :
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if Docker is running

if ! docker info > /dev/null 2>&1; then
  echo "This script uses docker, and it isn't running"
  sudo service docker start
  sleep 10
fi

# ----- Folders creation -----

DIRS="./public ./var ./vendor"

for DIR in $DIRS; do
  if [ ! -d "$DIR" ]; then
    # Take action if $DIR exists. #
    echo "${CYAN}Creating not existing $DIR${NC}"
    mkdir $DIR
  fi
done

# ----- Loading Local env vars -----

set -a
. ./.env
set +a

# ----- Adding PgAdmin local folders if needed -----
if [ -z ${PGADMIN_USER+x} ]; then
  # Ugly stuff for Wsl Host IP
  export IP_HOST=$(cat /etc/resolv.conf | grep nameserver | cut -d ' ' -f 2)

  # PgAdmin extra config :
  echo "$DATABASE_HOST:$DATABASE_PORT:$DATABASE_NAME:$DATABASE_USR:$DATABASE_PWD" > ./docker/pgadmin/pgpass
  echo "$DATABASE_HOST:$DATABASE_PORT:postgres:$DATABASE_USR:$DATABASE_PWD" >> ./docker/pgadmin/pgpass

  PGADMIN_SERVER=$(cat <<EOF
{
    "Servers": {
        "1": {
            "Name": "Docker-Compose Postgres SRV",
            "Port": $DATABASE_PORT,
            "Username": "$DATABASE_USR",
            "Group": "Servers",
            "Host": "$COMPOSE_PROJECT_NAME-db",
            "SSLMode": "prefer",
            "PassFile": "/pgpass",
            "MaintenanceDB": "$DATABASE_NAME"
        }
    }
}
EOF
)
  echo $PGADMIN_SERVER > ./docker/pgadmin/servers.json
fi

docker compose down
docker compose up -d

# ----- Display links -----

echo "-----------------------------------------------------------"
echo ""
echo "Sites available on the following Urls :"
echo ""
echo "Site symfony   :    ${GREEN}https://127.0.0.1"
echo ""
echo "Tools :"
echo "PgAdmin WebUi  :    ${GREEN}https://127.0.0.1:${PGADMIN_PORT:-8443}${NC}"
echo "Admin User     :    ${RED}$PGADMIN_USER${NC}"
echo "Admin Password :    ${RED}$PGADMIN_PWD${NC}"
echo ""
echo "DB Server      :    ${RED}db${NC}"
echo "DB Name        :    ${RED}${DATABASE_NAME}${NC}"
echo "DB User        :    ${RED}${DATABASE_USR}${NC}"
echo "DB Password    :    ${RED}${DATABASE_PWD}${NC}"
echo ""
echo "-----------------------------------------------------------"

# ----- Extra : Check if webserver is running -----


url="https://$SETUP_SITE_FRONT_URL/-admin/login"
wait_time=3
expected_status=200

echo ""
echo "${CYAN}Waiting for webserver to be ready${NC}"
echo ""
sleep 10

while [ "$status" != "$expected_status" ]; do
  status=$(curl --head --location --connect-timeout 5 --insecure --write-out %{http_code} --silent --output /dev/null ${url})
  #echo "$status"
  if [ "$status" = "$expected_status" ]; then
    echo "${GREEN}Server is ready (status_code: $status)${NC}"
  else
    echo "${RED}Server is not ready (status_code: $status)"
    echo "Waiting for $wait_time seconds${NC}"
    sleep $wait_time
  fi
 done
