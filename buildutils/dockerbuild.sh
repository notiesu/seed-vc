#!/bin/sh

WRITE_TO_CACHE=false

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
  CACHE_TO="--cache-to=type=registry,ref=docker.io/notiesu/mycache:latest,mode=max"
  LOAD_OPTION="--load"
fi

docker buildx build \
  $CACHE_TO \
  --cache-from=type=registry,ref=docker.io/notiesu/mycache:latest \
  --load \
  -t notiesu/seedvc-infer:v$1 ..

echo "Built seedvc-infer:v$1"

