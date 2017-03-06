#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"
sudo chmod ug+x deploy-properties-env.sh
sudo chmod ug+x *.sh
sudo chmod ug+x install/*.py
sudo chown gloag -R install/
cp deploy-properties-env.sh /etc/profile.d/ # set the environment variables
sh deploy-properties-env.sh                 # force load environment variables
./init-app-data.sh --prepare-directories # backup previous release spec
