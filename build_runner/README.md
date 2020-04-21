# How to build the docker image for the CI

In order to use the CI, we use a modified docker image that builds on
`continuumio/miniconda3:latest` and has all dependencies already installed
defined in the conda environment as well as `keras`, `Tensorflow` and
`speedyseq`.

## Create docker container

```bash
docker build . -t phyloseq2ml-runner
```

