#' Select sample data variables and add them to the count tables
#'
#' This function selects specified columns from the sample data of a phyloseq object
#' and iteratively merges each count table with the specified sample data columns.
#' Merging occurs using the row.names.
#' 
#' @param phyloseq_object the phyloseq object containing the sample data
#' @param sample_data_names a vector of sample data variable names
#' @param count_tables the list with relative abundance count tables
#' @param add_sample_data logical whether additional sample data should be used
#' 
#' @return A list of the merged count + sediment data frames
#'
#' @export
add_sample_data <- function(add_sample_data = FALSE, sample_data_names = NULL, 
  phyloseq_object = NULL, count_tables) {
  
  if (!add_sample_data) {
    futile.logger::flog.info("No sample data to be added to count data sets. 
      Returning unmodified list.")
    count_tables
  } else {
    if(!all(sample_data_names %in% names(phyloseq::sample_data(phyloseq_object)))) {
      stop("Sample data column names were not detected in phyloseq sample_data()")
    }
    merge_counter <- 0
    count_sample_data_list <- list()
    
    full_sample_data <- as.data.frame(phyloseq::sample_data(phyloseq_object))
    select_sample_data <- full_sample_data[, names(full_sample_data) %in% sample_data_names]

    for (count_table in count_tables) {
      merge_counter <- merge_counter + 1
      current_name <- names(count_tables)[merge_counter]
      tmp <- merge(count_table, select_sample_data, by = "row.names")
      row.names(tmp) <- tmp$Row.names
      tmp$Row.names <- NULL
      count_sample_data_list[[current_name]] <- tmp
    }
  count_sample_data_list
  }
}
