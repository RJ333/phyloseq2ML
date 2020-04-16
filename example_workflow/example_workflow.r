library(phyloseq)
library(phyloseq2ML)
library(futile.logger)
flog.threshold(TRACE)

data(TNT_communities)

# modify phyloseq object
TNT_communities2 <- add_unique_lineages(TNT_communities)
testps <- standardize_phyloseq_headers(
  phyloseq_object = TNT_communities2, taxa_prefix = "ASV", use_sequences = FALSE)

# translate ASVs to genus
levels_tax_dictionary <- c("Family", "Genus")
taxa_vector_list <- create_taxonomy_lookup(testps, levels_tax_dictionary)
translate_ID(ID = c("ASV02", "ASV17"), tax_level = c("Genus"), taxa_vector_list)

# define subsetting parameters
thresholds <- 1500
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
  ML_mode = "classification", 
  response_data = response_variables, 
  my_breaks = c(-Inf, 0, 3, Inf), 
  class_labels = c("none", "below_3", "above_3"))

# or for two classes
responses_binary <- categorize_response_variable(
  ML_mode = "classification", 
  response_data = response_variables, 
  my_breaks = c(-Inf, 0, Inf),
  class_labels = c("below_0", "above_0"))

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

keras_dummy_multi[[1]]

# oversampling
oversampled_keras_binary <- oversample(splitted_keras_binary, 2, 0.5)
oversampled_keras_multi <- oversample(splitted_keras_multi, 2, 0.5)
oversampled_keras_regression <- oversample(splitted_keras_regression, 2, 0.5)

# scaling
scaled_keras_binary <- scaling(oversampled_keras_binary)
scaled_keras_multi <- scaling(oversampled_keras_multi)
scaled_keras_regression <- scaling(oversampled_keras_regression)

scaled_keras_multi[[1]][["train_set"]]

# keras format
ready_keras_binary <- inputtables_to_keras(scaled_keras_binary)
ready_keras_multi <- inputtables_to_keras(scaled_keras_multi)
ready_keras_regression <- inputtables_to_keras(scaled_keras_regression)
str(ready_keras_binary, max = 2)

ready_keras_multi[[1]][["trainset_labels"]]

###### for ranger

# split merged list into training and test parts
splitted_input_binary <- split_data(merged_input_binary, c(0.6, 0.8))
splitted_input_multi <- split_data(merged_input_multi, c(0.6, 0.8))
splitted_input_regression <- split_data(merged_input_regression, c(0.6, 0.8))


# oversampling
oversampled_input_binary <- oversample(splitted_input_binary, 1, 0.5)
oversampled_input_multi <- oversample(splitted_input_multi, 1, 0.5)
oversampled_regression <- oversample(splitted_input_regression, 1, 0.5)

####### ranger classification
# set up a parameter data.frame
parameter_df <- extract_parameters(oversampled_input_multi)

hyper_grid <- expand.grid(
  ML_object = names(oversampled_input_multi),
  Number_of_trees = c(151),
  Mtry_factor = c(1),
  Importance_mode = c("none"),
  Cycle = 1:5,
  step = "training")

master_grid <- merge(parameter_df, hyper_grid, by = "ML_object")
# string arguments needs to be passed as character, not factor level 
master_grid$Target <- as.character(master_grid$Target)

test_grid <- head(master_grid, 2)

master_grid$results <- purrr::pmap(cbind(master_grid, .row = rownames(master_grid)), 
    ranger_classification, the_list = oversampled_input_multi, master_grid = master_grid)
results_df <-  as.data.frame(tidyr::unnest(master_grid, results))

#### ranger regression
parameter_regress <- extract_parameters(oversampled_regression)

hyper_grid_regress <- expand.grid(
  ML_object = names(oversampled_regression),
  Number_of_trees = c(151),
  Mtry_factor = c(1),
  Importance_mode = c("none"),
  Cycle = 1:5,
  step = "prediction")

master_grid_regress <- merge(parameter_regress, hyper_grid_regress, by = "ML_object")
master_grid_regress$Target <- as.character(master_grid_regress$Target)
test_grid_regress <- head(master_grid_regress, 1)

# running ranger
master_grid_regress$results <- purrr::pmap(cbind(master_grid_regress, .row = rownames(master_grid_regress)), 
    ranger_regression, the_list = oversampled_regression, master_grid = master_grid_regress)
results_regress <-  as.data.frame(tidyr::unnest(master_grid_regress, results))

test_grid_regress$results <- purrr::pmap(cbind(test_grid_regress, .row = rownames(test_grid_regress)), 
    ranger_regression, the_list = oversampled_regression, master_grid = test_grid_regress)
results_regress_test <-  as.data.frame(tidyr::unnest(test_grid_regress, results))


####### for keras multi
# set up a parameter data.frame
parameter_keras_multi <- extract_parameters(ready_keras_multi)

hyper_keras_multi <- expand.grid(
  ML_object = names(ready_keras_multi),
  Epochs = 5, 
  Batch_size = 2, 
  k_fold = 1, 
  current_k_fold = 1,
  Early_callback = "accuracy", #prediction: "accuracy", training: "val_loss"
  Layer1_units = 20,
  Layer2_units = 8,
  Dropout_layer1 = 0.2,
  Dropout_layer2 = 0.0,
  Dense_activation_function = "relu",
  Output_activation_function = "softmax", # sigmoid for binary
  Optimizer_function = "rmsprop",
  Loss_function = "categorical_crossentropy", # binary_crossentropy for binary
  Metric = "accuracy",
  Cycle = 1:3,
  step = "prediction",
  Classification = "multiclass",
  Delay = 2)

master_keras_multi <- merge(parameter_keras_multi, hyper_keras_multi, by = "ML_object")
# order by current_k_fold 
master_keras_multi <- master_keras_multi[order(
  master_keras_multi$ML_object, 
  master_keras_multi$Cycle, 
  master_keras_multi$current_k_fold), ]

test_keras_multi_prediction <- head(master_keras_multi, 2)

test_keras_multi_prediction$results <- purrr::pmap(cbind(test_keras_multi_prediction, .row = rownames(test_keras_multi_prediction)), 
  keras_classification, the_list = ready_keras_multi, master_grid = test_keras_multi_prediction)
keras_df_multi_prediction <-  as.data.frame(tidyr::unnest(test_keras_multi_prediction, results))

####### for keras binary
# set up a parameter data.frame
parameter_keras_binary <- extract_parameters(ready_keras_binary)

hyper_keras_binary <- expand.grid(
  ML_object = names(ready_keras_binary),
  Epochs = 5, 
  Batch_size = 2, 
  k_fold = 4, 
  current_k_fold = 1:4,
  Early_callback = "val_loss", #prediction: "accuracy", training: "val_loss"
  Layer1_units = 20,
  Layer2_units = 8,
  Dropout_layer1 = 0.2,
  Dropout_layer2 = 0.0,
  Dense_activation_function = "relu",
  Output_activation_function = "softmax", # sigmoid for binary
  Optimizer_function = "rmsprop",
  Loss_function = "categorical_crossentropy", # binary_crossentropy for binary
  Metric = "accuracy",
  Cycle = 1:3,
  step = "training",
  Classification = "binary",
  Delay = 2)

master_keras_binary <- merge(parameter_keras_binary, hyper_keras_binary, by = "ML_object")
master_keras_binary <- master_keras_binary[order(
  master_keras_binary$ML_object, 
  master_keras_binary$Cycle, 
  master_keras_binary$current_k_fold), ]

test_keras_binary_training <- head(master_keras_binary, 2)

test_keras_binary_training$results <- purrr::pmap(cbind(test_keras_binary_training, .row = rownames(test_keras_binary_training)), 
  keras_classification, the_list = ready_keras_binary, master_grid = test_keras_binary_training)
keras_df_binary_training <-  as.data.frame(tidyr::unnest(test_keras_binary_training, results))

####### for keras regression
# set up a parameter data.frame
parameter_keras_regression <- extract_parameters(ready_keras_regression)

hyper_keras_regression_training <- expand.grid(
  ML_object = names(ready_keras_regression),
  Epochs = 5, 
  Batch_size = 2, 
  k_fold = 4, 
  current_k_fold = 1:4,
  Early_callback = "mae",
  Layer1_units = 20,
  Layer2_units = 8,
  Dropout_layer1 = 0.2,
  Dropout_layer2 = 0.0,
  Dense_activation_function = "relu",
  Optimizer_function = "rmsprop",
  Loss_function = "mse",
  Metric = "mae",
  Cycle = 1:3,
  step = "training",
  Delay = 2)

master_keras_regression_training <- merge(parameter_keras_regression, hyper_keras_regression_training, by = "ML_object")
master_keras_regression_training <- master_keras_regression_training[order(
  master_keras_regression_training$ML_object, 
  master_keras_regression_training$Cycle, 
  master_keras_regression_training$current_k_fold), ]

test_keras_regression_training <- head(master_keras_regression_training, 2)

test_keras_regression_training$results <- purrr::pmap(cbind(test_keras_regression_training, .row = rownames(test_keras_regression_training)), 
  keras_regression, the_list = ready_keras_regression, master_grid = test_keras_regression_training)
keras_df_regression_training <-  as.data.frame(tidyr::unnest(test_keras_regression_training, results))

#### regression prediction
hyper_keras_regression_prediction <- expand.grid(
  ML_object = names(ready_keras_regression),
  Epochs = 5, 
  Batch_size = 2, 
  k_fold = 1, 
  current_k_fold = 1,
  Early_callback = "mae",
  Layer1_units = 20,
  Layer2_units = 8,
  Dropout_layer1 = 0.2,
  Dropout_layer2 = 0.0,
  Dense_activation_function = "relu",
  Optimizer_function = "rmsprop",
  Loss_function = "mse",
  Metric = "mae",
  Cycle = 1:3,
  step = "prediction",
  Delay = 2)

master_keras_regression_prediction <- merge(parameter_keras_regression, hyper_keras_regression_prediction, by = "ML_object")
master_keras_regression_prediction <- master_keras_regression_prediction[order(
  master_keras_regression_prediction$ML_object, 
  master_keras_regression_prediction$Cycle, 
  master_keras_regression_prediction$current_k_fold), ]

test_keras_regression_prediction <- head(master_keras_regression_prediction, 2)

test_keras_regression_prediction$results <- purrr::pmap(cbind(test_keras_regression_prediction, .row = rownames(test_keras_regression_prediction)), 
  keras_regression, the_list = ready_keras_regression, master_grid = test_keras_regression_prediction)
keras_df_regression_prediction <-  as.data.frame(tidyr::unnest(test_keras_regression_prediction, results))
