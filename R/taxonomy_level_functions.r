#' Creates a dictionary list to translate taxonomic levels
#'
#' This function creates a list containing the entries for a higher taxonomic 
#' level in relation to their low level unique identifier (i.e. OTUs or ASVs). 
#' The taxonomic levels can be specified and need to be present in `tax_table()`` 
#' of the respective phyloseq object
#' 
#' @param phyloseq_object the phyloseq object to extract the taxonomic information from
#' @param taxonomic_levels a character vector with taxa levels 
#'   e.g. from `colnames(phyloseq::tax_table(phyloseq_object))`
#' 
#' @return A list of vectors for each tax level with the corresponding unique 
#'   identifier as row name
#'
#' @export
create_taxonomy_lookup <- function(phyloseq_object, taxonomic_levels) {
  if(!all(taxonomic_levels %in% colnames(phyloseq::tax_table(phyloseq_object)))) {
    stop("Desired taxonomic levels were not detected in phyloseq tax_table()")
  }
  taxonomy_table <- phyloseq::tax_table(phyloseq_object)[, 
    colnames(phyloseq::tax_table(phyloseq_object)) %in% taxonomic_levels]
  
  tax_levels <- colnames(taxonomy_table)
  taxa_vector_list <- list()
  for (tax_level in tax_levels) {
    taxa_vector_list[[tax_level]] <- taxonomy_table[,tax_level]
  }
  futile.logger::flog.info("Taxonomy lookup vectors created for the following 
    taxonomic levels:", tax_levels, capture = TRUE)
  taxa_vector_list
}

#' Translate unique IDs such as ASV/OTUs to specified tax level
#'
#' This function translates a vector of given identifiers to the specified 
#' taxonomy level. The  lookup table required is generated by `create_taxonomy_lookup()`. 
#' 
#' @param ID a string with the ID name you want to translate
#' @param translate_to a string with the desired taxonomic rank for translation
#' @param lookup_table the list with all the lookup vectors created 
#'   by create_taxonomy_lookup().
#' @param na.rm a logical, default is TRUE. All IDs that were assigned as NA 
#'   on the specified taxonomic level will be removed. Use FALSE if same 
#'   length as input vector is required 
#'
#' @return A character vector of taxonomic annotations on the corresponding 
#'   taxonomic level per provided ID
#'
#' @export
translate_ID <- function(ID, translate_to, lookup_table, 
  na.rm = TRUE) {
  
  if(!translate_to %in% names(lookup_table)) {
    futile.logger::flog.warn("Available names: ", names(lookup_table), capture = TRUE)
    stop("\nThe taxonomic level ", translate_to, " is not found in the provided lookup table.")  
  }
  translated <- lookup_table[[translate_to]][ID]
  if (na.rm) {
    translated <- translated[!is.na(translated)]
  }
  as.character(translated)
}
