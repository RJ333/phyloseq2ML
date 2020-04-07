#' Merge all community tables with each response variable.
#'
#' This function merges the prepared input tables (consisting of community tables
#' and optionally added sample data) with the prepared response data frame.
#' All input tables are merged with each variable from the response data, so each 
#' combination of a given input table with a single response variable is
#' achieved.
#' 
#' @param input_tables a list containing the community (+ sample data) tables
#' @param response_data a dataframe containing the response variables
#'
#' @return a list of merged tables, each generated from an input table and one 
#'   column of the response data frame
#'
#' @export
merge_input_response <- function(input_tables, response_data) {
  if(!(tibble::is_tibble(response_data) | is.data.frame(response_data))) {
    stop("Provided response_data is neither a data frame nor a tibble")
  }
  input_counter <- 0
  response_counter <- 0
  merged_list <- list()

  for(input_table in input_tables) {
    input_counter <- input_counter + 1
    for (column in names(response_data)) {
      response_counter <- response_counter + 1
      current_name <- paste(names(input_tables)[input_counter], 
        names(response_data)[response_counter], sep = "_")
      # merge iteratively one of the columns of the response data frame
      tmp <- merge(input_table, response_data[, response_counter, drop = FALSE], 
        by = "row.names")
      row.names(tmp) <- tmp$Row.names
      tmp$Row.names <- NULL
      merged_list[[current_name]] <- tmp
    }
    response_counter <- 0
  }
  return(merged_list)
}

#' Split data frames according to a ratio into training and test sets.
#'
#' This function applies a split to the data frames contained in the input list. 
#' It first groups the data frames based on their number of rows. It then iterates
#' over the data frames in each group and the provided split ratios to separate
#' each data frame into a train and a test set. A nested list is returned having
#' the names as first level and the respective split data sets on second level. 
#' 
#' @param merged_list a list of data frames
#' @param split_ratios a numerical vector of ratios from 0 to 1 indicating the 
#'   training fraction after the split, e.g. `c(0.75, 0.8)` for two rounds of
#'   splits with resulting training sets of 75 and 80 percent of the total samples
#'
#' @return A named nested list, containing both parts of the splitted data frame. 
#'   The name is updated to reflect the split ratio
#'
#' @export
split_data <- function(merged_list, split_ratios) {
  if(!is.numeric(split_ratios)) {
    stop("Provided split ratios contain non-numeric values")
  }
  if(!all(split_ratios >= 0 & split_ratios <= 1)) {
    stop("Provided split ratios are not in range 0 - 1")
  }
  if(!identical(unique(split_ratios), split_ratios)) {
    stop("Some split ratio values are duplicated, resulting splits will not be 
      distinguished by name")
  }
  # group input tables by number of observations
  grouped_list <- split(merged_list, sapply(merged_list, nrow))
  
  splitted_list <- list()
  group_counter <- 0
  for (ratio in split_ratios) {
    for (group_item in grouped_list) {
    # generate a subsetting index based on the split ratio for each group
    sample_size <- nrow(group_item[[1]])
    sample_vector <- sample.int(n = sample_size, size = floor(ratio * sample_size), 
      replace = FALSE)
      for (input_table in group_item) {
        # perform split for each data frame
        group_counter <- group_counter + 1
        # add split ratio to name
        current_name <- paste(names(group_item)[group_counter], ratio, sep = "_")
        train_set <- input_table[sample_vector, ]
        test_set  <- input_table[-sample_vector, ]
        splitted_list[[current_name]] <- list(train_set = train_set, test_set = test_set)
      }
     group_counter <- 0
    }
  }
  splitted_list
}
