FROM openresty/openresty:xenial

RUN apt-get update
RUN apt-get -y install wget vim git libpq-dev
RUN apt-get -y install luarocks

RUN luarocks install lapis
