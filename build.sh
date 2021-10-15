#!/bin/bash
#-------------ENVIRON-VARIABLES--------------------

echo "Building docker compose images..."
# Build all images of your project
docker-compose -f ./docker-compose.yml build
echo "--------- Starting Containers ---------"
# Runs all containers of your project
docker-compose -f ./docker-compose.yml up -d
