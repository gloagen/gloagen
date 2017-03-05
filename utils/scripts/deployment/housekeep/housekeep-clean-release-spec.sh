#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $parent_path
./properties-env.sh # set the environment variables
./housekeep.sh --clean-release-spec # backup previous release spec
