#' Change naming style of the taxa in the phyloseq object.
#'
#' This function adapts the rows and the columns of the corresponding
#' phyloseq object to improve the reading. It adds 0s based
#' on the total amount of ASVs to enable correct sorting in R. If you imported
#' your data from dada2 and your current taxa names are the sequences (ASVs),
#' you can specify `use_sequences = TRUE` to move the sequences to the phyloseq
#' refseq() slot before renaming takes place. Existing sequences in the refseq()
#' slot will then be overwritten!
#'
#' @param phyloseq_object The phyloseq object with the taxa_names() to be modified
#' @param taxa_prefix The leading name of your taxa, e.g. `ASV` or `OTU`
#' @param use_sequences Logical indicating whether your current taxa_names()
#'   are sequences which you want to have moved to the refseq() slot of the 
#'   returning phyloseq object
#'
#' @return The modified phyloseq object
#'
#' @export
standardize_phyloseq_headers <- function(phyloseq_object, taxa_prefix, use_sequences) {
  if (!is.character(taxa_prefix) | !length(taxa_prefix) == 1)
    stop("Please provide a single character string as name")
  if (!is.logical(use_sequences))
    stop("Please enter TRUE or FALSE depending on whether your current
         taxa_prefixs are sequences (ASVs from dada2 import)")
  if (isTRUE(use_sequences)) {
    string_vector <- phyloseq::taxa_names(phyloseq_object)
    if(!all(grepl("A", string_vector) & grepl("T", string_vector) & 
        grepl("G", string_vector) & grepl("C", string_vector))) {
        futile.logger::flog.warn(
          "Your taxa_names() do not seem to contain DNA sequences")
    }
  }  
  number_seqs <- seq(phyloseq::ntaxa(phyloseq_object))
  length_number_seqs <- nchar(max(number_seqs))
  newNames <- paste0(taxa_prefix, formatC(number_seqs,
                                    width = length_number_seqs, flag = "0"))
  if (isTRUE(use_sequences)) {
    futile.logger::flog.warn("This will overwrite sequences currently 
      existing in the refseq() slot")
    sequences <- phyloseq::taxa_names(phyloseq_object)
    names(sequences) <- newNames
  }
  phyloseq::taxa_names(phyloseq_object) <- newNames
  if (isTRUE(use_sequences)) {
    phyloseq::merge_phyloseq(phyloseq_object, Biostrings::DNAStringSet(sequences))
  } else {
    phyloseq_object
  }
}  
