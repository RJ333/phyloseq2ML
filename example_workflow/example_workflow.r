library(phyloseq)
library(phyloseq2ML)
library(futile.logger)
flog.threshold(TRACE)

data(TNT_communities)

# modify phyloseq object
TNT_communities <- add_unique_lineages(TNT_communities)
testps <- standardize_phyloseq_headers(
  phyloseq_object = TNT_communities, taxa_prefix = "ASV", use_sequences = FALSE)

# translate ASVs to genus
levels_tax_dictionary <- c("Family", "Genus")
taxa_vector_list <- create_taxonomy_lookup(testps, levels_tax_dictionary)
translate_ID(ID = c("ASV02", "ASV17"), tax_level = c("Genus"), taxa_vector_list)

# define subsetting parameters
thresholds <- c(1500)
selected_taxa_1 <- setNames(c("To_Genus", "To_Family"), c("Genus", "Family"))

# phyloseq objects as list
subset_list <- list(
  ps_V4_surface = testps
)

# tax levels parameter is NULL as default
subset_list_tax <- create_community_table_subsets(
  subset_list = subset_list, 
  thresholds = thresholds,
  tax_levels = selected_taxa_1)
subset_list_df <- to_relative_abundance(subset_list = subset_list_tax)
# add sample data columns to the count table
#names(sample_data(testps))
desired_sample_data <- c("TOC", "P_percent")
subset_list_extra <- add_sample_data(phyloseq_object = testps, 
  community_tables = subset_list_df, sample_data_names = desired_sample_data)
