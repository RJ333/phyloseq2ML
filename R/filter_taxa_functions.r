#' Remove ASVs from a phyloseq object.
#'
#' This version of the filter_taxa function can be used with lists and lapply or for loops.
#'
#' @param phyloseq_object the object to be filtered
#' @param threshold this amount of reads have to appear for an ASV, than all ASV reads are kept
#' @param frequency the number of times the threshold has to be met
#'
#' @return The subsetted phyloseq object
#'
#' @export
filter_subsets <- function(phyloseq_object, threshold, frequency = 1) {
  phyloseq_subset2 <- phyloseq::filter_taxa(phyloseq_object, function (x) {
    sum(x > threshold) >= frequency }, prune = TRUE)
  return(phyloseq_subset2)
}

#' Create subsets of phyloseq objects with subsetting based on ASV reads and taxa level.
#'
#' This subsetting function allows to create multiple combinations of subsets from a
#' list of phyloseq object based on ASV thresholds for different taxa level, always including
#' the ASV level. The read counts of the new subsets are then turned into relative abundance
#' and the count tables are finally stored as list of data.frames. NaNs are turned into 0.
#'
#' @param subset_list a list of phyloseq objects
#' @param ASV_thresholds an integer vector specifying the input to filter_taxa(sum(x > ASV_threshold) >= 1)
#' @param tax_levels specifying the tax levels to agglomerate in the form of setNames(c("To_genus", To_family), c("Genus", "Family"))
#'
#' @return A list of subsetted data frames for each combination of phyloseq_subset, ASV_threshold and tax level + ASV
#'
#' @export
process_subsets_multi_tax <- function(subset_list, ASV_thresholds, tax_levels) {
  
  subset_list_filtered <- list()
  filter_counter <- 0
  for (phyloseq_subset in subset_list) {
    filter_counter <- filter_counter + 1 
    for (current_threshold in ASV_thresholds) { 
      current_name <- paste(names(subset_list)[filter_counter], 
                            current_threshold, "filtered", sep = "_")
      print(current_name)
      subset_list_filtered[[current_name]] <- filter_subsets(phyloseq_subset, 
                                                             threshold = current_threshold)	  
    }
  }
  
  subset_list_filtered_tax <- unlist(lapply(subset_list_filtered, function(xx) {
    lapply(tax_levels, function(yy) {
      phyloseq::tax_glom(xx, taxrank = yy)
    }
    )}
  ))
  
  names(subset_list_filtered) <- paste0(names(subset_list_filtered), ".ASV")
  subset_list_comb <- c(subset_list_filtered, subset_list_filtered_tax)
  subset_list_rel <- lapply(subset_list_comb, phyloseq::transform_sample_counts, 
                            function(x) {(x / sum(x)) * 100})
  subset_list_matrix <- lapply(subset_list_rel, function (x) {methods::as(phyloseq::otu_table(x), "matrix")}) 
  subset_list_matrix2 <- rapply(subset_list_matrix, 
                                f = function(x) ifelse(is.nan(x), 0, x), how = "replace")
  subset_list_df <- lapply(subset_list_matrix2, as.data.frame)
  subset_list_df
}
