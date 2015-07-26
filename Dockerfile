# Dockerfile for openresty

FROM ubuntu:15.04
MAINTAINER Robert Ditthardt <dditthardt@olivinelabs.com>

ENV DEBIAN_FRONTEND noninteractive
ENV OPENRESTY_VERSION 1.7.10.2

RUN apt-get update && apt-get upgrade -y && apt-get -y build-dep nginx && apt-get install -y wget git libpq-dev luarocks lua-sec liburiparser-dev libssl-dev check libpcre3 libpcre3-dev libjemalloc-dev libjemalloc1 build-essential libtool automake autoconf pkg-config && apt-get -q -y clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# libr3
RUN cd /tmp && git clone https://github.com/c9s/r3.git && cd r3 && ./autogen.sh && ./configure --with-malloc=jemalloc && make && make install && ln -s /usr/local/lib/libr3.so /usr/lib/libr3.so

# Openresty (Nginx)
RUN wget -O ngx_openresty.tar.gz http://openresty.org/download/ngx_openresty-$OPENRESTY_VERSION.tar.gz \
  && tar xvfz ngx_openresty.tar.gz \
  && cd ngx_openresty-$OPENRESTY_VERSION \
  && ./configure --with-luajit --with-http_addition_module --with-http_dav_module --with-http_geoip_module --with-http_gzip_static_module --with-http_image_filter_module --with-http_realip_module --with-http_stub_status_module --with-http_ssl_module --with-http_sub_module --with-http_xslt_module --with-ipv6 --with-http_postgres_module --with-pcre-jit \
  && make \
  && make install \
  && rm -rf /ngx_openresty-$OPENRESTY_VERSION

RUN mkdir /tmp/logs
RUN mkdir /app

ADD waco-kid/app-scm-1.rockspec /tmp/
RUN cd /tmp && luarocks make app-scm-1.rockspec

VOLUME ["/app"]

ENTRYPOINT /usr/local/openresty/nginx/sbin/nginx -p /tmp -c /app/nginx/nginx.conf
