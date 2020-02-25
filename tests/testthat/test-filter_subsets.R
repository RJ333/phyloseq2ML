test_that("OTU table correct for given threshold and number of samples", {
  expect_equal(digest::sha1(otu_table(phyloseq2ML::filter_subsets(TNT_communities, 1500, 3))),
               "e38eb6fc937245a9a7bc061fd68bfea3bee01120")
})

test_that("Tax table correct for given threshold and number of samples", {
  expect_equal(digest::sha1(tax_table(phyloseq2ML::filter_subsets(TNT_communities, 1500, 3))),
               "1d9b95315d37d63513df9088245dbe62cf3239f3")
})

test_that("Sample data correct for given threshold and number of samples", {
  expect_equal(digest::sha1(sample_data(phyloseq2ML::filter_subsets(TNT_communities, 100, 2))),
               "7a6020b9872cc5c10b895dcd6cda058be1ae9f4d")
})

test_that("Sample data correct for zero threshold and number of samples", {
  expect_error(phyloseq2ML::filter_subsets(TNT_communities, 1, 2))
})

test_that("Sample data correct for zero number of samples", {
  expect_error(phyloseq2ML::filter_subsets(TNT_communities, 2, 0))
})