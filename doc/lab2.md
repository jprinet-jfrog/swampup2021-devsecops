# Lab 2

## Objective

- Configure JFrog Xray
- [Try to] Download the Docker image created during Lab 1

## Check database synchronization is achieved

## Index resources

- index **devsecops-docker-prod-local** repository 

## Create Xray policy

Create **block-download-on-high-severity** security policy:
- trigger a violation on **high severity** security issue discovered
- **Block Download** and **Block Unscanned** Artifacts as actions

## Create Xray watch

Create **devsecops-docker-repo-watch** watch:
- add **devsecops-docker-prod-local** repository as resource
- add **block-download-on-high-severity** as policy

## Apply on existing content

## Download image

```bash
docker rmi ${IMAGE_ABSOLUTE_NAME_PROD} 2>/dev/null
docker images | grep ${DOCKER_REPO_PROD}
docker pull ${IMAGE_ABSOLUTE_NAME_PROD}
docker images | grep ${DOCKER_REPO_PROD}
```

## Conclusion

Image is blocked by Xray policy.