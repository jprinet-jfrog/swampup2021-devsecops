# Lab 2

## Objective

- Configure JFrog Xray
- [Try to] Download the Docker image created during Lab 1

## Check database synchronization is achieved

## Index resources

- Index **devsecops-docker-prod-local** repository 
- Expedite the indexing progress using the Index Now feature.

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

Remove local image:
```bash
docker rmi ${IMAGE_ABSOLUTE_NAME_PROD} 2>/dev/null
```

Try to pull image from Artifactory:
```bash
docker pull ${IMAGE_ABSOLUTE_NAME_PROD}
```

## Conclusion

Image is blocked by Xray policy.