[![pipeline status](https://gitlab.io-warnemuende.de/janssen/r-package-seq2ml/badges/master/pipeline.svg)](https://gitlab.io-warnemuende.de/janssen/r-package-seq2ml/-/commits/master) [![coverage report](https://gitlab.io-warnemuende.de/janssen/r-package-seq2ml/badges/master/coverage.svg)](https://gitlab.io-warnemuende.de/janssen/r-package-seq2ml/-/commits/master) [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

# R package phyloseq2ML


## Main idea and content

To facilitate and promote the use of machine learning (ML) in biological research I want to provide functionality to prepare count data for ML. The packages for microbiome and machine learning analyses do already exist, I just want to connect them.`phyloseq2ML` provides functions to extract data from a `phyloseq` object and use this as input for machine learning analysis. It also provides wrappers to run Machine Learning and create a set of performance metrics.


## Who could benefit from using this package?

People interested in Machine Learning and community data analysis, mostly. Especially those, who don't feel secure or equipped to run ML analyses in R.   As the name suggests, as data origin a `phyloseq` object is required. There is a lot of help available for this task. This can be slightly "enhanced" to make full use of this package's functionalities. `Phyloseq` makes sure that their objects have a standardized format. `phyloseq2ML` makes use of this format and prepares the data for ML. As you just read, this package is specifically about count data, usually based on 16S rRNA (gene) amplicon sequencing. 

However, any kind of data you can get into a `phyloseq` object can be used for ML afterwards. As `phyloseq` is optimized for organism-related data (counts, hierarchical taxonomy, sample data) you could easily use count tables and taxonomy e.g. acquired using microscopy or from a monitoring task. 


## The reason

Machine learning algorithms are widely common in different areas of science and private businesses. However, in microbiology (and biology in general I assume) they deserve a little more attention as they offer useful functionalities for complex biology-derived data. Depending on the type of ML algorithm and sample complexity, they require a large amount of relatively expensive training data to train a model. But in recent years more and more large data sets (100s - 10000 of communities) were created. Especially when only a certain aspect is of interest, not every sample needs to be investigated by a researcher in great detail (e.g. environmental monitoring). ML is perfectly suited for this tasks and the overall design of many microbial studies as well. 

The fine tuning of models can be a weary task (there are way more professional packages out there for this), but `phyloseq2ML` allows to create lists of specifically subsetted phyloseq objects which can be combined with parameter tuning. You can work on various taxonomic ranks, include abundance filtering steps and add sample data to the community composition to support the prediction.


## What Machine Learning types are supported?

So far I included connections to Random Forest analyses, which have shown great performances in classification and regression tests, in form of the package `ranger` and also `randomForest`.

The second group of algorithms are Artificial neural networks and in our case, more specifically feed forward multilayer perceptrons (MLP), using the `keras` package for R and the `tensorflow` backend. I have not tested other types of NN for microbiome data, but this should be no problem after you have formatted your data using `phyloseq2ML`.



# Install the package

```r
install.packages("remotes")
remotes::install_github("RJ333/phyloseq2ML")
```

# How to build the docker image for the CI

## Installation

### Set up CI

In order to use the CI, we use a modified docker image that builds on
`continuumio/miniconda3:latest` and has all dependencies already installed
defined in the conda environment as well as `keras`, `Tensorflow` and
`speedyseq`.

```bash
docker build . -t phyloseq2ml-runner
```

