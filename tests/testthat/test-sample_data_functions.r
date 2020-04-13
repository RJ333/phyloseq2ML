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

test_that("Label for first bin is second factor level due to alphabetical sorting", {
  categorized <- phyloseq2ML::categorize_response_variable(ML_mode = "classification", 
    response_data = response_variables, my_breaks = c(-Inf, 0, Inf),class_labels = c("lower", "higher"))
  expect_equal(levels(categorized[["TNT"]])[2], "lower")
})

test_that("Length of levels is 2 for 2 bins", {
  categorized <- phyloseq2ML::categorize_response_variable(ML_mode = "classification", 
    response_data = response_variables, my_breaks = c(-Inf, 0, Inf), class_labels = c("below_0", "above_0"))
  expect_equal(length(levels(categorized[[1]])), 2)
})

test_that("Fails if class labels do not match bins", {
  expect_error(phyloseq2ML::categorize_response_variable(ML_mode = "classification", 
    response_data = response_variables, my_breaks = c(-Inf, 0, Inf), 
    class_labels = c("below_0", "above_0", "too_many")))
})

test_that("Length of levels equals bins and labels for multi classification", {
  categorized <- phyloseq2ML::categorize_response_variable(ML_mode = "classification", 
    response_data = response_variables, my_breaks = c(-Inf, 0, 3, 5, Inf), 
     class_labels = c("class1", "class2", "class3", "class4"))
  expect_equal(length(levels(categorized[[1]])), 4)
})

test_that("Breaks if length of levels does not equal bins and labels for multi classification", {
  expect_error(phyloseq2ML::categorize_response_variable(ML_mode = "classification", 
    response_data = response_variables, my_breaks = c(-Inf, 0, 3, 5, Inf), 
     class_labels = c("class1", "class2", "class3", "class4", "class5")))
})

test_that("Breaks if no label is of type character for multi classification", {
  expect_error(phyloseq2ML::categorize_response_variable(ML_mode = "classification", 
    response_data = response_variables, my_breaks = c(-Inf, 0, 3, 5, Inf), 
     class_labels = c(1, 2, 3, 4)))
})

test_that("Returns unmodified table for regression", {
  not_categorized <- phyloseq2ML::categorize_response_variable(ML_mode = "regression", 
    response_data = response_variables, my_breaks = c(-Inf, 0, 3, 5, Inf), 
     class_labels = c("class1", "class2", "class3", "class4", "class5"))
  expect_equal(not_categorized, response_variables)
})
