% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/keras_regression.R
\name{store_regression_results}
\alias{store_regression_results}
\title{Store results from keras tf regression training and prediction}
\usage{
store_regression_results(hist, true_values, predicted_values, training_data)
}
\arguments{
\item{hist}{the keras history object}

\item{true_values}{the values to be predicted from `trainset_labels` or `testset_labels`}

\item{predicted_values}{numerical vector of predicted values}

\item{training_data}{the training set data.frame}
}
\value{
A data frame with one row per keras run and class
}
\description{
This function extracts information from the keras model generated by training
or prediction and stores them in a data.frame. It compares the pre-
dicted values in training and prediction to their true values and calculates
various measures to describe the difference.
}
