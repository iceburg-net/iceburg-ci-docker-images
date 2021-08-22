ARG REGISTRY=docker.io

#
# minimal CI image
#
FROM $REGISTRY/docker:20.10.8 as docker
FROM $REGISTRY/docker/compose:alpine-1.29.2 as compose

FROM $REGISTRY/alpine:3 as minimal
COPY --from=docker /usr/local/bin/docker /usr/local/bin/
COPY --from=compose /usr/local/bin/docker-compose /usr/local/bin/
RUN apk add --no-cache \
  bash \
  ca-certificates \
  curl \
  git \
  jq \
  openssh-client-default \
  tree \
  unzip \
&& WAIT_VERSION=2.9.0 && WAIT_SHA256SUM=b945d1bc2b6bac5b8998bdc56791a66d99085432a6b164ef6726c52653f4b8d5 &&\
  wget -qO /wait https://github.com/ufoscout/docker-compose-wait/releases/download/$WAIT_VERSION/wait &&\
  echo "$WAIT_SHA256SUM */wait" | sha256sum -c &&\
  chmod +x /wait

COPY entrypoint /entrypoint
ENTRYPOINT ["/entrypoint"]
CMD []

#
# universal CI image
#
FROM $REGISTRY/hadolint/hadolint:latest-alpine as hadolint
FROM $REGISTRY/adoptopenjdk/openjdk16:alpine-jre as lang-java
FROM $REGISTRY/node:16-alpine as lang-node
FROM $REGISTRY/ruby:3.0-alpine as lang-ruby
FROM $REGISTRY/koalaman/shellcheck:stable as shellcheck

FROM minimal as universal
COPY --from=hadolint /bin/hadolint /usr/local/bin/
COPY --from=shellcheck /bin/shellcheck /usr/local/bin/
RUN apk add --no-cache \
  bzip2 \
  libstdc++ \
  openssl

# java + tools
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="$JAVA_HOME/bin:$PATH"
COPY --from=lang-java $JAVA_HOME $JAVA_HOME

# python + tools
RUN apk add --no-cache \
  py3-cryptography \
  py3-pip \
  py3-requests \
  py3-yaml \
&& pip3 install --no-cache-dir --upgrade pip \
&& pip3 install --no-cache-dir \
  ansible-core==2.11.3 \
  awscli==1.20.26 \
  yamllint==1.26.3 \
  yq==2.12.2

# node + tools
COPY --from=lang-node /usr/local /usr/local
RUN npm install --global \
  newman@5.2.4

# ruby + tools
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME" \
    PATH=$GEM_HOME/bin:$PATH
COPY --from=lang-ruby /usr/local /usr/local
RUN runDeps="$( scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' )" \
&& apk add --no-cache $runDeps \
  libffi-dev \
  procps \
  yaml-dev \
  zlib-dev \
&& gem install \
  rubocop:0.39.0

# install docker compose v2 aka "docker (space) compose"
RUN curl -L https://github.com/docker/compose-cli/releases/download/v2.0.0-rc.1/docker-compose-linux-amd64 > docker-compose \
&& chmod +x docker-compose \
&& mkdir -p /usr/lib/docker/cli-plugins \
&& mv docker-compose /usr/lib/docker/cli-plugins/
