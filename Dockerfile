FROM centos:7.9.2009

ENV NGINX_VERSION nginx-1.20.1
ENV PCRE pcre-8.45
ENV ZLIB zlib-1.2.11
ENV OPENSSL openssl-1.1.1l

# curl -O https://www.openssl.org/source/openssl-1.1.1l.tar.gz
# curl -O https://www.zlib.net/zlib-1.2.11.tar.gz
# curl -O https://ftp.pcre.org/pub/pcre/pcre-8.45.tar.gz
# curl -O http://nginx.org/download/nginx-1.20.1.tar.gz

COPY pkg/ /opt
WORKDIR /opt

RUN tar xzf ${ZLIB}.tar.gz && \    
    tar xzf ${PCRE}.tar.gz && \    
    tar xzf ${OPENSSL}.tar.gz && \
    yum install -y gcc gcc-c++ make perl perl-devel perl-ExtUtils-Embed libxslt libxslt-devel libxml2 libxml2-devel gd gd-devel GeoIP GeoIP-devel && \    
    tar xzf ${NGINX_VERSION}.tar.gz && \
    cd /opt/${NGINX_VERSION} && \
    ./configure --prefix=/usr/share/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/run/nginx.pid \
        --lock-path=/var/lock/nginx.lock \
        --user=nginx \
        --group=nginx \
        --build=CentOS \
        --builddir=${NGINX_VERSION} \
        --http-client-body-temp-path=/var/lib/nginx/body \
        --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
        --http-proxy-temp-path=/var/lib/nginx/proxy \
        --http-scgi-temp-path=/var/lib/nginx/scgi \
        --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
        --with-openssl=../${OPENSSL} \
        --with-openssl-opt=enable-ec_nistp_64_gcc_128 \
        --with-openssl-opt=no-nextprotoneg \
        --with-openssl-opt=no-weak-ssl-ciphers \
        --with-openssl-opt=no-ssl3 \
        --with-pcre=../${PCRE} \
        --with-pcre-jit \
        --with-zlib=../${ZLIB} \
        --with-compat \
        --with-file-aio \
        --with-threads \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_sub_module \
        --with-http_stub_status_module \
        --with-http_v2_module \
        --with-http_secure_link_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-stream \
        --with-stream_realip_module \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-debug && \
    make && \
    make install && \
    ln -s /usr/lib64/nginx/modules /etc/nginx/modules && \
    mkdir -p /var/lib/nginx/body && \
    mkdir -p /etc/nginx/conf.d && \
    useradd --system --home /var/cache/nginx --shell /sbin/nologin --comment "nginx user" --user-group nginx


COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
