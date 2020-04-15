# test regression training
test_that("Length of output rows equals input rows times classes", {
  
  # run keras
  test_keras_regression_training$results <- purrr::pmap(
    cbind(test_keras_regression_training, .row = rownames(test_keras_regression_training)), 
    keras_regression, the_list = ready_keras_regression, master_grid = test_keras_regression_training)
  # unnest results dataframe to row
  keras_df_regression_training <- as.data.frame(tidyr::unnest(test_keras_regression_training, results))
  expect_equal(nrow(keras_df_regression_training), nrow(test_keras_regression_training))
})

test_that("Breaks for wrong input list", {
  expect_error(test_keras_regression_training$results <- purrr::pmap(
    cbind(test_keras_regression_training, .row = rownames(test_keras_regression_training)), 
    keras_regression, the_list = oversampled_keras_regression, 
    master_grid = test_keras_regression_training))
})

test_that("Breaks for missing columns in master_grid", {
  expect_error(test_keras_regression_training$results <- purrr::pmap(
    cbind(test_keras_regression_training, .row = rownames(test_keras_regression_training)), 
    keras_regression, the_list = oversampled_keras_regression, 
    master_grid = test_keras_regression_training[, c(1:8)]))
})

# test regression prediction
test_that("Length of output rows equals input rows times classes", {
  # run keras
  test_keras_regression_prediction$results <- purrr::pmap(
    cbind(test_keras_regression_prediction, .row = rownames(test_keras_regression_prediction)), 
    keras_regression, the_list = ready_keras_regression, master_grid = test_keras_regression_prediction)
  # unnest results dataframe to row
  keras_df_regression_prediction <- as.data.frame(tidyr::unnest(test_keras_regression_prediction, results))
  expect_equal(nrow(keras_df_regression_prediction), nrow(test_keras_regression_prediction))
})

test_that("Breaks if k_fold > 1 for prediction", {
  test_keras_regression_prediction$k_fold <- 2
  # run keras
  expect_error(purrr::pmap(
    cbind(test_keras_regression_prediction, .row = rownames(test_keras_regression_prediction)), 
    keras_regression, the_list = ready_keras_regression, master_grid = test_keras_regression_prediction))
})

test_that("Breaks if current_k_fold > 1 for prediction", {
  test_keras_regression_prediction$current_k_fold <- 2
  # run keras
  expect_error(purrr::pmap(
    cbind(test_keras_regression_prediction, .row = rownames(test_keras_regression_prediction)), 
    keras_regression, the_list = ready_keras_regression, master_grid = test_keras_regression_prediction))
})

# test store regression
test_that("Breaks if training_data is not a matrix", {
  empty_df <- data.frame()
  expect_error(store_regression_results(hist, timing = 0, true_values = c(0,5,4,3,2,5), 
    predicted_values = c(0,5,4,3,2,5), training_data = empty_df))
})

test_that("Breaks if training_data is an empty matrix", {
  empty_matrix <- matrix(, nrow = 0, ncol = 3)
  expect_error(store_regression_results(hist, timing = 0, true_values = c(0,5,4,3,2,5), 
    predicted_values = c(0,5,4,3,2,5), training_data = empty_matrix))
})

