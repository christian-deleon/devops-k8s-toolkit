#!/bin/bash

flux bootstrap gitlab \
  --hostname=https://gitlab.robochris.net \
  --owner=devops \
  --repository=devops-k8s-demo \
  --branch=main \
  --path=./clusters/development \
  --token-auth \
  --personal
