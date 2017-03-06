#!/bin/bash
#current_time=$(date +"%d%m%yT%H%M%S.%N")

log(){
   echo "$1" >> "$GLOAG_DEPLOY_LOGS_HOME/deploy.log"
}

validate_environment_variables(){
   if [ -n "$GLOAG_DEPLOY_HOME" ]; then
      exit 104 # environment variable is not specified
   fi

   if [ ! -d "$GLOAG_DEPLOY_PROPERTIES_HOME/backup" ]; then
      mkdir -p "$GLOAG_DEPLOY_PROPERTIES_HOME/backup"
   fi

   if [ ! -d "$GLOAG_DEPLOY_RELEASE_PROPERTIES_HOME" ]; then
      mkdir -p "$GLOAG_DEPLOY_RELEASE_PROPERTIES_HOME"
   fi

   if [ ! -d "$GLOAG_DEPLOY_LOGS_HOME" ]; then
      mkdir -p "$GLOAG_DEPLOY_LOGS_HOME"
   fi
}

clean_all_properties_dir(){
    rm -rf "$GLOAG_DEPLOY_RELEASE_PROPERTIES_HOME/*.*"
    rm -rf "$GLOAG_DEPLOY_PROPERTIES_HOME/*.*"
}

copy_properties_to_app_dir(){
    cp -TR ../properties/ "$GLOAG_DEPLOY_HOME/properties/"
    cp -TR ../release/ "$GLOAG_DEPLOY_HOME/release/"
}

set_permissions(){
    sudo chmod -R ug+rw "$GLOAG_DEPLOY_HOME/*.*"
    sudo chown gloag -R "$GLOAG_DEPLOY_HOME"
}

prepare_deploy_dir() {
   work_dir=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
   cd work_dir
   log "> current working directory: $work_dir"
   validate_environment_variables
   clean_all_properties_dir
   copy_properties_to_app_dir
   set_permissions
}

for arg in "$@"
  do
    if [ -n "$arg" ] && [ "$arg" = "--prepare-directories" ]; then
      prepare_deploy_dir
    fi
  done

