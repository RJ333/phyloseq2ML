#' Microbial communities in ammunition contaminated sediments.
#'
#' A dataset in form of a phyloseq object containing an ASV count table, 
#'   sample data and taxonomy data .
#'
#' @format A phyloseq object with 105 samples, 50 taxa and 93 sample variables
#'
"TNT_communities"

#' Renamed TNT communities.
#'
#' The phyloseq object `TNT_communities`with adjusted taxa names.
#'
#' @format A phyloseq object with 105 samples, 50 taxa and 93 sample variables
#'
"testps"

#' Dictionary for taxonomic level conversion.
#'
#' A list with vectors linking IDs (ASV/OTU/...) to their annotated taxonomic levels.
#'
#' @format A list with two vectors of taxonomic level Genus and Family
#' 
"taxa_vector_list"