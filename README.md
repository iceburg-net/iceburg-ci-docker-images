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
Java JDK 17 | Eclipse Temurin OpenJDK
Node 18.2.0 | npm, yarn
Ruby 3.1.2 | gem, bundler

### tools

name | notes
--- | ---
[ansible](https://github.com/ansible/ansible) | v5.2.0
[ansible-lint](https://github.com/ansible-community/ansible-lint) | v5.3.2
[awscli](https://github.com/aws/aws-cli) | v1.22.42, waiting for [official musl build](https://github.com/aws/aws-cli/issues/4685) of v2
bash | :ox: v5.1.4
[bats](https://github.com/bats-core/bats-core) | v1.7.0
[black](https://github.com/psf/black) | 21.12b0 , pep8 linter and formatter
[gcc](https://pkgs.alpinelinux.org/package/v3.14/main/x86/build-base) | with g++, libc-dev, make, and patch
bzip2 | -
curl | :ox:
docker client | :ox: v20.10.16
[docker compose cli v2](https://github.com/docker/compose) | :ox: v2.5.1
docker-compose legacy v1 | :ox: v1.29.2
[docker-compose-wait](https://github.com/ufoscout/docker-compose-wait) | v2.9.0, available as `/wait`
git | :ox: "the stupid content tracker"
[gradle](https://gradle.org/) | v7.4.2
[hadolint](https://github.com/hadolint/hadolint) | v2.9.3
[jq](https://stedolan.github.io/jq/) | :ox:
maven | v3.8.5
[molecule](https://github.com/ansible-community/molecule) | v3.5.2
[newman](https://github.com/postmanlabs/newman) | v5.3.1 postman collection runner
[packer](https://www.packer.io/) | v1.8.0
[rubocop](https://rubocop.org/) | v1.25.0
[shellcheck](https://github.com/koalaman/shellcheck) | v0.8.0
openssh | :ox:
openssl | -
[terraform](https://www.terraform.io/) | v1.2.1
tree | :ox:
unzip | :ox:
wget | :ox:
[yamllint](https://github.com/adrienverge/yamllint) | v1.26.3
[yq](https://pypi.org/project/yq) | v2.13.0

## usage

images are published to multiple registries. use whichever is closest to your workflow.

* docker.io/iceburgci/step-image:*
* ghcr.io/iceburgci/step-image:*
* registry.gitlab.com/iceburgci/step-image:*
* public.ecr.aws/iceburg/step-image:*

### as a github action

### as a gitlab agent

### in iceburg-ci

## development

the [publish workflow](.github/workflows/github-actions-publish.yml) automatically builds new images and publishes them to registries on commits to the `main` branch.

### manual publishing

* lint, build, test `bin/ci`
* like what you're seeing? publish the images.

```
PUBLISH_REGISTRY=docker.io/iceburgci \
PUBLISH_ROLLING_TAGS=true \
  bin/ci publish

# PUBLISH_REGISTRY determines the registry images are pushed to.
# PUBLISH_ROLLING_TAGS when true, an additional tag stripped of -PIPLELINE_ID is pushed.
```
