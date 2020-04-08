#' Extract parameters from named input list.
#'
#' This function extracts specific parameters from first level named list items.
#' The data frame headers and length are set up using `initialize_results()`.
#' 
#' @param input_list the input list with named items on first level
#'
#' @return a data frame with one row per list item and a column for each parameter
#'
#' @export
extract_parameters <- function(input_list) {
  
  if(is.null(names(input_list))) {
    stop("Input list does not seem to have names")
  }
  
  result_table <- initialize_results(input_list)
  if(ncol(result_table) > nchar(gsub("[^_]", "", names(input_list)[1]))) {
    stop('List item names incorrectly formatted, they contain too few "_"')
  }
  
  result_table$ML_object <- names(input_list)
  result_table$Primerset <- as.factor(sapply(strsplit(
    as.character(names(input_list)), '_'), "[", 2))
  result_table$Subset <- as.factor(sapply(strsplit(
    as.character(names(input_list)), '_'), "[", 3))
  result_table$Target <- as.factor(sapply(strsplit(
    as.character(names(input_list)), '_'), "[", 6))
  result_table$Split_ratio <- as.numeric(sapply(strsplit(
    as.character(names(input_list)), '_'), "[", 7))
  result_table$Noise_copies <- as.numeric(sapply(strsplit(
    as.character(names(input_list)), '_'), "[", 9))
  result_table$Noise_factor <- as.numeric(sapply(strsplit(
    as.character(names(input_list)), '_'), "[", 11))
  result_table$Threshold <- as.numeric(sapply(strsplit(
    as.character(names(input_list)), '_'), "[", 4))
  
  tax_level_unclean <- sapply(strsplit(
    as.character(names(input_list)), '\\.'), "[", 2)
  result_table$Tax_level <- as.factor(sapply(strsplit(
    tax_level_unclean, '_'), "[", 1))
  
  result_table
}

#' This function sets up a parameter data frame.
#'
#' Based on the length of the input list items a data frame is prepared
#' with headers for all information that can be extracted from the list
#' items names.
#' 
#' @param input_list the list that will be used as input for machine learning
#'
#' @return an empty data frame with headers of length of input_table_list 

initialize_results <- function(input_list) {

  df_headers <- c("ML_object", "Primerset", "Subset", "Tax_level", "Threshold", 
    "Target", "Split_ratio", "Noise_copies", "Noise_factor")
  df_result <- stats::setNames(data.frame(matrix(ncol = length(df_headers), 
    nrow = length(input_list))), df_headers)
  df_result
}