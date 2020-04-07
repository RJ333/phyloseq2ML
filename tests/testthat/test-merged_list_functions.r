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