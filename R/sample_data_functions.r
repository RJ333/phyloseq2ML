#' Select sample data variables and add them to the count tables
#'
#' This function selects specified columns from the sample data of a phyloseq object
#' and iteratively merges each count table with the specified sample data columns.
#' Merging occurs using the row.names.
#' 
#' @param sample_data_names a vector of sample data variable names
#' @param phyloseq_object the phyloseq object containing the sample data
#' @param community_tables the list with relative abundance community tables
#' 
#' @return A list of the merged community + sample data tables as data.frames
#'
#' @export
add_sample_data <- function(sample_data_names, phyloseq_object, 
  community_tables) {
  
  if(class(phyloseq_object) != "phyloseq") {
    stop('Provided argument for "phyloseq_object" is not of class "phyloseq"')
  }
  if(!all(sample_data_names %in% names(phyloseq::sample_data(phyloseq_object)))) {
    stop("Sample data column names were not detected in phyloseq sample_data()")
  }
  full_sample_data <- as.data.frame(phyloseq::sample_data(phyloseq_object))
  select_sample_data <- full_sample_data[, names(full_sample_data) %in% sample_data_names]
  
  merge_counter <- 0
  community_sample_data_list <- list()
  for (community_table in community_tables) {
    merge_counter <- merge_counter + 1
    current_name <- names(community_tables)[merge_counter]
    tmp <- merge(community_table, select_sample_data, by = "row.names")
    row.names(tmp) <- tmp$Row.names
    tmp$Row.names <- NULL
    community_sample_data_list[[current_name]] <- tmp
  }
  community_sample_data_list
}

#' Extract response variable columns from phyloseq sample data slot
#'
#' This function extracts specified columns from the sample data slot of a 
#' phyloseq object. It also replaces underscores in those column headers with 
#' dots, as underscores are later used for string splitting.
#'
#' @param response_variables a vector of sample data variable names
#' @param phyloseq_object the according `sample_data()` will be looked up 
#'   to receive the response columns
#'
#' @return A data frame consisting of the specified columns from `sample_data()`
#'
#' @export 
extract_response_variable <- function(response_variables, phyloseq_object) {
  # check if provided values are valid
  if(class(phyloseq_object) != "phyloseq") {
    stop('Provided argument for "phyloseq_object" is not of class "phyloseq"')
  }
  if(!all(response_variables %in% names(phyloseq::sample_data(phyloseq_object)))) {
    stop("Response variable names were not detected in phyloseq sample_data()")
  }
  # get sample data, extract requested columns and replace `_` with `.`
  full_sample_data <- as.data.frame(phyloseq::sample_data(phyloseq_object))
  response_sample_data <- full_sample_data[, names(full_sample_data) %in% response_variables]
  names(response_sample_data) <- gsub(x = names(response_sample_data), pattern = "_", 
    replacement = "\\.")
  response_sample_data
}

#' Categorize continuous response variable columns
#'
#' This function is a wrapper for `categorize_binary()` and `categorize_multi()`, 
#' which place continuous values into classes and return factor columns. To add 
#' columns which are already factor columns as response variables use `cbind()` 
#' or `merge()` after this step.
#'
#' @param ML_mode How many classes should be generated? `binary_class`, 
#'   `multi_class` or `regression` are valid, `regression` returns unmodified
#'   response_data
#' @param response_data a data frame or tibble where the columns are the 
#'   continuous response variables
#' @param ... arguments passed on to `categorize_binary()` and `categorize_multi()`
#'
#' @return A data frame with factor columns containing the categorized response 
#'   variables or for `regression` the unmodified data frame
#'
#' @export 
categorize_response_variable <- function(ML_mode, response_data, ...) {
  if(!tibble::is_tibble(response_data) & !is.data.frame(response_data)) {
    stop("Provided response_data is neither a data frame nor a tibble")
  }
  # check if all columns and the breaks are numeric
  if(!all(sapply(response_data, is.numeric))) {
    stop("Provided data frame contains non-numeric columns")
  }
 
  # check if ML_mode is valid
  if(!ML_mode %in% c("binary_class", "multi_class", "regression")) {
    stop('Mode of analysis not valid, 
      please choose from "binary_class", "multi_class", "regression"')
  }
  if (ML_mode == "binary_class") {
    categorize_binary(response_data, ...)
    
  } else if (ML_mode == "multi_class") {
    categorize_multi(response_data, ...)
   
  } else if (ML_mode == "regression") {
    futile.logger::flog.info("No categorization required for regression, 
      returning unmodified data")
    response_data
  }
}

#' Categorize continuous values into two classes
#'
#' This function places continuous values into two classes. The first class is 
#' labelled `Negative` and the second `Positive`. By default, `Positive` is used 
#' as first factor level and therefore the class for which the metrics are 
#' later on calculated!! E.g. `True positive` are the true positives of class 
#' `Positive`.
#'
#' @param response_data a data frame or tibble where the columns are the continuous 
#'   response variables
#' @param my_breaks the intervals norders to form to bins, specified e.g. 
#'   as `c(-Inf, 2, Inf)`
#' @param Positive_first logical, shall `Positive` become the first factor level? 
#'   Defaults to `TRUE`
#'
#' @return A data frame with factor columns containing binary response variables
#'
#' @export
categorize_binary <- function(response_data, my_breaks, Positive_first) {
  futile.logger::flog.info("Separating response variable at value ", my_breaks,
    " into two classes: Positive and Negative")
   if(!is.numeric(my_breaks)) {
    stop("Provided my_breaks contain non-numeric values")
  }
  # Split continuous values into Negative and Positive based on my_breaks
  response_variables_binary <- as.data.frame(apply(response_data, 2, cut, 
    breaks = my_breaks, labels = c("Negative", "Positive")))
  
  # Make "positive" the first factor level in each column
  if(Positive_first) {
    for (column in names(response_variables_binary)) {
      response_variables_binary[[column]] <- stats::relevel(
        factor(response_variables_binary[[column]]), ref = "Positive")
    }
    row.names(response_variables_binary) <- row.names(response_data)
    futile.logger::flog.info("Positive set to first factor level")
    response_variables_binary

    
  } else {
    # Negative stays first factor level
    row.names(response_variables_binary) <- row.names(response_data)
    futile.logger::flog.info("Negative stays first factor level")
    response_variables_binary
  }
}

#' Using `multi_class`, the number and names of classes can be freely chosen.
#' The elements in `class_labels` need to be one less compared to the elements 
#' in `my_breaks`. Metrics will be calculated for each of the classes.
#' 
#' @param response_data a data frame or tibble where the columns are the continuous 
#'   response variables
#' @param my_breaks the intervals for the binning, specified as e.g. 
#'    `c(-Inf, 2, 4, 6, Inf)` 
#' @param class_labels desired names of the factor levels, Specified as e.g. 
#'   `c("Below2", "2to4", "4to6", "Above6")` for breaks `c(-Inf, 2, 4, 6, Inf)`.
#'   At least one value needs to be a character, the others are then coerced to
#'   class character
#' @return A data frame with factor columns containing the categorized 
#'   response variables
#'
#' @export
categorize_multi <- function(response_data, my_breaks, class_labels) {
   if(!is.numeric(my_breaks)) {
    stop("Provided my_breaks contain non-numeric values")
   }
  if(!is.character(class_labels)) {
    stop("Provided class_labels are not of type character")
  }
  futile.logger::flog.info("Multiple classes, factor levels are alphabetically sorted")
  response_variables_multi <- as.data.frame(apply(response_data, 2, cut, 
    breaks = my_breaks, labels = class_labels))
  row.names(response_variables_multi) <- row.names(response_data)
  response_variables_multi
}
      
