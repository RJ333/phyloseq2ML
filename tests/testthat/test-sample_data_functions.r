test_that("Count column number with and without added sample data to count tables", {
  expect_equal(ncol(3 + phyloseq2ML::add_sample_data(add_sample_data = TRUE, phyloseq_object = testps, 
    count_tables = subset_list_df, sample_data_names = c("TIC", "TOC"))[[1]]) - 3, ncol(subset_list_df[[1]]))
})

test_that("Number of columns should stay the same", {
  expect_equal(ncol(3 + phyloseq2ML::add_sample_data(add_sample_data = FALSE, phyloseq_object = testps, 
    count_tables = subset_list_df, sample_data_names = "TIC")[[1]]), ncol(subset_list_df[[1]]))
})

test_that("Break if columns are not available", {
  expect_error(phyloseq2ML::add_sample_data(add_sample_data = TRUE, phyloseq_object = testps, 
    count_tables = subset_list_df, sample_data_names = "not_existent"))
})
