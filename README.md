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
Java JDK 16 | AdoptOpenJDK HotSpot
Node 16 | npm, yarn
Ruby 3.0 | gem, bundler

### tools

name | notes
--- | ---
[ansible-core](https://github.com/ansible/ansible) | v2.11.3
[awscli](https://github.com/aws/aws-cli) | v1.20.26, waiting for [official musl build](https://github.com/aws/aws-cli/issues/4685) of v2
bash | :ox: v5.1.4
[bats](https://github.com/bats-core/bats-core) | v1.4.1
[black](https://github.com/psf/black) | 21.8b0 , pep8 linter and formatter
bzip2 | -
curl | :ox:
docker client | v20.10.8
docker compose cli | v2.0.0-rc.1
docker-compose | v1.29.2
[docker-compose-wait](https://github.com/ufoscout/docker-compose-wait) | v2.9.0, available as `/wait`
git | :ox:
gradle | v7.2
[hadolint](https://github.com/hadolint/hadolint) | v2.7.0
[jq](https://stedolan.github.io/jq/) | :ox:
maven | v3.8.3
[newman](https://github.com/postmanlabs/newman) | v5.2.4 postman collection runner
[rubocop](https://rubocop.org/) | v0.39.0
[shellcheck](https://github.com/koalaman/shellcheck) | -
openssh | :ox:
openssl | -
tree | :ox:
unzip | :ox:
wget | :ox:
[yamllint](https://github.com/adrienverge/yamllint) | v1.26.3
[yq](https://pypi.org/project/yq) | v2.12.2

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
