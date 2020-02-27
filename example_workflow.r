library(phyloseq2ML)
library(futile.logger)
flog.threshold(TRACE)

data(TNT_communities)
ASV_thresholds <- c(1500)
selected_taxa_1 <- setNames(c("To_genus", "To_family"), c("Genus", "Family"))

# phyloseq objects as list
subset_list <- list(
  ps_V4_surface = TNT_communities
)

# tax levels parameter is NULL as default
subset_list_df <- create_counttable_subsets(
  subset_list = subset_list, 
  ASV_thresholds = ASV_thresholds,
  tax_levels = selected_taxa_1
)
subset_list_df

otu_table(TNT_communities)
head(sample_data(TNT_communities))
