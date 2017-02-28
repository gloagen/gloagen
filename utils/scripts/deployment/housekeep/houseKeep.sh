#!/bin/sh

spec_file="../properties/release.yml"
backup_spec_directory="../properties/backup/"
current_time=$(date +"%d%m%yT%H%M%S.%N")

backup_last_release_spec() {
  echo "> backing up previous release.yml spec.."
  if [ -e "$spec_file" ]; then
    backup_spec_file="$backup_spec_directory.$current_time.yml"
    echo "> created backup file: $backup_spec_file"
    mv "$spec_file" "$backup_spec_file"

  else
    echo "> $spec_file has not been found.. nothing to backup!"
  fi
}

for arg in "$@"
  do
    if [ -n "$arg" ] && [ "$arg" = "--clean-release-spec" ]; then
      backup_last_release_spec
    fi
  done

