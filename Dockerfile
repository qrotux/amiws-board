FROM node:12.22.12-alpine3.15 as queue

ENV WS_URL="window.wsAMIWSHost"

RUN apk update \
 && apk add git \
 && cd /usr \
 && git clone https://github.com/staskobzar/amiws_queue.git \
 && cd amiws_queue \
 && npm i \
 && npm run build

FROM ubuntu:18.04

RUN apt update && apt-get install -y libyaml-dev openssl make dh-autoreconf git runit nginx \
 && cd /usr \
 && git clone https://github.com/staskobzar/amiws.git \
 && cd amiws \
 && mv web_root /var/www/amiws \
 && autoreconf -if && ./configure && make && make install \
 && apt purge -y libyaml-dev git make dh-autoreconf \
 && rm -rf /var/lib/apt/lists/*

COPY --from=queue /usr/amiws_queue/dist /var/www/html

ENV WS_HOST=ws://localhost:8000

COPY amiws-config.yaml /data/amiws/config.yaml
COPY runsvdir-* /usr/local/bin/
COPY runit /etc/service

CMD ["runsvdir-init"]
