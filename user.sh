#!/bin/bash
curl -L https://get.rvm.io | bash
source ~/.rvm/scripts/rvm
rvm install 2.0.0
rvm use 2.0.0
gem install conjur-cli conjur-asset-environment-api conjur-asset-key-pair-api conjur-asset-layer-api --no-rdoc --no-ri