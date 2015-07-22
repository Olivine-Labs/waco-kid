#!/bin/bash
PORT=80
TAG=wacokid

docker build -t $TAG . &&\
DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd) &&\
CID=$(docker run -d -v "$DIR:/app" $TAG) &&\
echo $CID > ./app.pid &&\
IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${CID}) &&\
echo "http://$IP:$PORT"
