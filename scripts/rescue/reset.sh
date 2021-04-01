#!/usr/bin/env bash

################################
# Sourcing external properties #
################################
readonly BUILD_ENV_FILE=../build.env
if [ ! -f "${BUILD_ENV_FILE}" ]; then
    echo "ERROR - could not find ${BUILD_ENV_FILE}"
    exit 1
fi

source "${BUILD_ENV_FILE}"

echo "INFO - artifactory = ${ARTIFACTORY_HOSTNAME}"
echo "INFO - login = ${ARTIFACTORY_LOGIN}"

#######################
# internal properties #
#######################
readonly CLI_INSTANCE_ID='my-instance'
readonly CLI_GRADLE_BUILD_NAME='devsecops-gradle'
readonly CLI_DOCKER_BUILD_NAME='devsecops-docker'
readonly ARTIFACTORY_URL="https://${ARTIFACTORY_HOSTNAME}/artifactory"
readonly XRAY_URL="https://${ARTIFACTORY_HOSTNAME}/xray"

#################
# reset process #
#################
echo "INFO - deleting repos"
../jfrog rt repo-delete devsecops-docker-dev-local --quiet --server-id="${CLI_INSTANCE_ID}"
../jfrog rt repo-delete devsecops-docker-prod-local --quiet --server-id="${CLI_INSTANCE_ID}"
../jfrog rt repo-delete devsecops-docker-remote --quiet --server-id="${CLI_INSTANCE_ID}"
../jfrog rt repo-delete devsecops-docker-dev --quiet --server-id="${CLI_INSTANCE_ID}"
../jfrog rt repo-delete devsecops-docker-prod --quiet --server-id="${CLI_INSTANCE_ID}"
../jfrog rt repo-delete devsecops-gradle-dev-local --quiet --server-id="${CLI_INSTANCE_ID}"
../jfrog rt repo-delete devsecops-gradle-prod-local --quiet --server-id="${CLI_INSTANCE_ID}"
../jfrog rt repo-delete devsecops-gradle-remote --quiet --server-id="${CLI_INSTANCE_ID}"
../jfrog rt repo-delete devsecops-gradle-dev --quiet --server-id="${CLI_INSTANCE_ID}"
../jfrog rt repo-delete devsecops-gradle-prod --quiet --server-id="${CLI_INSTANCE_ID}"

echo "INFO - deleting builds"
curl -H "X-JFrog-Art-Api: ${ARTIFACTORY_API_KEY}" \
     -H 'Content-Type: application/json' \
     -X POST "${ARTIFACTORY_URL}/api/build/delete" \
     -d "{\"buildName\":\"${CLI_GRADLE_BUILD_NAME}\",\"deleteAll\":\"true\"}"
curl -H "X-JFrog-Art-Api: ${ARTIFACTORY_API_KEY}" \
     -H 'Content-Type: application/json' \
     -X POST "${ARTIFACTORY_URL}/api/build/delete" \
     -d "{\"buildName\":\"${CLI_DOCKER_BUILD_NAME}\",\"deleteAll\":\"true\"}"

echo "INFO - deleting watches"
curl -u "${ARTIFACTORY_LOGIN}:${ARTIFACTORY_API_KEY}" \
     -X DELETE "${XRAY_URL}/api/v2/watches/devsecops-docker-repo-watch"
curl -u "${ARTIFACTORY_LOGIN}:${ARTIFACTORY_API_KEY}" \
     -X DELETE "${XRAY_URL}/api/v2/watches/devsecops-docker-build-watch"

echo "INFO - deleting policies"
curl -u "${ARTIFACTORY_LOGIN}:${ARTIFACTORY_API_KEY}" \
     -H 'Content-Type: application/json' \
     -X DELETE "${XRAY_URL}/api/v2/policies/block-download-on-high-severity"
curl -u "${ARTIFACTORY_LOGIN}:${ARTIFACTORY_API_KEY}" \
     -H 'Content-Type: application/json' \
     -X DELETE "${XRAY_URL}/api/v2/policies/fail-build-on-high-severity"

echo "INFO - removing CLI configuration"
../jfrog config remove "${CLI_INSTANCE_ID}" --quiet

echo "INFO - clean local docker registry"
docker rmi ${ARTIFACTORY_HOSTNAME}/devsecops-docker-prod/alpine:3.1 2>/dev/null
docker rmi ${ARTIFACTORY_HOSTNAME}/devsecops-docker-prod/alpine:3.13.0 2>/dev/null
docker rmi ${ARTIFACTORY_HOSTNAME}/devsecops-docker-dev/swampup/devsecops:0.0.9 2>/dev/null
docker rmi ${ARTIFACTORY_HOSTNAME}/devsecops-docker-dev/swampup/devsecops:0.0.10 2>/dev/null
docker rmi ${ARTIFACTORY_HOSTNAME}/devsecops-docker-dev/swampup/devsecops:1.0.0 2>/dev/null
docker rmi ${ARTIFACTORY_HOSTNAME}/devsecops-docker-prod/swampup/devsecops:0.0.9 2>/dev/null
docker rmi ${ARTIFACTORY_HOSTNAME}/devsecops-docker-prod/swampup/devsecops:0.0.10 2>/dev/null
docker rmi ${ARTIFACTORY_HOSTNAME}/devsecops-docker-prod/swampup/devsecops:1.0.0 2>/dev/null
