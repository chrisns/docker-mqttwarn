FROM python:2-alpine

ARG VERSION=master

ENV DOCKERIZE_VERSION v0.5.0

RUN set -ex \
    # add fetch deps, remove after build
    && apk add --no-cache --virtual .fetch-deps \
        git \
        openssl \
    # add run deps, never remove
    && git clone https://github.com/jpmens/mqttwarn.git /usr/src/app\
    && cd /usr/src/app \
    && git checkout ${VERSION} \
    && rm -r .git \
    && pip install --no-cache-dir \
      paho-mqtt \
    && wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    # removing fetch deps and build deps
    && apk --purge del .fetch-deps \
    && rm -rf /var/cache/apk/*

WORKDIR /usr/src/app

COPY mqttwarn.tpl.ini .

CMD dockerize -template mqttwarn.tpl.ini:mqttwarn.ini -stdout /usr/src/app/mqttwarn.log -stderr /usr/src/app/mqttwarn.err python /usr/src/app/mqttwarn.py
