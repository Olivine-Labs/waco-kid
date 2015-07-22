#!/bin/bash

docker logs $(cat ./app.pid)
