ARG REGISTRY=docker.io

#
# minimal CI image
#
FROM $REGISTRY/docker:20.10.16 as docker
FROM $REGISTRY/docker/compose:alpine-1.29.2 as compose

FROM $REGISTRY/alpine:3 as minimal
COPY --from=docker /usr/local/bin/docker /usr/local/bin/
COPY --from=compose /usr/local/bin/docker-compose /usr/local/bin/
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN apk add --no-cache \
  bash \
  ca-certificates \
  curl \
  git \
  jq \
  openssh-client-default \
  tree \
  unzip \
&& ssh-keyscan github.com >> /etc/ssh/ssh_known_hosts \
&& export WAIT_VERSION=2.9.0 WAIT_SHA256SUM=b945d1bc2b6bac5b8998bdc56791a66d99085432a6b164ef6726c52653f4b8d5 \
  && wget -qO /wait https://github.com/ufoscout/docker-compose-wait/releases/download/$WAIT_VERSION/wait \
  && echo "$WAIT_SHA256SUM */wait" | sha256sum -c \
  && chmod +x /wait

# install docker compose v2 aka "docker (space) compose"
RUN export COMPOSE_VERSION=2.5.1 COMPOSE_SHA256SUM=d99de1ea7616f2a4c7914d37674f0650660a5e832be555805a71c0fc377233c9 \
  && wget -qO docker-compose "https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-linux-x86_64" \
  && echo "$COMPOSE_SHA256SUM *docker-compose" | sha256sum -c \
  && chmod +x docker-compose \
  && mkdir -p /usr/lib/docker/cli-plugins \
  && mv docker-compose /usr/lib/docker/cli-plugins/ \
  && echo "Testing installation"; docker compose version

COPY entrypoint /entrypoint
ENTRYPOINT ["/entrypoint"]
CMD []

#
# universal CI image
#

FROM $REGISTRY/bats/bats:1.7.0 as bats
FROM $REGISTRY/hadolint/hadolint:2.9.3-alpine as hadolint
FROM $REGISTRY/eclipse-temurin:17-jdk-alpine as lang-java
FROM $REGISTRY/node:18.2.0-alpine as lang-node
FROM $REGISTRY/ruby:3.1.2-alpine as lang-ruby
FROM $REGISTRY/hashicorp/packer:1.8.0 as packer
FROM $REGISTRY/koalaman/shellcheck-alpine:v0.8.0 as shellcheck
FROM $REGISTRY/hashicorp/terraform:1.2.1 as terraform

FROM minimal as universal
COPY --from=bats /opt/bats /opt/bats
COPY --from=hadolint /bin/hadolint /usr/local/bin/
COPY --from=shellcheck /bin/shellcheck /usr/local/bin/
COPY --from=packer /bin/packer /usr/local/bin/
COPY --from=terraform /bin/terraform /usr/local/bin/
ENV PATH="/opt/bats/bin:$PATH"
RUN apk add --no-cache \
  build-base \
  bzip2 \
  libstdc++ \
  openssl

# java + tools
ENV JAVA_HOME=/opt/java/openjdk \
    GRADLE_HOME=/opt/gradle
ENV PATH="$JAVA_HOME/bin:$GRADLE_HOME/bin:/opt/maven/bin:$PATH"
COPY --from=lang-java $JAVA_HOME $JAVA_HOME

RUN export GRADLE_VERSION=7.4.2 GRADLE_SHASUM=29e49b10984e585d8118b7d0bc452f944e386458df27371b49b4ac1dec4b7fda \
  && wget -qO gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
  && echo "$GRADLE_SHASUM *gradle.zip" | sha256sum -c \
  && unzip gradle.zip \
  && rm gradle.zip \
  && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
  && echo "Testing Gradle installation"; gradle --version

RUN export MAVEN_VERSION=3.8.5 MAVEN_SHASUM=88e30700f32a3f60e0d28d0f12a3525d29b7c20c72d130153df5b5d6d890c673 \
  && wget -qO maven.tar.gz "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
  && echo "$MAVEN_SHASUM *maven.tar.gz" | sha256sum -c \
  && tar xzf maven.tar.gz \
  && rm maven.tar.gz \
  && mv "apache-maven-${MAVEN_VERSION}" /opt/maven/ \
  && echo "Testing Maven installation"; mvn -v

# python + tools
RUN apk add --no-cache \
  py3-bcrypt \
  py3-cryptography \
  py3-pynacl \
  py3-pip \
  py3-regex \
  py3-requests \
  py3-ruamel.yaml \
  py3-yaml \
&& pip3 install --no-cache-dir --upgrade pip \
&& pip3 install --no-cache-dir \
  ansible==5.2.0 \
  ansible-lint==5.3.2 \
  awscli==1.22.42 \
  black==21.12b0 \
  molecule==3.5.2 \
  molecule-docker \
  yamllint==1.26.3 \
  yq==2.13.0

# node + tools
COPY --from=lang-node /usr/local /usr/local
RUN npm install --global \
  newman@5.3.1

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
  rubocop:1.25.0
