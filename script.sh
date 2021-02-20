#!/bin/bash

# If --script is set, print the commands to be run rather than interacting
if [[ "${1}" == "--script" ]]; then
  SCRIPT=true
fi

function pretend {
  cmd="${1}"
  output="${2}"

  if [[ "${SCRIPT}" == "true" ]]; then
    if [[ -n "${cmd}" ]]; then
      echo "${cmd}"
    fi
    return
  fi
  if [[ -z "${cmd}" ]]; then
    if [[ -n "${output}" ]]; then
      echo "${output}"
    fi
    return
  fi

  if [[ "${cmd}" != "y" ]]; then
    echo -en "\e[1;32mmjs@mjs-XPS-15-9550\e[0;1m \u00bb\e[0m "
  fi
  i=0
  stty -echo raw
  while true; do
    c="$(dd bs=1 count=1 2>/dev/null)"
    if [[ "${c}" == $'\003' ]] || [[ "${c}" == $'\004' ]]; then # \003/4 = ^C/^D
      exit 1
    fi
    if [[ "${c}" == $'\r' ]]; then
      echo
      break
    fi
    if [[ "${i}" -lt "${#cmd}" ]]; then
      printf "${cmd:i:1}"
      i="$((i+1))"
    fi
  done
  stty echo cooked
  echo -e "\e[G${output#$'\n'}"
}

pretend "pachctl list repo" "
NAME  CREATED       SIZE (MASTER) DESCRIPTION
input 7 minutes ago 74B"
pretend "pachctl list file input@master:/" "
NAME         TYPE SIZE
/datum1.json file 37B
/datum2.json file 37B"
pretend "cat pipeline.yaml" "$(cat pipeline.yaml)"

pretend "pachctl preview -f pipeline.yaml"
pretend "" "**No datum selected, choosing \"/datum1.json\"**"$'\n'
pretend "" "Starting preview container..."
pretend "" $'\n'"New git repo registered: github.com/msteffen/test-pipeline"
pretend "" $'\n'"*** Please grant the following ssh public key access to your repo ***"
pretend "" "$(cat ssh/id_rsa.pub)"
pretend "" "************************************************************************"$'\n'

[[ "${SCRIPT}" != "true" ]] && sleep 4
pretend "" "Starting port-forward. If connection is dropped, restart port-forward with:"
pretend "" "  kubectl port-forward preview-pipeline-example-56b11 30022:22 30888:8888 &"
[[ "${SCRIPT}" != "true" ]] && sleep 1
# Design note: this will only work for github pipelines, because the standard
# python container has this user in it. Alternatively, if we try to inject sshd
# into the container, we could configure it to allow root login?
pretend "" "
Run the following command for ssh access:
  ssh ssh://user@localhost:30222
Access Jupyter at:
  http://localhost:30888"

pretend "pachctl create pipeline -f pipeline.yaml"
pretend "pachctl list pipeline" "
NAME    VERSION INPUT     CREATED       STATE / LAST JOB   DESCRIPTION
example 1       images:/* 6 seconds ago running / starting"
pretend "pachctl flush commit input@master" "
REPO    BRANCH COMMIT                           FINISHED       SIZE     PROGRESS DESCRIPTION
example master b950a7a616ad401baafe8a5b3c37cedd 10 seconds ago 22.22KiB -"
pretend "pachctl list job" "
ID                               PIPELINE STARTED        DURATION RESTART PROGRESS  DL       UL       STATE
08091563844547548bff33d171ed3b2b example  39 seconds ago 1 second 0       1 + 0 / 1 57.27KiB 22.22KiB success"

pretend "pachctl preview -f pipeline2.yaml"
pretend "" "**No datum selected, choosing \"/datum1.json\"**"$'\n'
pretend "" "Starting preview container..."
[[ "${SCRIPT}" != "true" ]] && sleep 4
pretend "" "Starting port-forward. If connection is dropped, restart port-forward with:"
pretend "" "  kubectl port-forward preview-pipeline-example-56b11 30022:22 30888:8888 &"
[[ "${SCRIPT}" != "true" ]] && sleep 1
# Design note: this will only work for github pipelines, because the standard
# python container has this user in it. Alternatively, if we try to inject sshd
# into the container, we could configure it to allow root login?
pretend "" "
Run the following command for ssh access:
  ssh ssh://user@localhost:30222
Access Jupyter at:
  http://localhost:30888"

pretend "pachctl create pipeline -f pipeline2.yaml"
pretend "pachctl list pipeline" "
NAME        VERSION INPUT     CREATED       STATE / LAST JOB   DESCRIPTION
example     1       images:/* 6 seconds ago running / starting
example-exp 1       images:/* 6 seconds ago running / starting"
pretend "pachctl flush commit input@master" "
REPO    BRANCH COMMIT                           FINISHED       SIZE     PROGRESS DESCRIPTION
example master 1234abd9870980123984029481208430 7 seconds ago 22.22KiB -"
pretend "pachctl list job" "
ID                               PIPELINE    STARTED        DURATION RESTART PROGRESS  DL       UL       STATE
08091563844547548bff33d171ed3b2b example     39 seconds ago 1 second 0       1 + 0 / 1 57.27KiB 22.22KiB success
08091563844547548bff33d171ed3b2b example-exp 11 seconds ago 1 second 0       1 + 0 / 1 57.27KiB 22.22KiB success"
