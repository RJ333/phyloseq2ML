test_that("Length of df equals list length", {
  expect_equal(nrow(phyloseq2ML::extract_parameters(oversampled_input_binary)), 
    length(oversampled_input_binary))
})

test_that("Check that no NAs are created", {
  expect_false(all(is.na(phyloseq2ML::extract_parameters(oversampled_input_multi))))
})

test_that("Breaks for unnamed list", {
  expect_error(phyloseq2ML::extract_parameters(list(0, 3)))
})

test_that("Breaks for early list with missing parameters in name", {
  expect_error(phyloseq2ML::extract_parameters(subset_list_df))
})
