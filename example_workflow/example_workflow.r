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
# get response variables
desired_response_vars <- c("TNT", "DANT_2.6")
response_variables <- extract_response_variable(
  response_variables = desired_response_vars, phyloseq_object = testps)
# cut response numeric values into 3 classes
responses_multi <- categorize_response_variable(
  ML_mode = "multi_class", 
  response_data = response_variables, 
  my_breaks = c(-Inf, 0, 3, Inf), 
  class_labels = c("none", "below_3", "above_3"))

# or for two classes
responses_binary <- categorize_response_variable(
  ML_mode = "binary_class", 
  response_data = response_variables, 
  my_breaks = c(-Inf, 0, Inf),
  Positive = TRUE)

responses_regression <- categorize_response_variable(
  ML_mode = "regression", 
  response_data = response_variables)

# merge the input tables with the response variables
merged_input_binary <- merge_input_response(subset_list_extra, responses_binary)
merged_input_multi <- merge_input_response(subset_list_extra, responses_multi)
merged_input_regression <- merge_input_response(subset_list_extra, responses_regression)

###### for keras

# dummify input tables for keras ANN
keras_dummy_binary <- dummify_input_tables(merged_input_binary)
keras_dummy_multi <- dummify_input_tables(merged_input_multi)
keras_dummy_regression <- dummify_input_tables(merged_input_regression)
splitted_keras_binary <- split_data(keras_dummy_binary, c(0.6, 0.8))
splitted_keras_multi <- split_data(keras_dummy_multi, c(0.6, 0.8))
splitted_keras_regression <- split_data(keras_dummy_regression, c(0.6, 0.8))

# oversampling
oversampled_keras_binary <- oversample(splitted_keras_binary, 2, 0.5)
oversampled_keras_multi <- oversample(splitted_keras_multi, 2, 0.5)
oversampled_keras_regression <- oversample(splitted_keras_regression, 2, 0.5)

# scaling
scaled_keras_binary <- scaling(oversampled_keras_binary)
scaled_keras_multi <- scaling(oversampled_keras_multi)
scaled_keras_regression <- scaling(oversampled_keras_regression)

# keras format
ready_keras_binary <- inputtables_to_keras(scaled_keras_binary)
ready_keras_multi <- inputtables_to_keras(scaled_keras_multi)
ready_keras_regression <- inputtables_to_keras(scaled_keras_regression)
str(ready_keras, max = 2)
str(ready_keras_regression, max = 2)

###### for ranger

# split merged list into training and test parts
splitted_input_binary <- split_data(merged_input_binary, c(0.6, 0.8))
splitted_input_multi <- split_data(merged_input_multi, c(0.6, 0.8))
splitted_input_regression <- split_data(merged_input_regression, c(0.6, 0.8))
str(splitted_input, max = 2)

# oversampling
oversampled_input_binary <- oversample(splitted_input_binary, 1, 0.5)
oversampled_input_multi <- oversample(splitted_input_multi, 1, 0.5)
oversampled_regression <- oversample(splitted_input_regression, 1, 0.5)

# set up a parameter data.frame
parameter_df <- extract_parameters(oversampled_input_multi)

##### when to refactor target variable?
hyper_grid <- expand.grid(
  ML_object = names(oversampled_input_multi),
  Number_of_trees = c(151),
  Mtry_factor = c(1),
  Importance_mode = c("none"),
  Cycle = 1:5)

master_grid <- merge(parameter_df, hyper_grid, by = "ML_object")
# string arguments needs to be passed as character, not factor level 
master_grid$Target <- as.character(master_grid$Target)

test_grid <- head(master_grid, 1)

# running ranger
master_grid$results <- purrr::pmap(cbind(master_grid, .row = rownames(master_grid)), 
    ranger_classification, the_list = oversampled_input, master_grid = master_grid, step = "training")
# extract list elements within data frame into rows
results_df <-  as.data.frame(tidyr::unnest(master_grid, results))
