#!/usr/bin/env bash

echo "INFO - starting build process"

################################
# Sourcing external properties #
################################
readonly BUILD_ENV_FILE=./build.env
if [ ! -f "${BUILD_ENV_FILE}" ]; then
    echo "ERROR - could not find ${BUILD_ENV_FILE}"
    exit 1
fi

source ./build.env

echo "INFO - artifactory = ${ARTIFACTORY_HOSTNAME}"
echo "INFO - login = ${ARTIFACTORY_LOGIN}"
echo "INFO - gradle repository = ${ARTIFACTORY_GRADLE_REPO}"
echo "INFO - docker repository = ${ARTIFACTORY_DOCKER_REPO}"

#######################
# internal properties #
#######################
if [ "${SAFE_DEPENDENCIES}" = true ] ; then
  echo "INFO - using safe dependencies"
  readonly STRUTS_VERSION='2.5.26'
  readonly BASE_IMAGE_TAG='3.13.0'
  readonly PROJECT_VERSION='1.0.0'
else
  echo "INFO - using unsafe dependencies"
  readonly STRUTS_VERSION='2.0.5'
  readonly BASE_IMAGE_TAG='3.1'
  readonly PROJECT_VERSION='0.0.9'
fi

readonly ARTIFACTORY_URL="https://${ARTIFACTORY_HOSTNAME}/artifactory"
readonly DOCKER_REGISTRY="${ARTIFACTORY_HOSTNAME}/${ARTIFACTORY_DOCKER_REPO}"
readonly IMAGE_NAME='swampup/devsecops'
readonly IMAGE_ABSOLUTE_NAME="${DOCKER_REGISTRY}/${IMAGE_NAME}:${PROJECT_VERSION}"

#################
# build process #
#################
echo "INFO - building java project"
./gradlew clean artifactoryPublish \
    -PprojectVersion="${PROJECT_VERSION}" \
    -PartifactoryUrl="${ARTIFACTORY_URL}" \
    -PartifactoryGradleRepo="${ARTIFACTORY_GRADLE_REPO}" \
    -PartifactoryUser="${ARTIFACTORY_LOGIN}" \
    -PartifactoryApiKey="${ARTIFACTORY_API_KEY}" \
    -PstrutsVersion="${STRUTS_VERSION}"
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "ERROR - issue encountered while building java project"
    exit 2
fi

echo "INFO - login on registry ${DOCKER_REGISTRY}"
docker login -u ${ARTIFACTORY_LOGIN} -p ${ARTIFACTORY_API_KEY} ${DOCKER_REGISTRY}
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "ERROR - issue encountered while logging into docker registry"
    exit 3
fi

echo "INFO - building image ${IMAGE_ABSOLUTE_NAME}"
docker build -t ${IMAGE_ABSOLUTE_NAME} --build-arg "BASE_IMAGE_TAG=${BASE_IMAGE_TAG}" .
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "ERROR - issue encountered while building docker image"
    exit 4
fi

echo "INFO - pushing image ${IMAGE_ABSOLUTE_NAME}"
docker push ${IMAGE_ABSOLUTE_NAME}
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "ERROR - issue encountered while pushing docker image"
    exit 5
fi

echo "INFO - build process terminated successfully"
