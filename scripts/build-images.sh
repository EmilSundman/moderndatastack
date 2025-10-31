#!/bin/bash
set -e # Break on error

# --- Define variables ---

## Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
LIGHT_GRAY='\033[1;30m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
NC='\033[0m' # No Color

## Repositories to build
DAEMON_REPO="dagster-daemon"
WEBSERVER_REPO="dagster-webserver"
CODE_LOCATION_REPO="dbt-code-location"

## User inputs
TAG=${1:-"latest"} # From the first argument


# --- Build images ---
## Build images from docker compose file 
echo -e "${ORANGE}Building images from docker compose file...${NC}"
docker compose --file docker-compose.dev.yaml build 
echo -e "${GREEN}Done building images from docker compose file${NC}"
echo -e "--------------------------------"

## Tag images with input
echo -e "${ORANGE}Tagging images with input...${NC}"
docker tag $DAEMON_REPO $DAEMON_REPO:$TAG
docker tag $WEBSERVER_REPO $WEBSERVER_REPO:$TAG
docker tag $CODE_LOCATION_REPO $CODE_LOCATION_REPO:$TAG
echo -e "${GREEN}Done tagging images with input${NC}"
echo -e "--------------------------------"

## Tag images with latest
echo -e "${ORANGE}Tagging images with latest tag...${NC}"
docker tag $DAEMON_REPO $DAEMON_REPO:latest
docker tag $WEBSERVER_REPO $WEBSERVER_REPO:latest
docker tag $CODE_LOCATION_REPO $CODE_LOCATION_REPO:latest
echo -e "${GREEN}Done tagging images with latest${NC}"
echo -e "--------------------------------"
echo -e "${LIGHT_GREEN}Done building images${NC}"