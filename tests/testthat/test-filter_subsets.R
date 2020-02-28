test_that("OTU table correct for given threshold and number of samples", {
  expect_equal(digest::sha1(phyloseq::otu_table(phyloseq2ML::filter_subsets(TNT_communities, 1500, 3))),
               "e38eb6fc937245a9a7bc061fd68bfea3bee01120")
})

test_that("Tax table correct for given threshold and number of samples", {
  expect_equal(digest::sha1(phyloseq::tax_table(phyloseq2ML::filter_subsets(TNT_communities, 1500, 3))),
               "1d9b95315d37d63513df9088245dbe62cf3239f3")
})

test_that("Sample data correct for given threshold and number of samples", {
  expect_equal(digest::sha1(phyloseq::sample_data(phyloseq2ML::filter_subsets(TNT_communities, 100, 2))),
               "7a6020b9872cc5c10b895dcd6cda058be1ae9f4d")
})

test_that("Sample data correct for zero threshold and number of samples", {
  expect_error(phyloseq2ML::filter_subsets(TNT_communities, 0, 2))
})

test_that("Sample data correct for zero number of samples", {
  expect_error(phyloseq2ML::filter_subsets(TNT_communities, 2, 0))
})

test_that("Agglomeration fails if tax levels are not among  tax ranks", {
  expect_error(phyloseq2ML::create_counttable_subsets(
  subset_list = list(TNT_communities),  
  ASV_thresholds = c(1500, 2000),
  tax_levels = "Space Force"))
})

test_that("The returning object is a list also without tax levels specified", {
  expect_true(is.list(phyloseq2ML::create_counttable_subsets(
    subset_list = list(TNT_communities),  
    ASV_thresholds = c(1500, 2000))))
})

test_that("create_counttable_subsets fails if count value vector is empty", {
  empty_vector <- c()
  expect_error(phyloseq2ML::create_counttable_subsets(
    subset_list = list(TNT_communities),  
    ASV_thresholds = empty_vector))
})

test_that("create_counttable_subsets fails if input is not a list", {
  expect_error(phyloseq2ML::create_counttable_subsets(
    subset_list = TNT_communities,  
    ASV_thresholds = 500,
    tax_levels = "Genus"))
})
