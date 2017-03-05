#!/bin/bash

if [ -n "$DEPLOY_PROPERTIES_HOME" ]; then
  exit 104 # environment variable is not specified
fi

spec_file="$DEPLOY_PROPERTIES_HOME/release.yml"
backup_spec_directory="$DEPLOY_PROPERTIES_HOME/backup"
current_time=$(date +"%d%m%yT%H%M%S.%N")

backup_last_release_spec() {
  echo "> backing up previous release.yml spec.." >> log.out
  mkdir -p ${backup_spec_directory}

  if [ -e "$spec_file" ]; then
    backup_spec_file="$backup_spec_directory/release.backup.$current_time.yml"
    echo "> created backup file: $backup_spec_file"
    mv "$spec_file" "$backup_spec_file"

  else
    echo "> $spec_file has not been found.. nothing to backup!" >> log.out
  fi
}

for arg in "$@"
  do
    if [ -n "$arg" ] && [ "$arg" = "--clean-release-spec" ]; then
      backup_last_release_spec
    fi
  done

