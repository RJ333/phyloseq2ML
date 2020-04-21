FROM continuumio/miniconda3:latest

SHELL ["/bin/bash", "--login", "-c"]

ENV BASE_ENV phyloseq2ml
ENV PIP_CACHE_DIR="/opt/cache/pip"

RUN \
  conda config --append envs_dirs ./vendor/conda

RUN \
  echo $'name: phyloseq2ml \n\
channels: \n\
  - conda-forge \n\
  - bioconda \n\
  - defaults \n\
dependencies: \n\
  - _libgcc_mutex=0.1=conda_forge \n\
  - _openmp_mutex=4.5=1_llvm \n\
  - _r-mutex=1.0.1=anacondar_1 \n\
  - binutils_impl_linux-64=2.33.1=h53a641e_8 \n\
  - binutils_linux-64=2.33.1=h9595d00_16 \n\
  - bioconductor-biobase=2.46.0=r36h516909a_0 \n\
  - bioconductor-biocgenerics=0.32.0=r36_0 \n\
  - bioconductor-biomformat=1.14.0=r36_0 \n\
  - bioconductor-biostrings=2.54.0=r36h516909a_0 \n\
  - bioconductor-iranges=2.20.0=r36h516909a_0 \n\
  - bioconductor-multtest=2.42.0=r36h516909a_0 \n\
  - bioconductor-phyloseq=1.30.0=r36_0 \n\
  - bioconductor-rhdf5=2.30.0=r36he1b5a44_0 \n\
  - bioconductor-rhdf5lib=1.8.0=r36h516909a_0 \n\
  - bioconductor-s4vectors=0.24.0=r36h516909a_0 \n\
  - bioconductor-xvector=0.26.0=r36h516909a_0 \n\
  - bioconductor-zlibbioc=1.32.0=r36h516909a_0 \n\
  - bwidget=1.9.14=0 \n\
  - bzip2=1.0.8=h516909a_2 \n\
  - ca-certificates=2019.11.28=hecc5488_0 \n\
  - cairo=1.16.0=hfb77d84_1002 \n\
  - curl=7.68.0=hf8cf82a_0 \n\
  - fontconfig=2.13.1=h86ecdb6_1001 \n\
  - freetype=2.10.0=he983fc9_1 \n\
  - fribidi=1.0.5=h516909a_1002 \n\
  - gcc_impl_linux-64=7.3.0=hd420e75_5 \n\
  - gcc_linux-64=7.3.0=h553295d_16 \n\
  - gettext=0.19.8.1=hc5be6a0_1002 \n\
  - gfortran_impl_linux-64=7.3.0=hdf63c60_5 \n\
  - gfortran_linux-64=7.3.0=h553295d_16 \n\
  - glib=2.58.3=h6f030ca_1002 \n\
  - graphite2=1.3.13=hf484d3e_1000 \n\
  - gsl=2.6=h294904e_0 \n\
  - gxx_impl_linux-64=7.3.0=hdf63c60_5 \n\
  - gxx_linux-64=7.3.0=h553295d_16 \n\
  - harfbuzz=2.4.0=h9f30f68_3 \n\
  - icu=64.2=he1b5a44_1 \n\
  - jpeg=9c=h14c3975_1001 \n\
  - krb5=1.16.4=h2fd8d38_0 \n\
  - ld_impl_linux-64=2.33.1=h53a641e_8 \n\
  - libblas=3.8.0=15_openblas \n\
  - libcblas=3.8.0=15_openblas \n\
  - libcurl=7.68.0=hda55be3_0 \n\
  - libedit=3.1.20170329=hf8c457e_1001 \n\
  - libffi=3.2.1=he1b5a44_1006 \n\
  - libgcc-ng=9.2.0=h24d8f2e_2 \n\
  - libgfortran-ng=7.3.0=hdf63c60_5 \n\
  - libgomp=9.2.0=h24d8f2e_2 \n\
  - libiconv=1.15=h516909a_1005 \n\
  - liblapack=3.8.0=15_openblas \n\
  - libopenblas=0.3.8=h5ec1e0e_0 \n\
  - libpng=1.6.37=hed695b0_0 \n\
  - libssh2=1.8.2=h22169c7_2 \n\
  - libstdcxx-ng=9.2.0=hdf63c60_2 \n\
  - libtiff=4.1.0=hc3755c2_3 \n\
  - libuuid=2.32.1=h14c3975_1000 \n\
  - libxcb=1.13=h14c3975_1002 \n\
  - libxml2=2.9.10=hee79883_0 \n\
  - llvm-openmp=9.0.1=hc9558a2_2 \n\
  - lz4-c=1.8.3=he1b5a44_1001 \n\
  - make=4.2.1=h14c3975_2004 \n\
  - ncurses=6.1=hf484d3e_1002 \n\
  - openssl=1.1.1d=h516909a_0 \n\
  - pandoc=2.9.2=0 \n\
  - pango=1.42.4=ha030887_1 \n\
  - pcre=8.44=he1b5a44_0 \n\
  - pixman=0.38.0=h516909a_1003 \n\
  - pthread-stubs=0.4=h14c3975_1001 \n\
  - r-ade4=1.7_15=r36hcdcec82_0 \n\
  - r-ape=5.3=r36h0357c0b_1 \n\
  - r-askpass=1.1=r36hcdcec82_1 \n\
  - r-assertthat=0.2.1=r36h6115d3f_1 \n\
  - r-backports=1.1.5=r36hcdcec82_0 \n\
  - r-base=3.6.2=h7ed4ef7_1 \n\
  - r-base64enc=0.1_3=r36hcdcec82_1003 \n\
  - r-brew=1.0_6=r36h6115d3f_1002 \n\
  - r-broom=0.5.4=r36h6115d3f_0 \n\
  - r-callr=3.4.2=r36h6115d3f_0 \n\
  - r-cellranger=1.1.0=r36h6115d3f_1002 \n\
  - r-cli=2.0.1=r36h6115d3f_0 \n\
  - r-clipr=0.7.0=r36h6115d3f_0 \n\
  - r-clisymbols=1.2.0=r36h6115d3f_1002 \n\
  - r-cluster=2.1.0=r36h9bbef5b_2 \n\
  - r-codetools=0.2_16=r36h6115d3f_1001 \n\
  - r-colorspace=1.4_1=r36hcdcec82_1 \n\
  - r-commonmark=1.7=r36hcdcec82_1001 \n\
  - r-config=0.3=r36h6115d3f_1002 \n\
  - r-covr=3.4.0=r36h0357c0b_0 \n\
  - r-crayon=1.3.4=r36h6115d3f_1002 \n\
  - r-crosstalk=1.0.0=r36h6115d3f_1002 \n\
  - r-curl=4.3=r36hcdcec82_0 \n\
  - r-data.table=1.12.8=r36hcdcec82_0 \n\
  - r-dbi=1.1.0=r36h6115d3f_0 \n\
  - r-dbplyr=1.4.2=r36h6115d3f_1 \n\
  - r-desc=1.2.0=r36h6115d3f_1002 \n\
  - r-devtools=2.2.2=r36h6115d3f_0 \n\
  - r-digest=0.6.24=r36h0357c0b_0 \n\
  - r-dplyr=0.8.4=r36h0357c0b_0 \n\
  - r-dt=0.12=r36h6115d3f_0 \n\
  - r-ellipsis=0.3.0=r36hcdcec82_0 \n\
  - r-evaluate=0.14=r36h6115d3f_1 \n\
  - r-fansi=0.4.1=r36hcdcec82_0 \n\
  - r-farver=2.0.3=r36h0357c0b_0 \n\
  - r-fastdummies=1.6.0=r36h6115d3f_0 \n\
  - r-fastmap=1.0.1=r36h0357c0b_0 \n\
  - r-forcats=0.4.0=r36h6115d3f_1 \n\
  - r-foreach=1.4.8=r36h6115d3f_0 \n\
  - r-futile.logger=1.4.3 \n\
  - r-fs=1.3.1=r36h0357c0b_1 \n\
  - r-generics=0.0.2=r36h6115d3f_1002 \n\
  - r-ggplot2=3.2.1=r36h6115d3f_0 \n\
  - r-gh=1.1.0=r36h6115d3f_0 \n\
  - r-git2r=0.26.1=r36h5ca76e2_1 \n\
  - r-glue=1.3.1=r36hcdcec82_1 \n\
  - r-gtable=0.3.0=r36h6115d3f_2 \n\
  - r-haven=2.2.0=r36hde08347_0 \n\
  - r-highr=0.8=r36h6115d3f_1 \n\
  - r-hms=0.5.3=r36h6115d3f_0 \n\
  - r-htmltools=0.4.0=r36h0357c0b_0 \n\
  - r-htmlwidgets=1.5.1=r36h6115d3f_0 \n\
  - r-httpuv=1.5.2=r36h0357c0b_1 \n\
  - r-httr=1.4.1=r36h6115d3f_1 \n\
  - r-igraph=1.2.4.2=r36h6786f55_0 \n\
  - r-ini=0.3.1=r36h6115d3f_1002 \n\
  - r-iterators=1.0.12=r36h6115d3f_0 \n\
  - r-jsonlite=1.6.1=r36hcdcec82_0 \n\
  - r-keras=2.2.5.0=r36h6115d3f_0 \n\
  - r-knitr=1.28=r36h6115d3f_0 \n\
  - r-labeling=0.3=r36h6115d3f_1002 \n\
  - r-later=1.0.0=r36h0357c0b_0 \n\
  - r-lattice=0.20_40=r36hcdcec82_0 \n\
  - r-lazyeval=0.2.2=r36hcdcec82_1 \n\
  - r-lifecycle=0.1.0=r36h6115d3f_0 \n\
  - r-lubridate=1.7.4=r36h0357c0b_1002 \n\
  - r-magrittr=1.5=r36h6115d3f_1002 \n\
  - r-markdown=1.1=r36hcdcec82_0 \n\
  - r-mass=7.3_51.5=r36hcdcec82_0 \n\
  - r-matrix=1.2_18=r36hcdcec82_1 \n\
  - r-memoise=1.1.0=r36h6115d3f_1003 \n\
  - r-mgcv=1.8_31=r36hcdcec82_0 \n\
  - r-mime=0.9=r36hcdcec82_0 \n\
  - r-modelr=0.1.5=r36h6115d3f_0 \n\
  - r-munsell=0.5.0=r36h6115d3f_1002 \n\
  - r-nlme=3.1_144=r36h9bbef5b_0 \n\
  - r-openssl=1.4.1=r36h9c8475f_0 \n\
  - r-permute=0.9_5=r36_1 \n\
  - r-pillar=1.4.3=r36h6115d3f_0 \n\
  - r-pixmap=0.4_11=r36h6115d3f_1002 \n\
  - r-pkgbuild=1.0.6=r36h6115d3f_0 \n\
  - r-pkgconfig=2.0.3=r36h6115d3f_0 \n\
  - r-pkgload=1.0.2=r36h0357c0b_1001 \n\
  - r-plogr=0.2.0=r36h6115d3f_1002 \n\
  - r-plyr=1.8.5=r36h0357c0b_0 \n\
  - r-praise=1.0.0=r36h6115d3f_1003 \n\
  - r-prettyunits=1.1.1=r36h6115d3f_0 \n\
  - r-processx=3.4.2=r36hcdcec82_0 \n\
  - r-progress=1.2.2=r36h6115d3f_1 \n\
  - r-promises=1.1.0=r36h0357c0b_0 \n\
  - r-ps=1.3.2=r36hcdcec82_0 \n\
  - r-purrr=0.3.3=r36hcdcec82_0 \n\
  - r-r6=2.4.1=r36h6115d3f_0 \n\
  - r-randomforest=4.6_14=r36h9bbef5b_1002 \n\
  - r-ranger=0.12.1=r36h0357c0b_0 \n\
  - r-rappdirs=0.3.1=r36hcdcec82_1003 \n\
  - r-rcmdcheck=1.3.3=r36h6115d3f_2 \n\
  - r-rcolorbrewer=1.1_2=r36h6115d3f_1002 \n\
  - r-rcpp=1.0.3=r36h0357c0b_0 \n\
  - r-rcppeigen=0.3.3.7.0=r36h0357c0b_0 \n\
  - r-readr=1.3.1=r36h0357c0b_1002 \n\
  - r-readxl=1.3.1=r36h0357c0b_2 \n\
  - r-rematch=1.0.1=r36h6115d3f_1002 \n\
  - r-remotes=2.1.1=r36h6115d3f_0 \n\
  - r-reprex=0.3.0=r36h6115d3f_1 \n\
  - r-reshape2=1.4.3=r36h0357c0b_1004 \n\
  - r-reticulate=1.14=r36h0357c0b_0 \n\
  - r-rex=1.1.2=r36h6115d3f_1001 \n\
  - r-rlang=0.4.4=r36hcdcec82_0 \n\
  - r-rmarkdown=2.1=r36h6115d3f_0 \n\
  - r-roxygen2=7.0.2=r36h0357c0b_0 \n\
  - r-rprojroot=1.3_2=r36h6115d3f_1002 \n\
  - r-rstudioapi=0.11=r36h6115d3f_0 \n\
  - r-rversions=2.0.1=r36h6115d3f_0 \n\
  - r-rvest=0.3.5=r36h6115d3f_0 \n\
  - r-scales=1.1.0=r36h6115d3f_0 \n\
  - r-selectr=0.4_2=r36h6115d3f_0 \n\
  - r-sessioninfo=1.1.1=r36h6115d3f_1001 \n\
  - r-shiny=1.4.0=r36h6115d3f_0 \n\
  - r-sourcetools=0.1.7=r36he1b5a44_1001 \n\
  - r-sp=1.3_2=r36hcdcec82_0 \n\
  - r-stringi=1.4.6=r36h0e574ca_0 \n\
  - r-stringr=1.4.0=r36h6115d3f_1 \n\
  - r-survival=3.1_8=r36hcdcec82_0 \n\
  - r-sys=3.3=r36hcdcec82_0 \n\
  - r-tensorflow=2.0.0=r36h6115d3f_0 \n\
  - r-testthat=2.3.1=r36h0357c0b_0 \n\
  - r-tfruns=1.4=r36h6115d3f_1001 \n\
  - r-tibble=2.1.3=r36hcdcec82_1 \n\
  - r-tidyr=1.0.2=r36h0357c0b_0 \n\
  - r-tidyselect=1.0.0=r36h6115d3f_0 \n\
  - r-tidyverse=1.3.0=r36h6115d3f_1 \n\
  - r-tinytex=0.19=r36h6115d3f_0 \n\
  - r-usethis=1.5.1=r36h6115d3f_1 \n\
  - r-utf8=1.1.4=r36hcdcec82_1001 \n\
  - r-vctrs=0.2.3=r36hcdcec82_0 \n\
  - r-vegan=2.5_6=r36h9bbef5b_0 \n\
  - r-viridislite=0.3.0=r36h6115d3f_1002 \n\
  - r-whisker=0.4=r36h6115d3f_0 \n\
  - r-withr=2.1.2=r36h6115d3f_1001 \n\
  - r-xfun=0.12=r36h6115d3f_0 \n\
  - r-xml2=1.2.2=r36h0357c0b_0 \n\
  - r-xopen=1.0.0=r36h6115d3f_1002 \n\
  - r-xtable=1.8_4=r36h6115d3f_2 \n\
  - r-yaml=2.2.1=r36hcdcec82_0 \n\
  - r-zeallot=0.1.0=r36h6115d3f_1001 \n\
  - readline=8.0=hf8c457e_0 \n\
  - sed=4.7=h1bed415_1000 \n\
  - tk=8.6.10=hed695b0_0 \n\
  - tktable=2.10=h555a92e_3 \n\
  - xorg-kbproto=1.0.7=h14c3975_1002 \n\
  - xorg-libice=1.0.10=h516909a_0 \n\
  - xorg-libsm=1.2.3=h84519dc_1000 \n\
  - xorg-libx11=1.6.9=h516909a_0 \n\
  - xorg-libxau=1.0.9=h14c3975_0 \n\
  - xorg-libxdmcp=1.1.3=h516909a_0 \n\
  - xorg-libxext=1.3.4=h516909a_0 \n\
  - xorg-libxrender=0.9.10=h516909a_1002 \n\
  - xorg-renderproto=0.11.1=h14c3975_1002 \n\
  - xorg-xextproto=7.3.0=h14c3975_1002 \n\
  - xorg-xproto=7.0.31=h14c3975_1007 \n\
  - xz=5.2.4=h14c3975_1001 \n\
  - zlib=1.2.11=h516909a_1006 \n\
  - zstd=1.4.4=h3b9ef0a_1 \n\
prefix: /usr/local/envs/seq2ml' > environment.yml

RUN \
  conda env create -f environment.yml -p ./vendor/conda/$BASE_ENV

RUN \
  echo "conda activate $BASE_ENV" > ~/.bashrc

RUN \
  R --vanilla -e 'keras::install_keras(tensorflow = "default")'

RUN \
  R --vanilla -e 'devtools::install_github("mikemc/speedyseq")'

ENTRYPOINT ["conda", "run", "-n", "phyloseq2ml", "R", "--version"]

