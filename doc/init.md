# General Requirements

Make sure you have: 
- internet access
- Java Development Kit (JDK) 11 or above
- git
- Docker

# Artifactory Configuration Requirements

## Docker registry access method

if not using an Artifactory SaaS instance, set up the [repository path method](https://www.jfrog.com/confluence/display/JFROG/Getting+Started+with+Artifactory+as+a+Docker+Registry#GettingStartedwithArtifactoryasaDockerRegistry-ConfiguringArtifactory.1)

## API Key

Generate an [API Key](https://www.jfrog.com/confluence/display/JFROG/User+Profile#UserProfile-APIKey) for your Artifactory user

Copy it to the clipboard

# Artifactory Data Requirements

Move into the scripts folder:
```bash
cd scripts
```

## Environment

copy build.env.template to build.env and set values accordingly:

```bash
ARTIFACTORY_HOSTNAME='my-instance.jfrog.io'
ARTIFACTORY_LOGIN='foo@bar.com'
ARTIFACTORY_API_KEY='MY_KEY'
```

## Set dynamic properties

```bash
source ./build.env
```

## Set static properties

```bash
ARTIFACTORY_URL="https://${ARTIFACTORY_HOSTNAME}/artifactory"
CLI_INSTANCE_ID='my-instance'
```

## Download JFrog CLI

```bash
curl -fL https://getcli.jfrog.io | sh
```

## Configure JFrog CLI

```bash
./jfrog config remove "${CLI_INSTANCE_ID}" --quiet
./jfrog config add "${CLI_INSTANCE_ID}" --artifactory-url="${ARTIFACTORY_URL}" --user="${ARTIFACTORY_LOGIN}" --apikey="${ARTIFACTORY_API_KEY}" --interactive=false
```

## Delete old repositories

```bash
./jfrog rt repo-delete devsecops-docker-dev-local --quiet --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-delete devsecops-docker-prod-local --quiet --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-delete devsecops-docker-remote --quiet --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-delete devsecops-docker-dev --quiet --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-delete devsecops-docker-prod --quiet --server-id="${CLI_INSTANCE_ID}"

./jfrog rt repo-delete devsecops-gradle-dev-local --quiet --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-delete devsecops-gradle-prod-local --quiet --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-delete devsecops-gradle-remote --quiet --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-delete devsecops-gradle-dev --quiet --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-delete devsecops-gradle-prod --quiet --server-id="${CLI_INSTANCE_ID}"
```

## Create repositories

```bash
./jfrog rt repo-create template-create-repo.json --vars "repo-name=devsecops-docker-dev-local;repo-type=local;tech=docker" --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-create template-create-repo.json --vars "repo-name=devsecops-docker-prod-local;repo-type=local;tech=docker" --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-create template-create-repo.json --vars "repo-name=devsecops-docker-remote;repo-type=remote;tech=docker;url=https://registry-1.docker.io/" --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-create template-create-repo.json --vars "repo-name=devsecops-docker-dev;repo-type=virtual;tech=docker;repositories=devsecops-docker-remote,devsecops-docker-dev-local;default=devsecops-docker-dev-local" --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-create template-create-repo.json --vars "repo-name=devsecops-docker-prod;repo-type=virtual;tech=docker;repositories=devsecops-docker-remote,devsecops-docker-prod-local;default=devsecops-docker-prod-local" --server-id="${CLI_INSTANCE_ID}"

./jfrog rt repo-create template-create-repo.json --vars "repo-name=devsecops-gradle-dev-local;repo-type=local;tech=gradle" --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-create template-create-repo.json --vars "repo-name=devsecops-gradle-prod-local;repo-type=local;tech=gradle" --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-create template-create-repo.json --vars "repo-name=devsecops-gradle-remote;repo-type=remote;tech=gradle;url=https://jcenter.bintray.com" --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-create template-create-repo.json --vars "repo-name=devsecops-gradle-dev;repo-type=virtual;tech=gradle;repositories=devsecops-gradle-remote,devsecops-gradle-dev-local;default=devsecops-gradle-dev-local" --server-id="${CLI_INSTANCE_ID}"
./jfrog rt repo-create template-create-repo.json --vars "repo-name=devsecops-gradle-prod;repo-type=virtual;tech=gradle;repositories=devsecops-gradle-remote,devsecops-gradle-prod-local;default=devsecops-gradle-prod-local" --server-id="${CLI_INSTANCE_ID}"
```

