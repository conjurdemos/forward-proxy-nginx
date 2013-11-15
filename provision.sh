#!/bin/bash
set -e
set -x

if [[ ! -e /usr/local/nginx ]] ; then
  ./install-nginx-lua.sh
fi

# This is important!
cp /vagrant/.netrc /root/.netrc

ln -sf /vagrant/nginx.conf /usr/local/nginx/conf/nginx.conf
service nginx start

su vagrant -c /vagrant/user.sh




