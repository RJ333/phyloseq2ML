library(phyloseq2ML)
data(TNT_communities)
ASV_thresholds <- c(1500)
tax_levels <- setNames(c("To_genus", "To_family"), c("Genus", "Family"))
tax_levels2 <- c("To_genus", "To_family")

# phyloseq objects as list
subset_list <- list(
  ps_V4_surface = TNT_communities
)

# tax levels parameter is NULL as default
subset_list_df <- process_subsets(
  subset_list = subset_list, 
  ASV_thresholds = ASV_thresholds,
  tax_levels = "blabla"
)
subset_list_df
