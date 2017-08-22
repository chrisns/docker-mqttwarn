#!/usr/bin/env bash

VERSION=$(git ls-remote https://github.com/jpmens/mqttwarn.git rev-parse master | awk '{print $1}')

echo Remote $VERSION

function docker_tag_exists() {
    curl --silent -f -lSL https://index.docker.io/v1/repositories/$1/tags/$2 > /dev/null
}

if docker_tag_exists chrisns/mqttwarn ${VERSION} && [ "${TRAVIS_EVENT_TYPE}" = "cron" ]; then
  echo ${VERSION} already exists
else
  echo ${VERSION} does not yet exist
  docker login -u="${DOCKER_USERNAME}" -p="${DOCKER_PASSWORD}"
  docker build -t chrisns/mqttwarn:${VERSION} --build-arg VERSION=${VERSION} .
  docker push chrisns/mqttwarn:${VERSION}
  docker tag chrisns/mqttwarn:${VERSION} chrisns/mqttwarn:latest
  docker push chrisns/mqttwarn:latest
fi