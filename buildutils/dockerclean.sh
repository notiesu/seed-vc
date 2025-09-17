#!/bin/zsh

#clean up docker images and containers
docker container prune -f          # safe: deletes only stopped containers
docker image prune -f              # deletes dangling images only
docker builder prune -a -f         # deletes build cache

#dont touch volumes for now
# docker volume prune -f             # deletes dangling volumes only