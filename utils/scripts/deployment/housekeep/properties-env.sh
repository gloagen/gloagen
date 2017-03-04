#!/bin/bash

export DEPLOY_HOME=/opt/codedeploy-agent/deployment-root
export DEPLOY_PROPERTIES_HOME=$DEPLOY_HOME/properties
export PATH=$PATH:$DEPLOY_HOME:$DEPLOY_PROPERTIES_HOME