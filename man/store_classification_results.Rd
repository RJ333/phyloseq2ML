% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/keras_classification.R
\name{store_classification_results}
\alias{store_classification_results}
\title{Store results from keras tf classification training and prediction}
\usage{
store_classification_results(
  hist,
  prediction_table,
  n_classes,
  confusion_matrix,
  train_data
)
}
\arguments{
\item{hist}{the keras history object}

\item{prediction_table}{the data.frame comparing predictions and true values}

\item{n_classes}{the number of classes for classification}

\item{confusion_matrix}{the confusion matrix generated from `prediction_table`}

\item{train_data}{the training set data.frame}
}
\value{
A data frame with one row per keras run and class
}
\description{
This function extracts information from the keras model generated by training
or prediction and stores them in a data.frame. By calling `classification_metrics` 
various metrics for classification performance are calculated for each class.
}
