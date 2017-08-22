# Docker-mqttwarn

This repo runs a job every 24hrs to check for recent updates to mqttwarn and updates a dockerhub repo with the latest image.

You can depend on either `latest` or a git hash if you like a bit more stability

I use dockerize to start the job and also template which allows you to inject things in to the ini files you create inside double curly braces (`{{ .Env.example }}`) and then inject them into the running docker container.

The intention is that you'll base your image off of mine, and then load in your `mqttwarn.ini` and any other dependencies:

```dockerfile
FROM chrisns/mqttwarn:latest
COPY mqttwarn.tpl.ini .
```

Or more realistically something like this example to get a fully loaded image with all the dependencies:
```dockerfile
FROM chrisns/mqttwarn:611c0967b41f7ca10672fb40a40576d145fded7e

RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
        rrdtool-dev \
        build-base \
    && apk add --no-cache --virtual .run-deps \
        rrdtool \
    && pip install --no-cache-dir \
      puka \
      pyst2 \
      google-api-python-client \
      gspread \
      rrdtool \
      pyserial \
      Mastodon.py \
      xively-python \
    && apk --purge del .build-deps \
    && rm -rf /var/cache/apk/*

COPY mqttwarn.tpl.ini .
```

You can then run it with something like:

```bash
docker build -t my-mqttwarn

docker run -d \
  -e MQTT_HOST=mqtt.p.cns.me \
  -e MQTT_USER=locator \
  -e MQTT_PASS=XXX \
  my-mqttwarn
```

