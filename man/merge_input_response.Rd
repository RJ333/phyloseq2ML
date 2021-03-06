% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/merged_list_functions.r
\name{merge_input_response}
\alias{merge_input_response}
\title{Merge all community tables with each response variable.}
\usage{
merge_input_response(input_tables, response_data)
}
\arguments{
\item{input_tables}{a list containing the community (+ sample data) tables}

\item{response_data}{a dataframe containing the response variables}
}
\value{
a list of merged tables, each generated from an input table and one 
  column of the response data frame
}
\description{
This function merges the prepared input tables (consisting of community tables
and optionally added sample data) with the prepared response data frame.
All input tables are merged with each variable from the response data, so each 
combination of a given input table with a single response variable is
achieved.
}
