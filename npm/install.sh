#!/usr/bin/env bash

set -e # exit with nonzero exit code if anything fails

if ! which expect > /dev/null; then
  sudo apt-get install \
    expect -y
fi
