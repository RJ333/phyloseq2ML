#' Merge all read count tables with one column from meta data each
#'
#' This function merges the prepared input tables (consisting of community_tables
#' and optionally added sample data) with the prepared response data frame.
#' merging all count tables with all columns from the target meta data
#' so each combination of a given count table with one target column is
#' achieved.
#' 
#' @param count_table_list a list containing the named count tables
#' @param target_table a dataframe containing all columns of target variables
#'
#' @return a list of merged tables
#'
#' @export
combine_count_target <- function(count_table_list, target_table) {
  
  merge_col_counter <- 0
  column_counter <- 0
  merged_column_list <- list()

  for(table in count_table_list) {
    merge_col_counter <- merge_col_counter + 1
    for (column in names(target_table)) {
      column_counter <- column_counter + 1
      current_name <- paste(names(count_table_list)[merge_col_counter], 
        names(target_table)[column_counter], sep = "_")
      tmp <- merge(table, target_table[, column_counter, drop = FALSE], 
        by = "row.names")
      row.names(tmp) <- tmp$Row.names
      tmp$Row.names <- NULL
      merged_column_list[[current_name]] <- tmp
      rm(tmp)
    }
    column_counter <- 0
  }
  return(merged_column_list)
}


#' Split a list of data frames according to the ratio into training and test data
#'
#' This function applies a split to the data frames contained in the input list. It first groups the
#' data frames based on their number of rows. The same number indicates they originate from the same main
#' subset, but different ASV thresholds or tax level are present. Therefore, the samples for training and test
#' should be the same for comparison. Such data frames are combined as nested lists in the grouped_list. This
#' list is then split into train and test set for all data frames and ratios provided. The output list is already
#' flattened and with updated name, so the names are first level and train and test data frames are second level 
#' 
#' @param merged_column_list a list with data frames and the merged targed variable as last column
#' @param split_ratios a numerical vector of ratios from 0 - 1 indicating the training fraction after the split
#'
#' @return A list of lists, each data frame is split into train and test set, the name is updated to reflect the ratio value
#'
#' @export
split_dataset <- function(merged_column_list, split_ratios) {

  grouped_list <- split(merged_column_list, sapply(merged_column_list, nrow))
  
  data_list <- list()
  group_counter <- 0
  for (ratio in split_ratios) {
    for (group_item in grouped_list) {
    sample_vector <- sample.int(n = nrow(group_item[[1]]), 
      size = floor(ratio * nrow(group_item[[1]])), replace = FALSE)
      for (x_table in group_item) {
        group_counter <- group_counter + 1
        current_name <- paste(names(group_item)[group_counter], ratio, sep = "_")
        train_set <- x_table[sample_vector, ]
        test_set  <- x_table[-sample_vector, ]
        data_list[[current_name]] <- list(train_set = train_set, test_set = test_set)
      }
     group_counter <- 0
    }
  }
  data_list
}