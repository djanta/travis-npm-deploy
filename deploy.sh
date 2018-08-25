#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# deploy.sh - This script will be use to perform travis-ci npm script based deploy

# Copyright 2018, Stanislas Koffi ASSOUTOVI "Fonder of DJANTA, LLC and djantajs creator" <team.dev@djanta.io>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License at <http://www.gnu.org/licenses/> for more details.
# ---------------------------------------------------------------------------

set -e # exit with nonzero exit code if anything fails

argv0=$(echo "$0" | sed -e 's,\\,/,g')
basedir=$(dirname "$(readlink "$0" || echo "$argv0")")

case "$(uname -s)" in
  Linux) basedir=$(dirname "$(readlink -f "$0" || echo "$argv0")");;
  *CYGWIN*) basedir=`cygpath -w "$basedir"`;;
esac

echo "Current script dir = $basedir"

PROGNAME=${0##*/}
V_REGEX='^(v[0-9]+\.){0,2}(\*|[0-9]+)$'
LOCK_FILE='~/.npm-lock'

#Copied from: https://github.com/fsaintjacques/semver-tool/blob/master/src/semver
SEMVER_REGEX="^v(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)(\\-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"

DESCRIBE=`git describe --tags --always`

############################# PRIVATE FUNCTIONS #############################

_clean () { # Perform pre-exit housekeeping
  return
}

_error_exit () {
  echo -e "${PROGNAME}: ${1:-"Unknown Error"}" >&2
  _clean
  exit 1
}

_graceful_exit () {
  _clean
  exit
}

_signal_exit () { # Handle trapped signals
  case $1 in
    INT)
      _error_exit "Program interrupted by user" ;;
    TERM)
      echo -e "\n$PROGNAME: Program terminated" >&2
      _graceful_exit ;;
    *)
      _error_exit "$PROGNAME: Terminating on unknown signal" ;;
  esac
}

_witch () {
  _witch "$1"
}

_isSu () {
  if [[ $(id -u) != 0 ]]; then
    _error_exit "You must be the superuser to run this script."
  fi
}

############################# PUBLIC FUNCTIONS #############################

apt_install () {
  if ! which expect > /dev/null; then
    sudo apt-get update
    sudo apt-get install \
      expect -y
  fi
}

##
# DEFINE TRAVIS GIT CONFIGURATION
##
git_confg () {
  [ -n "${DEFINED_GIT_EMAIL##+([[:space:]])}" ] && GH_USER_EMAIL="$DEFINED_GIT_EMAIL" || GH_USER_EMAIL="$GH_USER_EMAIL"
  [ -n "${DEFINED_GIT_USER##+([[:space:]])}" ] && GH_USER="$DEFINED_GIT_USER" || GH_USER="$GH_USER"
  [ -n "${DEFINED_GIT_TOKEN##+([[:space:]])}" ] && GH_TOKEN="$DEFINED_GIT_TOKEN" || GH_TOKEN="$GH_TOKEN"

  git config user.name "$GDUSER"
  git config user.email "$GH_USER_EMAIL"
  git config credential.helper "store --file=.git/credentials"
  echo "https://$GH_TOKEN:@github.com" > .git/credentials
}

# Begin of Npm tools
npm_login () {
  if which npm > /dev/null && which expect > /dev/null; then
    echo "Log into npm registry from ${basedir} ..."
    expect -f "${basedir}/npm/login.sh" ${@}
  fi
}

npm_logout () {
  if which npm > /dev/null; then
    echo "Login out from npm registry ..."
    npm logout ${@}
  fi
}
# end of Npm tools

publish () {
  [ -n "${TAG_REG_EXPR##+([[:space:]])}" ] && TAG_REGEX=$TAG_REG_EXPR || TAG_REGEX=$SEMVER_REGEX
  if [[ "$TRAVIS_TAG" =~ $TAG_REGEX ]] && which npm > /dev/null; then
    echo "Publishing npm package from tag: $TRAVIS_TAG"
    npm publish ${@} #npm publish with the given command line option ...
  else
    echo "Unexpected tag branch: $TRAVIS_TAG to match with: $TAG_REGEX"
    _error_exit "Invalid given tag version lavel"  #make sure with exit with error
  fi
}

#OPTS=${@:1:$#}
case "${1}" in
  login)
    for O in ${@:2:$#}; do
      case "${O}" in
        -u=*|--user=*)
          USER_NAME="${O#*=}"
        ;;
        -p=*|--password=*)
          USER_PWD="${O#*=}"
        ;;
        -e=*|--email=*)
          USER_EMAIL="${O#*=}"
        ;;
        -s=*|--scope=*)
          NPM_SCOPE="--scope=${O#*=}"
        ;;
        -r=*|--registry=*)
          NPM_REGISTRY="--registry=${O#*=}"
        ;;
      esac
    done;
    #npm_login ${@:2:$#}
    npm_login "$USER_NAME" "$USER_PWD" "$USER_EMAIL" "$NPM_SCOPE" "$NPM_REGISTRY"
    _graceful_exit
  ;;
  logout)
    npm_logout ${@:2:$#}
    _graceful_exit
  ;;
  -u|--config|--git-config)
    git_confg ${@:2:$#}
    _graceful_exit
  ;;
  -i|--install)
    apt_install ${@:2:$#}
    _graceful_exit
  ;;
  *)
    publish "${@:2:$#}"
    _graceful_exit
  ;;
esac

# Trap signals
trap "_signal_exit TERM" TERM HUP
trap "_signal_exit INT"  INT
# vim:set et sts=4 ts=4 tw=0:
