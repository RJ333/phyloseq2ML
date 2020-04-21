#' Creates a dictionary list to translate taxonomic ranks
#'
#' This function creates a list containing the entries for a higher taxonomic 
#' rank in relation to their low rank unique identifier (i.e. OTUs or ASVs). 
#' The taxonomic ranks can be specified and need to be present in `tax_table()`` 
#' of the respective phyloseq object
#' 
#' @param phyloseq_object the phyloseq object to extract the taxonomic information from
#' @param taxonomic_ranks a character vector with taxa ranks 
#'   e.g. from `colnames(phyloseq::tax_table(phyloseq_object))`
#' 
#' @return A list of vectors for each tax rank with the corresponding unique 
#'   identifier as row name
#'
#' @export
create_taxonomy_lookup <- function(phyloseq_object, taxonomic_ranks) {
  if(!all(taxonomic_ranks %in% colnames(phyloseq::tax_table(phyloseq_object)))) {
    stop("Desired taxonomic ranks were not detected in phyloseq tax_table()")
  }
  taxonomy_table <- phyloseq::tax_table(phyloseq_object)[, 
    colnames(phyloseq::tax_table(phyloseq_object)) %in% taxonomic_ranks]
  
  tax_ranks <- colnames(taxonomy_table)
  taxa_vector_list <- list()
  for (tax_rank in tax_ranks) {
    taxa_vector_list[[tax_rank]] <- taxonomy_table[,tax_rank]
  }
  msg <- paste("Taxonomy lookup vectors created for taxonomic ranks:", tax_ranks)
  futile.logger::flog.info(msg)
  taxa_vector_list
}

#' Translate unique IDs such as ASV/OTUs to specified tax rank
#'
#' This function translates a vector of given identifiers to the specified 
#' taxonomy rank. The  lookup table required is generated by `create_taxonomy_lookup()`. 
#' 
#' @param ID a string with the ID name you want to translate
#' @param tax_rank a string with the desired taxonomic rank for translation
#' @param lookup_table the list with all the lookup vectors created 
#'   by create_taxonomy_lookup().
#' @param na.rm a logical, default is TRUE. All IDs that were assigned as NA 
#'   on the specified taxonomic rank will be removed. Use FALSE if same 
#'   length as input vector is required 
#'
#' @return A character vector of taxonomic annotations on the corresponding 
#'   taxonomic rank per provided ID
#'
#' @export
translate_ID <- function(ID, tax_rank, lookup_table, 
  na.rm = TRUE) {
  
  if(!tax_rank %in% names(lookup_table)) {
    futile.logger::flog.warn("Available names: ", names(lookup_table), capture = TRUE)
    stop("\nThe taxonomic rank ", tax_rank, " is not found in the provided lookup table.")  
  }
  translated <- lookup_table[[tax_rank]][ID]
  if (na.rm) {
    translated <- translated[!is.na(translated)]
  }
  as.character(translated)
}
