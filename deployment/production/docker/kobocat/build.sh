#!/usr/bin/env bash
set -e

if [ -z "$REPO_NAME" ]; then
	REPO_NAME=kartoza
fi

if [ -z "$SERVICE_NAME" ]; then
	SERVICE_NAME=kobocat
fi

if [ -z "$IMAGE_NAME" ]; then
	IMAGE_NAME=${REPO_PREFIX}_${SERVICE_NAME}
fi

if [ -z "$TAG_NAME" ]; then
	TAG_NAME=2.018.31
fi

if [ -z "$BASE_IMAGE_NAME" ]; then
	BASE_IMAGE_NAME=kobotoolbox/kobocat:2.018.31
fi

if [ -z "$BUILD_ARGS" ]; then
	BUILD_ARGS="--pull --no-cache"
fi

# Build Args Environment

if [ -z "$KOBOCAT_TEMPLATE_REPO" ]; then
 	KOBOCAT_TEMPLATE_REPO=git@github.com:kartoza/kobocat-template.git
fi

if [ -z "$KOBOCAT_TEMPLATE_TAG" ]; then
	KOBOCAT_TEMPLATE_TAG=develop
fi

echo "KOBOCAT_TEMPLATE_REPO=${KOBOCAT_TEMPLATE_REPO}"

echo "KOBOCAT_TEMPLATE_TAG=${KOBOCAT_TEMPLATE_TAG}"


echo "Build: $REPO_NAME/$IMAGE_NAME:$TAG_NAME"

echo "Generate Dockerfile"

export PYTHONPATH="$PWD/../"

python -c "from utils.helpers import *;generate_dockerfile_for_service('$SERVICE_NAME', '$BASE_IMAGE_NAME')"

cat Dockerfile

docker build -t ${REPO_NAME}/${IMAGE_NAME} \
	--build-arg KOBOCAT_TEMPLATE_REPO=${KOBOCAT_TEMPLATE_REPO} \
	--build-arg KOBOCAT_TEMPLATE_TAG=${KOBOCAT_TEMPLATE_TAG} \
	${BUILD_ARGS} .
docker tag ${REPO_NAME}/${IMAGE_NAME}:latest ${REPO_NAME}/${IMAGE_NAME}:${TAG_NAME}
# docker push ${REPO_NAME}/${IMAGE_NAME}:${TAG_NAME}
