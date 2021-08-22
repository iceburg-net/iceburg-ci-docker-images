# iceburg-ci-docker-images
:rocket: docker images useful for CI agents and step execution


## software

image variants are defined in [docker-compose.yml](docker-compose.yml).
* :ox: tools are available in `minimal` images.
* all tools and languages are available in `universal` images.

### languages

language | notes
--- | ---
python3 | pip3
Java JRE 16 | AdoptOpenJDK HotSpot
Node 16 | npm, yarn
Ruby 3.0 | gem, bundler


### tools

name | notes
--- | ---
[ansible-core](https://github.com/ansible/ansible) | v2.11.3
[awscli](https://github.com/aws/aws-cli) | v1.20.26, waiting for [official musl build](https://github.com/aws/aws-cli/issues/4685) of v2
bash | :ox:
bzip2 | -
curl | :ox:
docker client | v20.10.8
docker compose cli | v2.0.0-rc.1
docker-compose | v1.29.2
[docker-compose-wait](https://github.com/ufoscout/docker-compose-wait) | v2.9.0, available as `/wait`
git | :ox:
[hadolint](https://github.com/hadolint/hadolint) | -
[jq](https://stedolan.github.io/jq/) | -
[newman](https://github.com/postmanlabs/newman) | v5.2.4 postman collection runner
[rubocop](https://rubocop.org/) | v0.39.0
[shellcheck](https://github.com/koalaman/shellcheck) | -
openssh | :ox:
openssl | -
tree | :ox:
unzip | :ox:
wget | :ox:
[yamllint](https://github.com/adrienverge/yamllint) | -
[yq](https://pypi.org/project/yq) | -

## usage

### as a github action

### as a gitlab agent

### in iceburg-ci
