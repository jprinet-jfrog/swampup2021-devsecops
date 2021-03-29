ARG BASE_IMAGE=foo
FROM ${BASE_IMAGE}
LABEL maintainer="jeromep@jfrog.com" description="image shipping java archive"

USER foo:bar

# adding maven archive
ADD build/distributions/*.tar dist
