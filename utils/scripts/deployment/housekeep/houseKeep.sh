#!/bin/sh

backup_last_release_spec() {
  echo "> backing up previous release.yml spec.."
  current_spec_file = "../properties/release.yml"
  if [ -e "$current_spec_file" ]; then
    current_time = $(date + %d%m%y%H%M%S%N)
    backup_spec_file = "../properties/release.backup.$current_time.yml"
    mv "$current_spec_file" "$backup_spec_file"

  else
    echo "$current_spec_file has not been found.. nothing to backup!"
  fi
}

for arg in "$@"
  do
    if [ -n "$arg" ] && [ "$arg" = "--clean-release-spec" ]; then
      backup_last_release_spec
    fi
  done

