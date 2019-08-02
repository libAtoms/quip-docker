#!/usr/bin/env bash

docker run --rm \
	-v $(pwd)/README.md:/data/README.md \
	-e SHORT_DESCRIPTION="QUIP - QUantum mechanics and Interatomic Potentials" \
	-e DOCKERHUB_USERNAME="$DOCKER_USERNAME" \
	-e DOCKERHUB_PASSWORD="$DOCKER_PASSWORD" \
	-e DOCKERHUB_REPO_PREFIX="$DOCKER_USERNAME" \
	-e DOCKERHUB_REPO_NAME="quip" \
	sheogorath/readme-to-dockerhub