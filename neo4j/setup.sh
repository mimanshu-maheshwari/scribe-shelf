#! /bin/bash 

set -x 
set -eo pipefail 

type docker>/dev/null 2>&1 || {
	echo >&2 "Error: docker is missing."
	exit 1
}

NEO4J_IMAGE="neo4j:latest"
IMAGE_NAME="${NEO4J_IMAGE_NAME:=db_neo4j}"
DB_PORT="${NEO4J_PORT:=5432}"
DB_USER="${NEO4J_USER:=neo4j}"
DB_PASSWORD="${NEO4J_PASSWORD:=neo4j}"

# Pull the latest Neo4j image
echo "Pulling neo4j image..."
docker pull $NEO4J_IMAGE


# Check if a container with the same name is already running
if [ "$(docker ps -q -f name=$IMAGE_NAME)" ]; then
    echo "A running container with the name $IMAGE_NAME already exists. Stopping and removing it..."
    docker stop $IMAGE_NAME
    docker rm $IMAGE_NAME
elif [ "$(docker ps -aq -f name=$IMAGE_NAME)" ]; then
    echo "A container with the name $IMAGE_NAME exists but is not running. Removing it..."
    docker rm $IMAGE_NAME
fi

docker run \
	--name "${IMAGE_NAME}" \
	--publish=${DB_PORT}:${DB_PORT} --publish=7687:7687 \
  --env NEO4J_AUTH=${DB_USER}/${DB_PASSWORD} \
	 --volume=./data:/data \
	 --volume=./logs:/logs \
	-d "${NEO4J_IMAGE}"


