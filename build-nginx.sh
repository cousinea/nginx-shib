#!/bin/bash

set -x

DEFAULT_NGINX_VERSION="1.10.2"
dep_version=${VERSION:-$DEFAULT_NGINX_VERSION}
dep_dirname=nginx-${dep_version}
dep_archive_name=${dep_dirname}.tar.gz
dep_url=http://nginx.org/download/${dep_archive_name}
headers_version=${HEADERS_MORE_VERSION:-0.32}

pushd /tmp
    # Get nginx
    curl -L ${dep_url} | tar xz

    # Get the headers-more module
    curl -L https://github.com/openresty/headers-more-nginx-module/archive/v${headers_version}.tar.gz | tar xz

    # Get the nginx shibboleth module
    git clone https://github.com/nginx-shib/nginx-http-shibboleth.git

    pushd $dep_dirname
        # Configure and build nginx
        ./configure \
            --prefix=/usr/local/nginx \
            --sbin-path=/usr/sbin/nginx \
            --conf-path=/usr/local/nginx/nginx.conf \
            --error-log-path=/dev/stderr \
            --http-log-path=/dev/stdout \
            --pid-path=/usr/local/nginx/nginx.pid \
            --lock-path=/usr/local/nginx/nginx.lock \
            --http-client-body-temp-path=/var/cache/nginx/client_temp \
            --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
            --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
            --user=_shibd \
            --group=_shibd \
            --with-debug \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-http_realip_module \
            --with-pcre \
            --with-http_auth_request_module \
            --with-http_stub_status_module \
            --add-module=../headers-more-nginx-module-${headers_version} \
            --add-module=../nginx-http-shibboleth
        make && make install
    popd

    # Clean up a bit
    rm -Rf $dep_dirname ./headers-more-nginx-module-${headers_version} ./nginx-http-shibboleth
    
popd