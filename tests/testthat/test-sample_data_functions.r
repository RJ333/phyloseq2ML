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