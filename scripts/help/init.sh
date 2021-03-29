#!/usr/bin/env bash

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

#######################
# internal properties #
#######################
readonly CLI_INSTANCE_ID='my-instance'
readonly ARTIFACTORY_URL="https://${ARTIFACTORY_HOSTNAME}/artifactory"
readonly REPO_PREFIX='devsecops'

################
# download CLI #
################
if [ ! -f "./jfrog" ]; then
  echo "INFO - downloading JFrog CLI"
  curl -fL https://getcli.jfrog.io | sh
  retVal=$?
  if [ $retVal -ne 0 ]; then
      echo "ERROR - issue encountered while downloading JFrog CLI"
      exit 2
  fi
fi

#################
# init process #
#################

echo "INFO - initial cleanup"
./jfrog config remove "${CLI_INSTANCE_ID}" --quiet

echo "INFO - configuring instance"
./jfrog config add "${CLI_INSTANCE_ID}" --artifactory-url="${ARTIFACTORY_URL}" --user="${ARTIFACTORY_LOGIN}" --apikey="${ARTIFACTORY_API_KEY}" --interactive=false
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "ERROR - issue encountered while configuring instance"
    exit 3
fi

echo "INFO - deleting repos"
./jfrog rt repo-delete ${REPO_PREFIX}-docker-dev-local --quiet --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-delete ${REPO_PREFIX}-docker-prod-local --quiet --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-delete ${REPO_PREFIX}-docker-remote --quiet --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-delete ${REPO_PREFIX}-docker-dev --quiet --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-delete ${REPO_PREFIX}-docker-prod --quiet --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-delete ${REPO_PREFIX}-gradle-dev-local --quiet --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-delete ${REPO_PREFIX}-gradle-prod-local --quiet --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-delete ${REPO_PREFIX}-gradle-remote --quiet --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-delete ${REPO_PREFIX}-gradle-dev --quiet --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-delete ${REPO_PREFIX}-gradle-prod --quiet --server-id="${CLI_INSTANCE_ID}"

echo "INFO - creating repos"
./jfrog rt repo-create template-create-repo.json --vars "repo-name=${REPO_PREFIX}-docker-dev-local;repo-type=local;tech=docker" --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-create template-create-repo.json --vars "repo-name=${REPO_PREFIX}-docker-prod-local;repo-type=local;tech=docker" --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-create template-create-repo.json --vars "repo-name=${REPO_PREFIX}-docker-remote;repo-type=remote;tech=docker;url=https://registry-1.docker.io/" --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-create template-create-repo.json --vars "repo-name=${REPO_PREFIX}-docker-dev;repo-type=virtual;tech=docker;repositories=${REPO_PREFIX}-docker-remote,${REPO_PREFIX}-docker-dev-local;default=${REPO_PREFIX}-docker-dev-local" --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-create template-create-repo.json --vars "repo-name=${REPO_PREFIX}-docker-prod;repo-type=virtual;tech=docker;repositories=${REPO_PREFIX}-docker-remote,${REPO_PREFIX}-docker-prod-local;default=${REPO_PREFIX}-docker-prod-local" --server-id="${CLI_INSTANCE_ID}"

./jfrog rt repo-create template-create-repo.json --vars "repo-name=${REPO_PREFIX}-gradle-dev-local;repo-type=local;tech=gradle" --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-create template-create-repo.json --vars "repo-name=${REPO_PREFIX}-gradle-prod-local;repo-type=local;tech=gradle" --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-create template-create-repo.json --vars "repo-name=${REPO_PREFIX}-gradle-remote;repo-type=remote;tech=gradle;url=https://jcenter.bintray.com" --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-create template-create-repo.json --vars "repo-name=${REPO_PREFIX}-gradle-dev;repo-type=virtual;tech=gradle;repositories=${REPO_PREFIX}-gradle-remote,${REPO_PREFIX}-gradle-dev-local;default=${REPO_PREFIX}-gradle-dev-local" --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-create template-create-repo.json --vars "repo-name=${REPO_PREFIX}-gradle-prod;repo-type=virtual;tech=gradle;repositories=${REPO_PREFIX}-gradle-remote,${REPO_PREFIX}-gradle-prod-local;default=${REPO_PREFIX}-gradle-prod-local" --server-id="${CLI_INSTANCE_ID}"
