test_that("Final table columns should increase by number of sample_data columns specified", {
  expect_equal(ncol(phyloseq2ML::add_sample_data(phyloseq_object = testps, 
    community_tables = subset_list_df, sample_data_names = c("TIC", "TOC"))[[1]]) - 2, 
    ncol(subset_list_df[[1]]))
})

test_that("Break if columns are not available", {
  expect_error(phyloseq2ML::add_sample_data(phyloseq_object = testps, 
    community_tables = subset_list_df, sample_data_names = "not_existent"))
})

test_that("Break if argument to phyloseq_object is not of class phyloseq ", {
  expect_error(phyloseq2ML::add_sample_data(phyloseq_object = 5, 
    community_tables = subset_list_df, sample_data_names = "TIC"))
})

test_that("Break if argument to phyloseq_object is not of class phyloseq", {
  expect_error(phyloseq2ML::extract_response_variable(phyloseq_object = 5, 
    response_variables = "TNT"))
})

test_that("Break if columns are not available", {
  expect_error(phyloseq2ML::extract_response_variable(phyloseq_object = testps, 
    response_variables = "not_existent"))
})

test_that("Check that underscores are converted to dots", {
  expect_equal(names(phyloseq2ML::extract_response_variable(phyloseq_object = testps, 
    response_variables = "DANT_2.6")), "DANT.2.6")
})

test_that("TNT Positive is first level when TRUE", {
  expect_equal(levels(phyloseq2ML::categorize_response_variable(ML_mode = "binary_class", 
    response_data = response_variables, my_breaks = c(-Inf, 0, Inf), 
     class_labels = NULL, Positive_first = TRUE)[[1]])[1], "Positive")
})

test_that("TNT Negative is first level when FALSE", {
  expect_equal(levels(phyloseq2ML::categorize_response_variable(ML_mode = "binary_class", 
    response_data = response_variables, my_breaks = c(-Inf, 0, Inf), 
     class_labels = NULL, Positive_first = FALSE)[[1]])[1], "Negative")
})

test_that("Length of levels is 2 for binary classification", {
  expect_equal(length(levels(phyloseq2ML::categorize_response_variable(ML_mode = "binary_class", 
    response_data = response_variables, my_breaks = c(-Inf, 0, Inf), 
     class_labels = NULL, Positive_first = TRUE)[[1]])), 2)
})

test_that("Length of levels equals bins and labels for multi classification", {
  expect_equal(length(levels(phyloseq2ML::categorize_response_variable(ML_mode = "multi_class", 
    response_data = response_variables, my_breaks = c(-Inf, 0, 3, 5, Inf), 
     class_labels = c("class1", "class2", "class3", "class4"), Positive_first = TRUE)[[1]])), 4)
})

test_that("Breaks if length of levels does not equal bins and labels for multi classification", {
  expect_error(length(levels(phyloseq2ML::categorize_response_variable(ML_mode = "multi_class", 
    response_data = response_variables, my_breaks = c(-Inf, 0, 3, 5, Inf), 
     class_labels = c("class1", "class2", "class3", "class4", "class5"), Positive_first = TRUE)[[1]])))
})

test_that("Returns unmodified table for regression", {
  expect_equal(phyloseq2ML::categorize_response_variable(ML_mode = "regression", 
    response_data = response_variables, my_breaks = c(-Inf, 0, 3, 5, Inf), 
     class_labels = c("class1", "class2", "class3", "class4", "class5"), Positive_first = TRUE), response_variables)
})


