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
