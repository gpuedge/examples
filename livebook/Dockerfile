FROM ubuntu:22.04
ENV DEBIAN_FRONTEND noninteractive

ENV SSL_VERSION=1.1.1o
ENV OTP_VERSION=OTP-24.3.4
ENV ELIXIR_VERSION=v1.13.4

RUN apt-get update && apt-get install -y vim git curl locate wget apt-transport-https apt-utils locales
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN echo "en_US UTF-8" >> /etc/locale.gen && locale-gen

WORKDIR "/root"
RUN mkdir -p /root/source 

#Install erlang + elixir
RUN apt-get update && apt-get install -y build-essential autoconf libncurses-dev m4 xsltproc libxml2-utils unixodbc-dev

RUN cd /root/source && \
    curl https://www.openssl.org/source/openssl-$SSL_VERSION.tar.gz -O && \
    tar -xzf openssl-$SSL_VERSION.tar.gz && \
    cd openssl-$SSL_VERSION && ./config && make depend && make && \
    mkdir -p /root/source/openssl-$SSL_VERSION/lib && \
    cp -r /root/source/openssl-$SSL_VERSION/libc* /root/source/openssl-$SSL_VERSION/lib/ && \
    cp -r /root/source/openssl-$SSL_VERSION/libs* /root/source/openssl-$SSL_VERSION/lib/

RUN git clone https://github.com/erlang/otp /root/source/otp && \
    cd /root/source/otp && \
    git checkout $OTP_VERSION
RUN cd /root/source/otp && \
    ./otp_build autoconf && ./configure --with-ssl=/root/source/openssl-$SSL_VERSION --disable-dynamic-ssl-lib && make -j$(nproc) && make install

RUN git clone https://github.com/elixir-lang/elixir.git /root/source/elixir && \
    cd /root/source/elixir && \
    git checkout $ELIXIR_VERSION && \
    make clean && make install && \
    mix local.hex --force && mix local.rebar --force

#cleanup
RUN rm -rf /root/source

#Install livebook
RUN mix escript.install --force hex livebook

#install cftunnel
RUN wget --no-verbose https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    && dpkg -i cloudflared-linux-amd64.deb \
    && rm cloudflared-linux-amd64.deb

#setup init because cftunnel
RUN echo '#!/bin/bash' >> /start.sh \
    && echo 'cloudflared tunnel --url "http://localhost:8080" &' >> /start.sh \
    && echo '/root/.mix/escripts/livebook server' >> /start.sh \
    && chmod +x /start.sh

CMD ["/start.sh"]

