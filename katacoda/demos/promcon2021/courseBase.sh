#!/usr/bin/env bash

# TODO(bwplotka): We can move start script here for auto-start. Don't start here yet during dev cycle, because we can't be able to see logs.
# We also don't want to fix index.json and allow-list all files required for so we directly clone repo as first step.
# YOLO!

git clone git@github.com:bwplotka/observe-argo-rollout.git -b demo

# Start k8s.
launch.sh