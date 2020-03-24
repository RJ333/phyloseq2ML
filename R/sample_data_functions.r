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
