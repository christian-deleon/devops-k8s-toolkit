#!/bin/bash

flux bootstrap git \
  --url=ssh://git@gitlab.robochris.net/devops/devops-k8s-demo.git \
  --private-key-file=/home/$USER/.ssh/flux-bot \
  --branch=develop \
  --path=./clusters/development
