ARG BASE_IMAGE_TAG=latest
FROM alpine:${BASE_IMAGE_TAG}
LABEL maintainer="jeromep@jfrog.com" description="image shipping java archive"

USER foo:bar

# adding maven archive
ADD build/distributions/*.tar dist
