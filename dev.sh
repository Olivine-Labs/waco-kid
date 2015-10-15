#!/bin/bash
PORT=80
TAG=wacokid

docker build -t $TAG . &&\
DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd) &&\
CID=$(docker run -d -v "$DIR:/app" $TAG) &&\
echo $CID > ./app.pid &&\
if [ "x${DOCKER_HOST}" = 'x' ]; then
  IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${CID})
else
  IP=$(docker-machine ip $(docker-machine active))
fi
echo "http://$IP:$PORT"
