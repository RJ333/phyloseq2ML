test_that("Breaks for wrong structure of input list", {
  expect_error(phyloseq2ML::dummify_input_tables(splitted_input))
})

test_that("Response variable changed from factor to dummy", {
  dummified <- phyloseq2ML::dummify_input_tables(merged_input_tables)
  target_factor <- merged_input_tables[[1]][,ncol(merged_input_tables[[1]])]
  target_dummified <- dummified[[1]][,ncol(dummified[[1]])]
  expect_true(is.dummy(target_dummified))
  expect_true(is.factor(target_factor))
})

test_that("Returns unmodified table if no factor columns present", {
  dummified <- phyloseq2ML::dummify_input_tables(merged_input_regression)
  expect_equal(dummified[[1]], merged_input_regression[[1]])
})


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

test_that("Scaling took place on non-dummy columns setting mean to 0 and SD to 1", {
  scaled_keras <- phyloseq2ML::scaling(oversampled_keras)
  train_set <- scaled_keras[[1]][["train_set"]]
  dummy_columns <- names(train_set)[vapply(train_set, is.dummy, logical(1))]
  mean_scaled <- round(sum(apply(train_set[, !names(train_set) %in% dummy_columns], 2, mean)))
  standard_dev_scaled <- mean(apply(train_set[, !names(train_set) %in% dummy_columns], 2, stats::sd))
  expect_equal(mean_scaled, 0) 
  expect_equal(standard_dev_scaled, 1)
})

test_that("Scaling ignored response var: mean to 0 and SD to 1 are not true", {
  scaled_keras_regression <- phyloseq2ML::scaling(oversampled_keras_regression)
  train_set <- scaled_keras_regression[[1]][["train_set"]]
  # this time including the numeric response var
  mean_scaled <- mean(apply(train_set, 2, mean))
  standard_dev_scaled <- mean(apply(train_set, 2, stats::sd))
  # testing if two values are not equal
  expect_false(isTRUE(all.equal(mean_scaled, 0))) 
  expect_false(isTRUE(all.equal(standard_dev_scaled, 1)))
})

test_that("Breaks for wrong structure of input list", {
  expect_error(phyloseq2ML::scaling(merged_input_tables))
})