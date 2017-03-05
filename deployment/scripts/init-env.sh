#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"
sudo chmod ug+x properties-env.sh
sudo chmod ug+x housekeep/*.sh
sudo chmod ug+x install/*.py
sudo chown gloag -R install/
cp properties-env.sh /etc/profile.d/ # set the environment variables
sh properties-env.sh                 # force load environment variables
./housekeep/housekeep.sh --clean-release-spec # backup previous release spec
