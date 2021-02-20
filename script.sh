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

pretend "pachctl preview -f pipeline.json"
echo -n "Copy ssh keys into preview container? y/N "
pretend "y"
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

stty echo cooked
