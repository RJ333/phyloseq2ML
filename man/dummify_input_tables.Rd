% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/keras_prepare_functions.r
\name{dummify_input_tables}
\alias{dummify_input_tables}
\title{Turn response column levels into dummy variables.}
\usage{
dummify_input_tables(input_tables)
}
\arguments{
\item{input_tables}{a list of input tables before splitting or oversampling}
}
\value{
A list input_tables with factor variable turned into dummy variables
}
\description{
The factor columns of an input table must be turned into dummy variables so 
keras can work with it. This function detects factor columns and turns them 
into dummy columns. First, as many columns are created as there are factor 
levels in the origin column, so a 2-level factor column would be represented 
by two complementary columns consisting of 0s and 1s. However, these are 
dependent on each other, which is known as the dummy trap. Therefore, the first 
of a given number of dummy columns per factor column is removed. If no factor 
columns are detected, the list will be returned unmodified along with an info. 
The response column is ignored, as it will be modified later using 
`keras::to_categorical()`.
}
