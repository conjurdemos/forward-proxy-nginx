#!/bin/bash
set -e
set -x

# install debian packages
apt-get update
apt-get -y install build-essential zlib1g-dev libpcre3 libpcre3-dev libbz2-dev libssl-dev tar unzip vim git curl

cd /tmp

echo "installing luajit"
git clone http://luajit.org/git/luajit-2.0.git
cd luajit-2.0
make && make install
cd /tmp
rm -rf luajit*
# need this to build lua c extensions
cp /usr/local/include/luajit-2.0/*.h /usr/local/include


echo "installing nginx"
echo "fetching nginx-lua"
wget -O lua-nginx-module.tar.gz https://github.com/chaoslawful/lua-nginx-module/archive/v0.9.0.tar.gz
tar xzvf lua-nginx-module.tar.gz

echo "fetching ngx-devel-kit"
wget -O ngx_devel_kit.tar.gz https://github.com/simpl/ngx_devel_kit/archive/v0.2.19.tar.gz
tar xzvf ngx_devel_kit.tar.gz

echo "fetching nginx"
wget http://nginx.org/download/nginx-1.5.6.tar.gz
tar -xzvf nginx-1.5.6.tar.gz
cd nginx-1.5.6
export LUAJIT_LIB=/usr/local/lib
export LUAJIT_INC=/usr/local/include/luajit-2.0
./configure --with-http_ssl_module --with-http_auth_request_module --add-module=../ngx_devel_kit-0.2.19 --add-module=../lua-nginx-module-0.9.0 --with-debug
make && make install
ln /usr/local/nginx/sbin/nginx /usr/local/sbin/nginx
ldconfig

wget https://raw.github.com/JasonGiedymin/nginx-init-ubuntu/master/nginx -O /etc/init.d/nginx
chmod +x /etc/init.d/nginx
update-rc.d -f nginx defaults
