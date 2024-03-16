#!/bin/bash

flux bootstrap git \
  --url=ssh://git@gitlab.com/devops9483002/devops-k8s-toolkit.git \
  --private-key-file=/home/$USER/.ssh/flux-bot \
  --branch=main \
  --path=./flux/clusters/production \
  --context devops-toolkit
