#dummify_input_tables
test_that("Breaks for wrong structure of input list", {
  expect_error(phyloseq2ML::dummify_input_tables(splitted_input))
})

test_that("Response variable changed from factor to dummy", {
  dummified <- phyloseq2ML::dummify_input_tables(merged_input_tables)
  target_factor <- merged_input_tables[[1]][,ncol(merged_input_tables[[1]])]
  target_dummified <- dummified[[1]][,ncol(dummified[[1]])]
  expect_true(all(is.dummy(target_dummified), is.factor(target_factor)))
})

test_that("Returns unmodified table if no factor columns present", {
  dummified <- phyloseq2ML::dummify_input_tables(merged_input_regression)
  expect_equal(dummified[[1]], merged_input_regression[[1]])
})


# scaling
test_that("Scaling returns unmodified response dummy col", {
  scaled_keras <- phyloseq2ML::scaling(oversampled_keras)
  target_scaled <- scaled_keras[[1]][["train_set"]][,ncol(scaled_keras[[1]][["train_set"]])]
  target_oversampled <- oversampled_keras[[1]][["train_set"]][,ncol(oversampled_keras[[1]][["train_set"]])]
  expect_equal(target_scaled, target_oversampled)
})

test_that("Scaling returns unmodified response regression col", {
  scaled_keras_regression <- phyloseq2ML::scaling(oversampled_keras_regression)
  target_scaled <- scaled_keras_regression[[1]][["train_set"]][,ncol(scaled_keras_regression[[1]][["train_set"]])]
  target_oversampled <- oversampled_keras_regression[[1]][["train_set"]][,ncol(oversampled_keras_regression[[1]][["train_set"]])]
  expect_equal(target_scaled, target_oversampled)
})

test_that("Scaling took place on non-dummy columns setting mean to 0", {
  scaled_keras <- phyloseq2ML::scaling(oversampled_keras)
  train_set <- scaled_keras[[1]][["train_set"]]
  dummy_columns <- names(train_set)[vapply(train_set, is.dummy, logical(1))]
  mean_scaled <- round(sum(apply(train_set[, !names(train_set) %in% dummy_columns], 2, mean)))
  expect_equal(mean_scaled, 0) 
})

test_that("Scaling took place on non-dummy columns setting SD to 1", {
  scaled_keras <- phyloseq2ML::scaling(oversampled_keras)
  train_set <- scaled_keras[[1]][["train_set"]]
  dummy_columns <- names(train_set)[vapply(train_set, is.dummy, logical(1))]
  standard_dev_scaled <- mean(apply(train_set[, !names(train_set) %in% dummy_columns], 2, stats::sd))
  expect_equal(standard_dev_scaled, 1)
})

test_that("Scaling ignored response var: SD to 1 not true for all columns", {
  scaled_keras_regression <- phyloseq2ML::scaling(oversampled_keras_regression)
  train_set <- scaled_keras_regression[[1]][["train_set"]]
  standard_dev_scaled <- mean(apply(train_set, 2, stats::sd))
  expect_false(isTRUE(all.equal(standard_dev_scaled, 1)))
})

test_that("Scaling ignored response var: mean to 0 not true for all columns", {
  scaled_keras_regression <- phyloseq2ML::scaling(oversampled_keras_regression)
  train_set <- scaled_keras_regression[[1]][["train_set"]]
  mean_scaled <- mean(apply(train_set, 2, mean))
  expect_false(isTRUE(all.equal(mean_scaled, 0))) 
})
test_that("Breaks for wrong structure of input list", {
  expect_error(phyloseq2ML::scaling(merged_input_tables))
})


# inputtables_to_keras
test_that("Breaks for wrong structure of input list", {
  expect_error(phyloseq2ML::inputtables_to_keras(merged_input_tables))
})

test_that("Detect dummy response labels for train set", {
  final <- phyloseq2ML::inputtables_to_keras(scaled_keras)
  train_target_scaled <- final[[1]][["trainset_labels"]]
  expect_true(is.dummy(train_target_scaled))
})

test_that("Detect dummy response labels for test set", {
  final <- phyloseq2ML::inputtables_to_keras(scaled_keras)
  test_target_scaled <- final[[1]][["testset_labels"]]
  expect_true(is.dummy(test_target_scaled))
})

test_that("Detect non-dummy response labels for regression train set", {
  final <- phyloseq2ML::inputtables_to_keras(scaled_keras_regression)
  train_target_scaled <- final[[1]][["trainset_labels"]]
  expect_true(!is.dummy(train_target_scaled) & is.numeric(train_target_scaled))
})

test_that("Detect non-dummy response labels for regression test set", {
  final <- phyloseq2ML::inputtables_to_keras(scaled_keras_regression)
  test_target_scaled <- final[[1]][["testset_labels"]]
  expect_true(!is.dummy(test_target_scaled) & is.numeric(test_target_scaled))
})

test_that("Train set exists and is not NULL", {
  final <- phyloseq2ML::inputtables_to_keras(scaled_keras)
  train_data <- final[[1]][["trainset_data"]]
  expect_true(!is.null(train_data))
})

test_that("Test set exists and is not NULL", {
  final <- phyloseq2ML::inputtables_to_keras(scaled_keras)
  test_data <- final[[1]][["testset_data"]]
  expect_true(!is.null(test_data))
})

test_that("Input and output list have same length", {
  final <- phyloseq2ML::inputtables_to_keras(scaled_keras)
  all_length <- unique(length(final), length(scaled_keras), length(oversampled_keras), length(splitted_keras))
  expect_equal(all_length, length(final))
})
