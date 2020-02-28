#' Change naming style of the taxa in the phyloseq object.
#'
#' This function adapts the rows and the columns of the corresponding
#' phyloseq object to improve the reading. It adds 0s based
#' on the total amount of ASVs to enable correct sorting in R. If you imported
#' your data from dada2 and your current taxa names are the sequences (ASVs),
#' you can specify `use_sequences = TRUE` to move the sequences to the phyloseq
#' refseq() slot before renaming takes place
#'
#' @param phyloseq_object The phyloseq object with the taxa_names() to be modified.
#' @param taxa_name The leading name of your taxa, e.g. `ASV` or `OTU`
#' @param use_sequences Logical indicating whether your current taxa_names()
#'   are sequences which you want to have moved to the refseq() slot of the 
#'   returning phyloseq object
#'
#' @return The modified phyloseq object.
#'
#' @export
standardize_phyloseq_headers <- function(phyloseq_object, taxa_name, use_sequences) {
  if (!is.character(taxa_name) | !length(taxa_name) == 1)
    stop("Please provide a single character string as name")
  if (!is.logical(use_sequences))
    stop("Please enter TRUE or FALSE depending on whether your current
         taxa_names are sequences (ASVs from dada2 import)")
  number_seqs <- seq(phyloseq::ntaxa(phyloseq_object))
  length_number_seqs <- nchar(max(number_seqs))
  newNames <- paste0(taxa_name, formatC(number_seqs,
                                    width = length_number_seqs, flag = "0"))
  if (use_sequences == TRUE) {
    futile.logger::flog.warn("This will overwrite sequences currently 
      existing the refseq() slot")
    sequences <- phyloseq::taxa_names(phyloseq_object)
    names(sequences) <- newNames
  }
  phyloseq::taxa_names(phyloseq_object) <- newNames
  if (use_sequences == TRUE) {
    phyloseq::merge_phyloseq(phyloseq_object, Biostrings::DNAStringSet(sequences))
  } else if (use_sequences == FALSE) {
    phyloseq_object
  }
}  
