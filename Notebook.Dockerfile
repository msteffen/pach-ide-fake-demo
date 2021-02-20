FROM jupyter/minimal-notebook@sha256:19d6b2d0fde7305d400dc0b1ce422d7200c37b0bc6e81b7f5b1063c2c9d458ba

LABEL author=msteffen@pachyderm.io

# Must be 'root' to run apt (whyyyy), change ssh permissions, and modify '/'
USER root
RUN sudo apt-get update -y && \
  sudo apt-get install -y git ssh
# Add SSH key
ADD ssh /home/jovyan/.ssh
# Create /pfs/* and update perms (and ~/.ssh perms)
RUN \
  mkdir /pfs \
  && mkdir /pfs/input \
  && mkdir /pfs/source \
  && mkdir /pfs/build \
  && mkdir /pfs/out \
  && chown -R jovyan:users /pfs \
  && chown -R jovyan:users /home/jovyan/.ssh

# Create dirs as the user that will be running the notebooks
USER jovyan
ADD jupyter_notebook_config.py /home/jovyan/.jupyter/jupyter_notebook_config.py
ADD test_datums/datum1.json /pfs/input
RUN rmdir /home/jovyan/work
RUN git clone git@github.com:msteffen/pach-git-demo.git /pfs/source
