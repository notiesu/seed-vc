#!/bin/sh

export $(grep -v '^#' .env | xargs)
docker run --rm -it $DOCKER_USER/audio-ml:v$1