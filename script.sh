#!/bin/bash

function pretend {
  msg="${1}"
  output="${2}"

  echo -en "\e[1;32mmjs@mjs-XPS-15-9550\e[0;1m \u00bb\e[0m "
  i=0
  while true; do
    stty -echo raw
    c="$(dd bs=1 count=1 2>/dev/null)"
    stty echo cooked
    if [[ "${c}" == $'\003' ]] || [[ "${c}" == $'\004' ]]; then # \003/4 = ^C/^D
      stty echo cooked
      exit 1
    fi
    if [[ "${c}" == $'\r' ]]; then
      echo
      break
    fi
    if [[ i -lt "${#msg}" ]]; then
      printf "${msg:i:1}"
      i="$((i+1))"
    fi
  done
  echo -n "${2}"
}

pretend "pachctl list repo" "\
NAME  CREATED       SIZE (MASTER) DESCRIPTION
input 7 minutes ago 74B
"
pretend "pachctl list file input@master:/" "\
NAME         TYPE SIZE
/datum1.json file 37B
/datum2.json file 37B
"
pretend "cat pipeline.yaml" "\
pipeline:
  name: example
description: An example github pipeline
input:
  pfs:
    glob: /*
    repo: input
transform:
  # - Like build pipelines, but files come from github
  # - Pipeline is updated when branch is updated
  # - Default branch is "master", but can specify others
  git:      github.com/msteffen/test-pipeline
  language: python
"

pretend "pachctl preview -f pipeline.json"
echo -n "Copy ssh keys into preview container? y/N "
pretend "y"
echo Starting preview container...
sleep 4
echo "Starting port-forward. If connection is dropped, restart port-forward with:"
echo "  kubectl port-forward preview-pipeline-example-56b11 30022:22 30888:8888 & "
sleep 1
# Design note: this will only work for github pipelines, because the standard
# python container has this user in it. Alternatively, if we try to inject sshd
# into the container, we could configure it to allow root login?
cat <<EOF
Run the following command for ssh access:
  ssh ssh://user@localhost:30222
Access Jupyter at:
  http://localhost:30888
EOF

stty echo cooked
