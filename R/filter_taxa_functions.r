#' Remove ASV/OTU/etc from a phyloseq object based on relative abundance.
#'
#' This version of the filter_taxa function can be used with lists and 
#' lapply or for loops.
#'
#' @param phyloseq_object the object to be filtered
#' @param threshold this relative abundance in percentage have to appear for an ASV, 
#'   than all ASV reads are kept
#' @param num_samples the number of times (samples) the threshold has to be met
#'
#' @return The subsetted phyloseq object
#'
#' @export
filter_subsets <- function(phyloseq_object, threshold, num_samples = 1) {
  if (threshold <= 0) {
    stop("threshold is <= 0 %, filter would have no effect, 
      stopped function")
  } else if (threshold >= 100) {
    stop("threshold is >= 100 % relative abundance, stopped function")
  }
  if (num_samples <= 0)
    stop("number of samples is not larger 0, filter would have no effect, 
      stopped function")
  
  phyloseq_subset2 <- phyloseq::filter_taxa(phyloseq_object, function (x) {
    sum(x > threshold) >= num_samples }, prune = TRUE)
  return(phyloseq_subset2)
}

#' Create subsets of phyloseq objects based on ASV/OTU counts and taxa level.
#'
#' This subsetting function allows to create multiple combinations of subsets 
#' from a list of phyloseq objects. The lowest taxonomic level 
#' (usually ASV or OTU) is always included, further taxonomic levels can be 
#' specified as described below. The call to `phyloseq::tax_glom` can be slow, 
#' therefore package `speedyseq` is used, if installed.
#'
#' @param subset_list a list of phyloseq objects
#' @param thresholds an integer vector specifying the input
#'   to `filter_taxa(sum(x > threshold) >= num_samples)`, will be formatted with
#'   with digits after . later string splits
#' @param tax_ranks specifying the tax ranks to agglomerate in the form 
#'   of `setNames(c("To_genus", To_family), c("Genus", "Family"))`. 
#'   Here, "To_genus" is the corresponding taxonomic level in tax_table() and 
#'   "Genus" is appended to the name the agglomerated data.frame in the
#'   results list for later distinction. Check taxa rank using 
#'   `colnames(tax_table(TNT_communities))`
#' @param taxa_prefix The leading name of your taxa, e.g. `ASV` or `OTU`, 
#'   must not contain an underscore or white space
#' @param ... further argument passed on to filter_subsets()
#'
#' @return A list of subsetted community tables for each combination of 
#'   phyloseq_subset, thresholds and tax_ranks (+ ASV/OTU)
#' @export
create_community_table_subsets <- function(subset_list, thresholds, 
  tax_ranks = NULL, taxa_prefix, ...) {
  if (!is.list(subset_list))
    stop("Input needs to be a list")
  if (length(thresholds) < 1)
    stop("No count thresholds provided for subsetting")
  if (!is.character(taxa_prefix) | !length(taxa_prefix) == 1)
    stop("Please provide a single character string as name")
  if(grepl("_", taxa_prefix, fixed = TRUE))
     stop("taxa_prefix needs to be a string without underscores")
  
  subset_list_filtered <- list()
  filter_counter <- 0
  for (phyloseq_subset in subset_list) {
    filter_counter <- filter_counter + 1 
    for (threshold in thresholds) { 
      current_name <- paste(names(subset_list)[filter_counter], 
        threshold, "filtered", sep = "_")
      message <- paste("Generating subset:", current_name)
      futile.logger::flog.info(message)
      subset_list_filtered[[current_name]] <- filter_subsets(phyloseq_subset, threshold, ...)
    }
  }
  if (is.null(tax_ranks)) {
    futile.logger::flog.info("No taxonomic levels for agglomeration specified")
    names(subset_list_filtered) <- paste0(names(subset_list_filtered), ".", taxa_prefix)
    subset_list_comb <- subset_list_filtered
  } else {
    if(!requireNamespace("speedyseq", quietly = TRUE)) {
      futile.logger::flog.info("Applying taxonomic agglomeration, speed could be improved by installing speedyseq")
      subset_list_filtered_tax <- unlist(lapply(subset_list_filtered, function(xx) {
        lapply(tax_ranks, function(yy) {
          phyloseq::tax_glom(xx, taxrank = yy)
        }
        )}
      ))
    } else {
      futile.logger::flog.info("Applying taxonomic agglomeration")
      subset_list_filtered_tax <- unlist(lapply(subset_list_filtered, function(xx) {
        lapply(tax_ranks, function(yy) {
          speedyseq::tax_glom(xx, taxrank = yy)
        }
        )}
      ))
    }  
    names(subset_list_filtered) <- paste0(names(subset_list_filtered),  ".", taxa_prefix)
    subset_list_comb <- c(subset_list_filtered, subset_list_filtered_tax)
  }
  subset_list_comb
}  

#' Turn subsets of phyloseq objects into relative abundance data.frames.
#'
#' The provided list of phyloseq objects is turned to relative abundances 
#' in percentage. The community tables are converted to data.frames and stored
#' in a list. NaNs are turned into 0.
#'
#' @param subset_list a list of phyloseq objects
#'
#' @return A list of subsetted community tables as data.frames 
#'
#' @export
otu_table_to_df <- function(subset_list) {
  subset_list_matrix <- lapply(subset_list, function (x) {
    methods::as(phyloseq::otu_table(x), "matrix")}) 
  subset_list_matrix2 <- rapply(subset_list_matrix, 
    f = function(x) ifelse(is.nan(x), 0, x), how = "replace")
  subset_list_df <- lapply(subset_list_matrix2, as.data.frame)
  # reorder by column names
  subset_list_df <- lapply(subset_list_df, function(x) x[, names(x)])
  subset_list_df
}

#' Turn otu_table() of phyloseq objects to relative abundance
#'
#' The provided list of phyloseq objects is turned to relative abundances 
#' in percentage. 
#'
#' @param subset_list a list of phyloseq objects
#'
#' @return A list of phyloseq objects 
#'
#' @export
to_relative_abundance <- function(subset_list) {
  subset_list_rel <- lapply(subset_list, phyloseq::transform_sample_counts, 
    function(x) {(x / sum(x)) * 100})
  subset_list_rel
}