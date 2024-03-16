#!/bin/bash

flux bootstrap git \
  --url=ssh://git@gitlab.robochris.net/devops/devops-k8s-toolkit.git \
  --private-key-file=/home/$USER/.ssh/flux-bot \
  --branch=main \
  --path=./flux/clusters/production
