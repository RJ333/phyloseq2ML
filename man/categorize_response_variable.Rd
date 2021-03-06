% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sample_data_functions.r
\name{categorize_response_variable}
\alias{categorize_response_variable}
\title{Categorize continuous response variable columns.}
\usage{
categorize_response_variable(ML_mode, response_data, ...)
}
\arguments{
\item{ML_mode}{How many classes should be generated? `classification` or 
`regression` are valid, `regression` returns unmodified response_data}

\item{response_data}{a data frame where the columns are the 
continuous response variables}

\item{...}{arguments passed on to `categorize()`}
}
\value{
A data frame with factor columns containing the categorized response 
  variables or for `regression` the unmodified data frame
}
\description{
This function is a wrapper for `categorize()`, 
which place continuous values into classes and return factor columns. To add 
columns which are already factor columns as response variables use `cbind()` 
or `merge()` after this step.
}
