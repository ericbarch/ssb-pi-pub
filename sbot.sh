#!/bin/bash

mkdir -p ~/.ssb

echo '{ "replication": { "legacy": false } }' > ~/.ssb/config

source ~/.nvm/nvm.sh

sbot "$@"
