FROM gcc as builder

RUN apt-get update && apt-get install -y git

RUN groupadd nobody && \
    useradd jsproxy -g nobody --create-home

USER jsproxy
WORKDIR /home/jsproxy

RUN cd $(mktemp -d) && \
    curl -k -O https://www.openssl.org/source/openssl-1.1.1b.tar.gz && \
    tar zxf openssl-* && ls -l && \
    curl -k -O https://ftp.exim.org/pub/pcre/pcre-8.43.tar.gz && \
    tar zxf pcre-* && ls -l && \
    curl -k -O https://zlib.net/zlib-1.2.12.tar.gz && \
    tar zxf zlib-* && ls -l && \
    curl -k -O https://openresty.org/download/openresty-1.15.8.1.tar.gz && \
    tar zxf openresty-* && ls -l &&\
    cd openresty-* && \
    export PATH=$PATH:/sbin && \
    ./configure \
        --with-openssl=../openssl-1.1.1b \
        --with-pcre=../pcre-8.43 \
        --with-zlib=../zlib-1.2.12 \
        --with-http_v2_module \
        --with-http_ssl_module \
        --with-pcre-jit \
        --prefix=$HOME/openresty && \
    make && \
    make install

RUN git clone --depth=1 https://github.com/EtherDream/jsproxy.git server && \
    cd server && \
    rm -rf www && \
    git clone -b gh-pages --depth=1 https://github.com/EtherDream/jsproxy.git www


FROM ubuntu as prod

RUN groupadd nobody && \
    useradd jsproxy -g nobody --create-home

USER jsproxy

COPY --from=builder /home/jsproxy /home/jsproxy

WORKDIR /home/jsproxy

EXPOSE 8443
EXPOSE 8080

CMD ./server/run.sh && while true; do sleep 1; done
