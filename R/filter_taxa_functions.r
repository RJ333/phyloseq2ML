#' Remove ASVs from a phyloseq object.
#'
#' This version of the filter_taxa function can be used with lists and lapply or for loops.
#'
#' @param phyloseq_object the object to be filtered
#' @param threshold this amount of reads have to appear for an ASV, than all ASV reads are kept
#' @param num_samples the number of times the threshold has to be met
#'
#' @return The subsetted phyloseq object
#'
#' @export
filter_subsets <- function(phyloseq_object, threshold = 0, num_samples = 1) {
  if (threshold <= 0)
    stop("threshold is not larger 0, filter would have no effect, stopped function")
  if (num_samples <= 0)
    stop("number of samples is not larger 0, filter would have no effect, stopped function")
  
  phyloseq_subset2 <- phyloseq::filter_taxa(phyloseq_object, function (x) {
    sum(x > threshold) >= num_samples }, prune = TRUE)
  return(phyloseq_subset2)
}

#' Create subsets of phyloseq objects based on ASV/OTU counts and taxa level.
#'
#' This subsetting function allows to create multiple combinations of subsets from a
#' list of phyloseq objects. The lowest taxonomic level (usually ASV or OTU) is always included,
#' further taxonomic levels can be specified as described below, if they are available in the tax_table()
#' the ASV level. The read counts of the new subsets are then turned into relative abundance
#' and the count tables are finally stored as list of data.frames. NaNs are turned into 0.
#'
#' @param subset_list a list of phyloseq objects
#' @param ASV_thresholds an integer vector specifying the input to `filter_taxa(sum(x > ASV_threshold) >= 1)``
#' @param tax_levels specifying the tax levels to agglomerate in the form of `setNames(c("To_genus", To_family), c("Genus", "Family"))`. 
#'   Here, "To_genus" is the corresponding taxonomic level in tax_table() and "Genus" is appended to the name the agglomerated data.frame in the
#'   results list for later distinction. Check taxa level using `colnames(tax_table(TNT_communities))``
#' @param ... further argument passed on to filter_subsets()
#'
#' @return A list of subsetted data frames for each combination of phyloseq_subset, ASV_threshold and tax_levels (+ ASV/OTU)
#'
#' @export
process_subsets <- function(subset_list, ASV_thresholds, tax_levels = NULL, ...) {
  if (is.list(subset_list) == FALSE)
    stop("Input needs to be a list")
  if (length(ASV_thresholds) < 1)
    stop("No count thresholds provided for subsetting")
  
  subset_list_filtered <- list()
  filter_counter <- 0
  for (phyloseq_subset in subset_list) {
    filter_counter <- filter_counter + 1 
    for (current_threshold in ASV_thresholds) { 
      current_name <- paste(names(subset_list)[filter_counter], 
                            current_threshold, "filtered", sep = "_")
      print(paste0("Generating subset: ", current_name))
      subset_list_filtered[[current_name]] <- filter_subsets(phyloseq_subset, 
                                                             threshold = current_threshold, ...)
      
    }
  }
  if (is.null(tax_levels)) {
    print("No taxonomic levels for agglomeration specified")
    names(subset_list_filtered) <- paste0(names(subset_list_filtered), ".ASV")
    subset_list_comb <- subset_list_filtered
  } else {
    print("Applying taxonomic agglomeration")
    subset_list_filtered_tax <- unlist(lapply(subset_list_filtered, function(xx) {
      lapply(tax_levels, function(yy) {
        phyloseq::tax_glom(xx, taxrank = yy)
      }
      )}
    ))
  
    names(subset_list_filtered) <- paste0(names(subset_list_filtered), ".ASV")
    subset_list_comb <- c(subset_list_filtered, subset_list_filtered_tax)
  }
  print("Transforming remaining absolute counts into relative abundances [%]")
  subset_list_rel <- lapply(subset_list_comb, phyloseq::transform_sample_counts, 
                            function(x) {(x / sum(x)) * 100})
  subset_list_matrix <- lapply(subset_list_rel, function (x) {methods::as(phyloseq::otu_table(x), "matrix")}) 
  subset_list_matrix2 <- rapply(subset_list_matrix, 
                                f = function(x) ifelse(is.nan(x), 0, x), how = "replace")
  subset_list_df <- lapply(subset_list_matrix2, as.data.frame)
  print("Returning list with subsetted data.frames")
  subset_list_df
}
