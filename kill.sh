#!/bin/bash

docker kill $(cat ./app.pid)
docker rm $(cat ./app.pid)

rm ./app.pid
