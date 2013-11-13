#!/bin/bash
set -e
set -x

if [[ ! -e /usr/local/nginx ]] ; then
  ./install-nginx-lua.sh
fi

# This is important!
cp /home/vagrant/.netrc /root/.netrc

ln -sf /home/vagrant/nginx.conf /usr/local/nginx/conf/nginx.conf
service nginx start

su vagrant
curl -L https://get.rvm.io | bash
source ~/.rvm/scripts/rvm
rvm install 2.0.0
rvm use 2.0.0
gem install conjur-cli conjur-asset-environment-api conjur-asset-key-pair-api conjur-asset-layer-api --no-rdoc --no-ri




