#!/bin/sh
current_time=$(date +"%d%m%yT%H%M%S.%N")
work_dir=`dirname $0`
cd "$work_dir"

sudo chmod ug+x *.sh
sudo chmod ug+x install/*.py
sudo chown gloag -R install/

cp deploy-properties-env.sh /etc/profile.d/ # set the environment variables
. deploy-properties-env.sh

log(){
   echo "$1" >> "${GLOAG_DEPLOY_LOGS_HOME}/deploy-$current_time.log"
}

init_directories(){
    if [ -n "$1" ]; then
        exit 104 # environment variable is not specified
    elif [ ! -d "$1" ]; then
        mkdir -p "$1"
    else
        log "> attempting to delete: '$1'"
        rm -rf "$1/*.raphael"
    fi
}

copy_properties_to_app_dir(){
    log "> copying files from ../properties/ to ${GLOAG_DEPLOY_PROPERTIES_HOME}"
    cp -TR ../properties/ "${GLOAG_DEPLOY_PROPERTIES_HOME}"

    log "> copying files from ../release/ to ${GLOAG_DEPLOY_RELEASE_HOME}"
    cp -TR ../release/ "${GLOAG_DEPLOY_RELEASE_HOME}"
}

prepare_deploy_dir() {
    if [ "$GLOAG_DEPLOY_HOME" == "" ] || [ ! "$GLOAG_DEPLOY_LOGS_HOME" ]; then
        exit 104 # environment variable is not specified
    fi

    log "> current working directory: $work_dir"

    init_directories "${GLOAG_DEPLOY_RELEASE_PROPERTIES_HOME}"
    init_directories "${GLOAG_DEPLOY_PROPERTIES_HOME}"

    copy_properties_to_app_dir

    log "> attempting to set permissions for GLOAG_DEPLOY_HOME path: ${GLOAG_DEPLOY_HOME}/*.*"
    #sudo chmod -R ug+rw "$GLOAG_DEPLOY_HOME/*.*"
    #sudo chown gloag -R "$GLOAG_DEPLOY_HOME"
}
: <<'END'
for arg in "$@"
  do
    if [ -n "$arg" ] && [ "$arg" = "--prepare-directories" ]; then
      prepare_deploy_dir
    fi
  done
END




prepare_deploy_dir