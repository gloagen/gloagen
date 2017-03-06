#!/bin/bash
current_time=$(date +"%d%m%yT%H%M%S.%N")

log(){
   echo "$1" >> "$GLOAG_DEPLOY_LOGS_HOME/deploy-$current_time.log"
}

init_directories(){
    if [ -n "$1" ]; then
        exit 104 # environment variable is not specified
    elif [ ! -d "$1" ]; then
        mkdir -p "$1"
    else
        rm -rf "$1/*.*"
    fi
}

copy_properties_to_app_dir(){
    log "> copying files from ../properties/ to $GLOAG_DEPLOY_HOME/properties/"
    cp -TR ../properties/ "$GLOAG_DEPLOY_HOME/properties/"

    log "> copying files from ../release/ to $GLOAG_DEPLOY_HOME/release/"
    cp -TR ../release/ "$GLOAG_DEPLOY_HOME/release/"
}

prepare_deploy_dir() {
    if [ -n "$GLOAG_DEPLOY_HOME" ] && [ -n "$GLOAG_DEPLOY_LOGS_HOME" ]; then
        exit 104 # environment variable is not specified
    fi

    work_dir=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
    cd "$work_dir"
    log "> current working directory: $work_dir"

    init_directories "$GLOAG_DEPLOY_RELEASE_PROPERTIES_HOME"
    init_directories "$GLOAG_DEPLOY_PROPERTIES_HOME"

    copy_properties_to_app_dir

    sudo chmod -R ug+rw "$GLOAG_DEPLOY_HOME/*.*"
    sudo chown gloag -R "$GLOAG_DEPLOY_HOME"
}

for arg in "$@"
  do
    if [ -n "$arg" ] && [ "$arg" = "--prepare-directories" ]; then
      prepare_deploy_dir
    fi
  done

