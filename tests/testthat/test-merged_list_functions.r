test_that("Adds only 1 column to an input table", {
  merged <- phyloseq2ML::merge_input_response(subset_list_extra, 
    responses_final2)
  expect_equal(ncol(merged[[1]]), ncol(subset_list_extra[[1]]) + 1)
})

test_that("All combinations of input tables and response vars are created", {
  merged <- phyloseq2ML::merge_input_response(subset_list_extra, 
    responses_final2)
  expect_equal(length(merged), length(subset_list_extra) * ncol(responses_final2))
})

test_that("Breaks if response variables are not a data frame", {
  expect_error(phyloseq2ML::merge_input_response(subset_list_extra, 
    "response_variable"))
})

test_that("Breaks for repeated split values", {
  expect_error(phyloseq2ML::split_data(merged_input_tables, c(0.6, 0.6, 0.8)))
})

test_that("Breaks for non numeric split values", {
  expect_error(phyloseq2ML::split_data(merged_input_tables, c(0.6, "hello", 0.8)))
})

test_that("Breaks for values below 0 - 1 range", {
  expect_error(phyloseq2ML::split_data(merged_input_tables, c(0.6, -1)))
})

test_that("Breaks for values above 0 - 1 range", {
expect_error(phyloseq2ML::split_data(merged_input_tables, c(0.6, 3)))
})

test_that("Train and test set were created", {
  splitted <- phyloseq2ML::split_data(merged_input_tables, c(0.6, 0.8))
  expect_true(exists("train_set", where = splitted[[1]]))
  expect_true(exists("test_set", where = splitted[[1]]))
})


test_that("Breaks if train set does not exist for oversampling", {
  expect_error(phyloseq2ML::oversample(merged_input_tables, 1, 0.5))
})

test_that("Regression response is excluded from noise addition so each 
  response value appears at least as often as 1 + copy_number", {
  copies <- 3
  oversampled_regression <- oversample(splitted_input_regression, copies, 0.5)
  # count the minimal number of occurrences of DANT.2.6 concentrations
  min_occurrences <- min(table(oversampled_regression[[1]][["train_set"]][["DANT.2.6"]]))
  expect_equal(min_occurrences, copies + 1)
})

test_that("Oversampling is ignored for copy_number 0", {
  oversampled <- phyloseq2ML::oversample(splitted_input, 0, 0.5)
  expect_equal(nrow(oversampled[[1]][["train_set"]]), nrow(splitted_input[[1]][["train_set"]]))
})

test_that("Oversampling multiplies length of train set", {
  copies <- 3
  oversampled <- phyloseq2ML::oversample(splitted_input, copies, 0.5)
  expect_equal(nrow(oversampled[[1]][["train_set"]]), (copies + 1) * nrow(splitted_input[[1]][["train_set"]]))
})

test_that("Oversampling breaks for negative copy number", {
  expect_error(phyloseq2ML::oversample(splitted_input, -1, 0.5))
})

test_that("Oversampling breaks for non numeric copy number", {
  expect_error(phyloseq2ML::oversample(splitted_input, "hello", 0.03))
})

test_that("Oversampling breaks for negative noise factor", {
  expect_error(phyloseq2ML::oversample(splitted_input, 1, -0.5))
})

test_that("Oversampling breaks for non numeric noise_factor", {
  expect_error(phyloseq2ML::oversample(splitted_input, 1, "hello"))
})
