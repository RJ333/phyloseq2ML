library(phyloseq2ML)
library(futile.logger)
flog.threshold(TRACE)

data(TNT_communities)

# modify phyloseq object
testps <- standardize_phyloseq_headers(
  phyloseq_object = TNT_communities, taxa_prefix = "ASV", use_sequences = FALSE)

# define subsetting parameters
ASV_thresholds <- c(1500)
selected_taxa_1 <- setNames(c("To_genus", "To_family"), c("Genus", "Family"))

# phyloseq objects as list
subset_list <- list(
  ps_V4_surface = TNT_communities
)

# tax levels parameter is NULL as default
subset_list_tax <- create_counttable_subsets(
  subset_list = subset_list, 
  ASV_thresholds = ASV_thresholds,
  tax_levels = selected_taxa_1)
subset_list_df <- to_relative_abundance(subset_list = subset_list_tax)
