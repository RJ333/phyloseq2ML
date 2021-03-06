% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/keras_classification.R
\name{build_the_model}
\alias{build_the_model}
\title{Build and compile keras sequential models with 2 hidden layers}
\usage{
build_the_model(
  train_data,
  Layer1_units,
  Layer2_units,
  classes,
  Dropout_layer1,
  Dropout_layer2,
  Dense_activation_function,
  Output_activation_function = NULL,
  Optimizer_function,
  Loss_function,
  Metric,
  ...
)
}
\arguments{
\item{train_data}{a table of training data}

\item{Layer1_units}{integer, number of units in the first hidden layer}

\item{Layer2_units}{integer, number of units in the second hidden layer}

\item{classes}{integer, number of classes and therefore number of units in 
the output layer, set to 1 for regression}

\item{Dropout_layer1}{numeric, ratio of dropout nodes for layer 1 between 0 and 1}

\item{Dropout_layer2}{numeric, ratio of dropout nodes for layer 2 between 0 and 1}

\item{Dense_activation_function}{char, activation function for the hidden layers}

\item{Output_activation_function}{char, activation function for the output layer,
(default: NULL, used for regression)}

\item{Optimizer_function}{char, the optimizer function}

\item{Loss_function}{char, the loss function}

\item{Metric}{char vector, which metrics to monitor}

\item{...}{further arguments}
}
\value{
a compiled keras sequential model with two hidden layers
}
\description{
This function can setup and compile sequential models. Please have a look at
[keras_model_sequential](https://keras.rstudio.com/reference/keras_model_sequential.html),
[layer_dense](https://keras.rstudio.com/reference/layer_dense.html) and 
[compile](https://keras.rstudio.com/reference/compile.html) for further details.
}
