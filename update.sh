#!/bin/sh

docker-compose down || exit 1
docker-compose pull || exit 1
docker-compose up --force-recreate --build -d || exit 1
docker image prune -f || exit 1
echo "Done updating"
