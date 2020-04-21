FROM continuumio/miniconda3:latest

ENV BASE_ENV phyloseq2ml
ENV PIP_CACHE_DIR="/opt/cache/pip"

RUN apt-get update

RUN apt-get install -y pkg-config libxml2-dev libssl-dev libcurl4-openssl-dev \
  libcairo2-dev x11-apps tree python-dev python-numpy build-essential cmake \
  git unzip libopenblas-dev liblapack-dev libhdf5-serial-dev python-h5py

ADD environment.yml /tmp/environment.yml

RUN conda env create -f /tmp/environment.yml

RUN echo "source activate $BASE_ENV" > ~/.bashrc
ENV PATH /opt/conda/envs/$BASE_ENV/bin:$PATH

RUN R --vanilla -e 'keras::install_keras(method = "conda", tensorflow = "default")'

RUN R --vanilla -e 'devtools::install_github("mikemc/speedyseq")'

