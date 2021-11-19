ARG REGISTRY=docker.io

#
# minimal CI image
#
FROM $REGISTRY/docker:20.10.8 as docker
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

FROM $REGISTRY/bats/bats:v1.4.1 as bats
FROM $REGISTRY/hadolint/hadolint:2.7.0-alpine as hadolint
FROM $REGISTRY/eclipse-temurin:17-jdk-alpine as lang-java
FROM $REGISTRY/node:16-alpine as lang-node
FROM $REGISTRY/ruby:3.0-alpine as lang-ruby
FROM $REGISTRY/hashicorp/packer:1.7.8 as packer
FROM $REGISTRY/koalaman/shellcheck:stable as shellcheck
FROM $REGISTRY/hashicorp/terraform:1.0.11 as terraform

FROM minimal as universal
COPY --from=bats /opt/bats /opt/bats
COPY --from=hadolint /bin/hadolint /usr/local/bin/
COPY --from=shellcheck /bin/shellcheck /usr/local/bin/
COPY --from=packer /bin/packer /usr/local/bin/
COPY --from=terraform /bin/terraform /usr/local/bin/
ENV PATH="/opt/bats/bin:$PATH"
RUN apk add --no-cache \
  bzip2 \
  libstdc++ \
  openssl

# java + tools
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="$JAVA_HOME/bin:/opt/maven/bin:$PATH" \
    GRADLE_HOME=/opt/gradle \
    GRADLE_OPTS="-Dorg.gradle.daemon=false"
COPY --from=lang-java $JAVA_HOME $JAVA_HOME

RUN export GRADLE_VERSION=7.3 GRADLE_SHASUM=de8f52ad49bdc759164f72439a3bf56ddb1589c4cde802d3cec7d6ad0e0ee410; \
  wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
  && echo "$GRADLE_SHASUM *gradle.zip" | sha256sum -c \
  && unzip gradle.zip \
  && rm gradle.zip \
  && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
  && ln -s "${GRADLE_HOME}/bin/gradle" /usr/local/bin/gradle \
  && echo "Testing Gradle installation"; gradle --version

RUN export MAVEN_VERSION=3.8.3 MAVEN_SHASUM=0f1597d11085b8fe93d84652a18c6deea71ece9fabba45a02cf6600c7758fd5b; \
  wget --no-verbose --output-document=maven.tar.gz "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
  && echo "$MAVEN_SHASUM *maven.tar.gz" | sha256sum -c \
  && tar xzf maven.tar.gz \
  && rm maven.tar.gz \
  && mv "apache-maven-${MAVEN_VERSION}" /opt/maven/ \
  && echo "Testing Maven installation"; mvn -v

# python + tools
RUN apk add --no-cache \
  py3-cryptography \
  py3-pip \
  py3-regex \
  py3-requests \
  py3-yaml \
&& pip3 install --no-cache-dir --upgrade pip \
&& pip3 install --no-cache-dir \
  ansible==4.8.0 \
  awscli==1.20.26 \
  black==21.8b0 \
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
