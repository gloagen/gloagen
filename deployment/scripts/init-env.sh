#!/bin/bash

set_env(){
    export GLOAG_DEPLOY_HOME=/opt/codedeploy-agent/deployment-root/gloagen-app
    export GLOAG_DEPLOY_LGLOAG_DEPLOY_HOMEOGS_HOME=$GLOAG_DEPLOY_HOME/logs
    export GLOAG_WEBAPPS_HOME=/opt/server/tomcat/webapps
    export GLOAG_DEPLOY_PROPERTIES_HOME=$GLOAG_DEPLOY_HOME/properties
    export GLOAG_DEPLOY_RELEASE_HOME=$GLOAG_DEPLOY_HOME/release/userservice
    export GLOAG_DEPLOY_RELEASE_PROPERTIES_HOME=$GLOAG_DEPLOY_RELEASE_HOME/properties
    export GLOAG_DEPLOY_DOWNLOADS_HOME=$GLOAG_DEPLOY_HOME/downloads
}

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"
sudo chmod ug+x deploy-properties-env.sh
sudo chmod ug+x *.sh
sudo chmod ug+x install/*.py
sudo chown gloag -R install/
cp deploy-properties-env.sh /etc/profile.d/ # set the environment variables
sh deploy-properties-env.sh                 # force load environment variables
./init-app-data.sh --prepare-directories # backup previous release spec
