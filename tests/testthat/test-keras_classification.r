# ... for pmap build the model: argument darf nicht vorher abgfangen werden, muss in funktion genauso heißen, ... müssen da sin

# test binary training
test_that("Length of output rows equals input rows times classes", {
  
  training_labels <- ready_keras_binary[[1]][["trainset_labels"]]
  classes <- ncol(training_labels)
  # run keras
  test_keras_binary_training$results <- purrr::pmap(
    cbind(test_keras_binary_training, .row = rownames(test_keras_binary_training)), 
    keras_classification, the_list = ready_keras_binary, master_grid = test_keras_binary_training)
  # unnest results dataframe to row
  keras_df_binary_training <- as.data.frame(tidyr::unnest(test_keras_binary_training, results))
  expect_equal(nrow(keras_df_binary_training), classes * nrow(test_keras_binary_training))
})

test_that("Breaks for wrong input list", {
  expect_error(test_keras_binary_training$results <- purrr::pmap(
    cbind(test_keras_binary_training, .row = rownames(test_keras_binary_training)), 
    keras_classification, the_list = augmented_keras_binary, 
    master_grid = test_keras_binary_training))
})

test_that("Breaks for missing columns in master_grid", {
  expect_error(test_keras_binary_training$results <- purrr::pmap(
    cbind(test_keras_binary_training, .row = rownames(test_keras_binary_training)), 
    keras_classification, the_list = augmented_keras_binary, 
    master_grid = test_keras_binary_training[, c(1:8)]))
})

# test multi prediction
test_that("Length of output rows equals input rows times classes", {
  
  prediction_labels <- ready_keras_multi[[1]][["trainset_labels"]]
  classes <- ncol(prediction_labels)
  test_keras_multi_prediction$k_fold <- 1
  test_keras_multi_prediction$current_k_fold <- 1
  # run keras
  test_keras_multi_prediction$results <- purrr::pmap(
    cbind(test_keras_multi_prediction, .row = rownames(test_keras_multi_prediction)), 
    keras_classification, the_list = ready_keras_multi, master_grid = test_keras_multi_prediction)
  # unnest results dataframe to row
  keras_df_multi_prediction <- as.data.frame(tidyr::unnest(test_keras_multi_prediction, results))
  expect_equal(nrow(keras_df_multi_prediction), classes * nrow(test_keras_multi_prediction))
})

test_that("Number of caes per class corresponds to TP + FN for each case, also
  Number of Samples fits number of predicted cases", {
  keras_trues <- table(augmented_keras_multi[[test_keras_multi_prediction$ML_object[1]]][["test_set"]][[as.character(
    test_keras_multi_prediction$Target[1])]])
  
  test_keras_multi_prediction$results <- purrr::pmap(cbind(test_keras_multi_prediction, .row = rownames(test_keras_multi_prediction)), 
    keras_classification, the_list = ready_keras_multi, master_grid = test_keras_multi_prediction)
  keras_testing <- as.data.frame(tidyr::unnest(test_keras_multi_prediction, results))
  
  result_sub_keras <- subset(keras_testing, ML_object == as.character(test_keras_multi_prediction$ML_object[1]))
  keras_predicteds <- result_sub_keras[["True_positive"]] + result_sub_keras[["False_negative"]]
  
  expect_true(all(result_sub_keras[["Number_of_samples_validate"]] == result_sub_keras[["True_positive"]] + 
      result_sub_keras[["False_negative"]] + result_sub_keras[["False_positive"]] + result_sub_keras[["True_negative"]]))
  expect_true(all(keras_predicteds %in% keras_trues))
})

test_that("Breaks if k_fold > 1 for prediction", {
  test_keras_multi_prediction$k_fold <- 2
  # run keras
  expect_error(purrr::pmap(
    cbind(test_keras_multi_prediction, .row = rownames(test_keras_multi_prediction)), 
    keras_classification, the_list = ready_keras_multi, master_grid = test_keras_multi_prediction))
})

test_that("Breaks if current_k_fold > 1 for prediction", {
  test_keras_multi_prediction$current_k_fold <- 2
  # run keras
  expect_error(purrr::pmap(
    cbind(test_keras_multi_prediction, .row = rownames(test_keras_multi_prediction)), 
    keras_classification, the_list = ready_keras_multi, master_grid = test_keras_multi_prediction))
})

# test store classification
test_that("Breaks for empty data.frames", {
  empty_df <- data.frame()
  expect_error(store_classification_results(hist, prediction_table = empty_df, 
    n_classes = 3, confusion_matrix = NULL, train_data = empty_df))
})

test_that("Breaks for non-data.frames", {
  expect_error(store_classification_results(hist, prediction_table = NULL, 
    n_classes = 3, confusion_matrix = NULL, train_data = empty_df))
})

# test reverse categorical
test_that("Reversing binary matrix to column works", {
  binary_matrix <- ready_keras_multi[[1]][["trainset_labels"]]
  column <- categoric_to_factor(ready_keras_multi[[1]][["trainset_labels"]])
  expect_equal(length(column), nrow(binary_matrix))
})

test_that("Reversing binary matrix results in one column", {
  expect_true(is.vector(categoric_to_factor(
    ready_keras_multi[[1]][["trainset_labels"]])))
})

test_that("Breaks for non matrix objects", {
  expect_error(is.vector(categoric_to_factor(
    parameter_df)))
})

# check if false positive and true negatives vice versa are correct
test_that("Checking number of samples", {
  # run keras
  test_keras_multi_prediction$results <- purrr::pmap(
    cbind(test_keras_multi_prediction, .row = rownames(test_keras_multi_prediction)), 
    keras_classification, the_list = ready_keras_multi, master_grid = test_keras_multi_prediction)
  keras_df_multi_prediction <- as.data.frame(tidyr::unnest(test_keras_multi_prediction, results))
  Negative_samples <- subset(keras_df_multi_prediction, Class == "below_3", select = c("Negative", "Positive"))
  print(Negative_samples)
  expect_equal(Negative_samples[1,1], Negative_samples[2,1])
  expect_equal(Negative_samples[1,2], Negative_samples[2,2])
})
