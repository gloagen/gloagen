#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cp properties-env.sh /etc/profile.d/ # set the environment variables
sh properties-env.sh                 # force load environment variables
cd "$parent_path"
./housekeep/housekeep.sh --clean-release-spec # backup previous release spec
