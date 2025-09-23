#!/bin/sh

WRITE_TO_CACHE=false

cd ..

export $(grep -v '^#' ../.env | xargs)
# parse arguments
for arg in "$@"; do
  case $arg in
    --write-to-cache)
      WRITE_TO_CACHE=true
      shift
      ;;
  esac
done

CACHE_TO=""
LOAD_OPTION=""
if [ "$WRITE_TO_CACHE" = true ]; then
  CACHE_TO="--cache-to=type=registry,ref=docker.io/$DOCKER_USER/mycache:latest,mode=max"
  LOAD_OPTION="--load"
fi

docker buildx build \
  $CACHE_TO \
  --cache-from=type=registry,ref=docker.io/$DOCKER_USER/mycache:latest \
  --load \
  -t $DOCKER_USER/audio-ml:$1 \
  -f Dockerfile.handler \
  --push \
  .


echo "Built $DOCKER_USER/audio-ml:v$1"


