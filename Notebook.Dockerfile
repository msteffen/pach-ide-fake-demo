FROM jupyter/minimal-notebook@sha256:19d6b2d0fde7305d400dc0b1ce422d7200c37b0bc6e81b7f5b1063c2c9d458ba

LABEL author=msteffen@pachyderm.io

USER root

RUN sudo apt-get update -y && \
  sudo apt-get install -y git
