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
  if(!is.data.frame(response_data)) {
    stop("Provided response_data is not a data frame")
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

#' Replicate observations with added noise.
#'
#' This function creates copies of existing observations in the training set 
#' with a specified amount of noise added to each numeric variable/observation 
#' combination with a non-zero value using data.table. This includes taxa abundance and also 
#' sample data variables. Pure integer columns are ignored, as they are either 
#' all 0s or dummy columns (only 0 and 1) and represent factor levels. The 
#' response variable is also ignored. Copies are named according to this scheme: 
#' original: "Sample_1", first copy: "Sample_1.1", second copy: "Sample_1.2" etc
#' The actual work is performed by internal `augment_and_noise()` function.
#' 
#' @param splitted_list a list of complimentary training and test data sets named
#'   "train_set" and "test_set", e.g `mylist[[1]][["train_set"]]` and 
#'   `mylist[[1]][["test_set"]]` for the first list item
#' @param copy_number an integer specifying the number of copies, 0 means no 
#'   augmentation takes place and `noise_factor` is ignored
#' @param noise_factor a value >= 0 specifing the relative amount of noise randomly 
#'   added or substracted to/from the original value e.g. 0.05 == +-5 \% noise 
#' 
#' @return A list of lists, the list item name is updated to reflect the number 
#'   of copies and the noise value
#'
#' @export
augment <- function(splitted_list, copy_number, noise_factor) {
  
  if(!exists("train_set", where = splitted_list[[1]]))
    stop('Error: Provided list does not contain a training set at location 
      "splitted_list[[1]][["train_set"]].')
   
  augment_counter <- 0
  augmented_list <- list()

  # turn training sets to data.tables
  for (i in c(1:length(splitted_list))) { 
    splitted_list[[i]][[1]] <- data.table::as.data.table(
      splitted_list[[i]][[1]], keep.rownames = "Sample")
  }
  # generate name, then call actual augmentation function for each training table
  for (split_table in splitted_list) {
    augment_counter <- augment_counter + 1
    current_name <- paste(names(splitted_list)[augment_counter], 
      "copies", copy_number, "noise", noise_factor, sep = "_")
    
    augmented_list[[current_name]] <- augment_and_noise(
      split_table, copy_number, noise_factor)
  }
  augmented_list
}

#' Replicate observations with added noise.
#'
#' This function gets called by `augment` and creates copies of samples with
#' a specified amount of random noise. For more information see the docstring of
#' `augment`. 
#' The anonymous data.table function for replication and noise addition acts on
#' all columns which are numeric, but neither the response variable or 0/1 only
#' columns, as these are either dummy variables or empty columns. It copies each
#' row of a train set as often as defined by `copy_number` and adds or substracts
#' randomly the amount of `noise_factor`.
#' 
#' @param split_table a list consisting of "train_set" and "test_set"
#' @param copy_number an integer specifying the number of copies, 0 means no 
#'   augmentation takes place and `noise_factor` is ignored
#' @param noise_factor a value between 0 and 100 (100 equals 10,000 \% noise) 
#'   specifing the relative amount of noise randomly added or substracted to/from 
#'   the original value. e.g. 0.05 == +-5 \% noise
#' @import data.table 
#' 
#' @return A list of lists, the list item name is updated to reflect the number 
#'   of copies and the noise value
#'
augment_and_noise <- function(split_table, copy_number, noise_factor) {
  
  if (!is.numeric(copy_number)) {
    stop("Error: copy_number needs to be numeric")
  } else if (copy_number%%1 != 0) {
    stop("Error: copy_number needs to be an integer")
  } else if (copy_number < 0) {
    stop("Error: copy_number can't be negative")
  }
  
  if(!is.numeric(noise_factor)) {
    stop("Provided noise factor needs to be numeric") 
  } else if (!all(noise_factor >= 0 & noise_factor <= 100)) {
    stop("Provided split ratios are not in range 0 - 100") 
  }

  if (copy_number == 0) {
    futile.logger::flog.warn("No augmentation demanded, returning unmodified 
      list with updated names. Noise factor ignored.") 
    noise_factor <- 0
  }
  
  train_tmp <- split_table$train_set
  test_tmp <- split_table$test_set
  
  # select the column to add noise:
  all_numeric_cols <- names(train_tmp)[sapply(train_tmp, is.numeric)]
  response_col <- names(train_tmp)[ncol(train_tmp)]
  integer_cols <- names(train_tmp)[vapply(train_tmp, is.dummy, logical(1))]
  ignore_cols <- unique(c(integer_cols, response_col))
 
  # these are the columns to be modified with random noise
  noise_cols <- subset(all_numeric_cols, !all_numeric_cols %in% ignore_cols)
  
  # replicate samples and add random noise to each value
  noised_copies <- NULL
  . = Sample = NULL # due to NSE notes in R CMD check
  
  if (copy_number > 0) {
    noised_copies <- lapply(c(1:copy_number), function(current_copy) {
      data.table::copy(train_tmp)[,
        c("Sample", noise_cols) := c(.(paste(Sample, current_copy, sep = ".")), 
          .SD + .SD * sample(c(-noise_factor, noise_factor), 
          .N * ncol(.SD), TRUE)), .SDcols = noise_cols]
    })
  }
  
  # bind original and noised samples
  train_noised <- data.table::rbindlist(c(noised_copies, list(train_tmp)), use.names = FALSE)
  data.table::setDF(train_noised, rownames = train_noised$Sample)
  train_noised$Sample <- NULL
  # return as list
  list(train_set = train_noised, test_set = test_tmp)
}
