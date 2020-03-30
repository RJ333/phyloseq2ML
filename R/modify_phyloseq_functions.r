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

#' Add columns with unique lineages to phyloseq `tax_table()`
#'
#' This function modifies the phyloseq object in order to enable Machine learning
#' analysis on specified taxonomy ranks. phyloseq provides the `tax_glom()` function 
#' which allows to combine an `otu_table` at e.g. the Genus or Family level. 
#' However, not annotated taxa (`NA` or `unclassified`) at a given level will 
#' either be dropped or combined to e.g. one large Genus called `unclassified.
#' But an unannotated taxa might still be important for classification. This 
#' function keeps such information by incorporating the full unique lineage 
#' for each existing taxonomic rank by concatenating all higher level annotations.
#' The function than interleaves those newly generated columns with the existing
#' tax_table() so the positioning is what tax_glom() requires.
#' 
#' @param phyloseq_object The phyloseq object with the `tax_table()` to be 
#'   modified. This function assumes that ranks are hierarchically ordered, 
#'   starting with the highest taxonomic rank (e.g. Kingdom) as first column.
#'
#' @return The phyloseq object with a modified `tax_table()`
#'
#' @export
add_unique_lineages <- function(phyloseq_object) {
  
  if(class(phyloseq_object) != "phyloseq") {
    stop('Provided argument for "phyloseq_object" is not of class "phyloseq"')
  }
  
  tax_columns <- colnames(phyloseq::tax_table(phyloseq_object))
  interleaved <- rep(1:length(tax_columns), each = 2) + 
    (0:1) * length(tax_columns)
  
  unique_lineages <- list()
  for (tax_rank in tax_columns){ 
    unique_lineages[[paste("To", tax_rank, sep = "_")]] <- 
      as.vector(apply(phyloseq::tax_table(phyloseq_object)[, 
        c(1:which(tax_columns == tax_rank))], 1, paste, collapse = "_"))
  }
  
  unique_lineages_df <- as.data.frame(unique_lineages)
  phyloseq::tax_table(phyloseq_object) <- cbind(as.matrix(unique_lineages_df), 
    phyloseq::tax_table(phyloseq_object))[,interleaved]
  phyloseq_object
}
