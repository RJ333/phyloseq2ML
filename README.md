[![pipeline status](https://gitlab.io-warnemuende.de/janssen/r-package-seq2ml/badges/master/pipeline.svg)](https://gitlab.io-warnemuende.de/janssen/r-package-seq2ml/-/commits/master) [![coverage report](https://gitlab.io-warnemuende.de/janssen/r-package-seq2ml/badges/master/coverage.svg)](https://gitlab.io-warnemuende.de/janssen/r-package-seq2ml/-/commits/master) [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

# R package phyloseq2ML

## Main idea

This project is about developing an own R package. This package provides functions to extract microbial community data from a phyloseq object and use this as input for machine learning (ML) analysis.

## The reason

Machine learning algorithms are widely common in different areas of science and private businesses. However, in microbiology they deserve a little more attention as they offer useful functionalities for complex biology-derived data. Depending on the type of ML algorithm and sample complexity, they require a large amount of relatively expensive training data to train a model. But in recent years more and more large data sets (100s - 10000 of communities) were created. Especially when only a certain aspect is of interest, not every sample needs to be investigated by a researcher in great detail. ML is perfectly suited for this tasks and the overall design of many microbial studies as well. 
To facilate and promote the use of machine learning I want to provide an easy to handle work environment. The packages for microbiome and machine learning analyses do already exist, I just want to connect them.

## Where does the data come from?

As the name suggests, as data origin I'm using a phyloseq object, which can be slightly "enhanced" to make full use of this package's functionalities. Phyloseq makes sure that their objects have a standardized format. `phyloseq2ML` makes use of this format and prepares the data for ML. As you just read, this package is specifically about count data, usually based on 16S rRNA (gene) amplicon sequencing. However, any kind of data you can get into a phyloseq object can be used for ML afterwards.

## What Machine Learning types are supported?

So far I included connections to Random Forest analyses, which have shown great performances in classification and regression tests, in form of the package `ranger` and also `randomForest`.

The second group of algorithms are Artificial neural networks and in our case, more specifically feed forward multilayer perceptrons (MLP), using the `keras` package for R and the `tensorflow` backend. I have not tested other types of NN for microbiome data, but this should be no problem after you have formatted your data using `phyloseq2ML`.

## Anything else?

you can combine your sample and count table data as input object. Some analysis scripts for microbiome data are included, e.g. variable importance. You can use lists of phyloseq objects to reduce hands on time and some plotting standards are included. You can choose from the various taxonomic levels present in your data which one should be used.
