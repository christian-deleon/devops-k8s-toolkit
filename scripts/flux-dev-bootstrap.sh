#!/bin/bash

flux bootstrap git \
  --url=ssh://git@gitlab.com/devops9483002/devops-k8s-toolkit.git \
  --private-key-file=/home/$USER/.ssh/flux-bot \
  --branch=develop \
  --path=./flux/clusters/development \
  --context devops-toolkit
