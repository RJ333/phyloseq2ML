test_that("OTU table correct for given threshold and number of samples", {
  data("TNT_communities")
  expect_equal(digest::sha1(phyloseq::otu_table(phyloseq2ML::filter_subsets(TNT_communities, 0.15, 3))),
               "bdca6425e84ba4641c4b57595bcd57bbeb789c3f")
})

test_that("Sample data correct for given threshold and number of samples", {
  data("TNT_communities")
  expect_equal(digest::sha1(phyloseq::sample_data(phyloseq2ML::filter_subsets(TNT_communities, 0.1, 2))),
               "ed37856a69c8d0ec8655b82d7fb167d234c36088")
})

test_that("Filtering fails for zero threshold and number of samples", {
  expect_error(phyloseq2ML::filter_subsets(TNT_communities, 0, 2))
})

test_that("Filtering fails for zero number of samples", {
  expect_error(phyloseq2ML::filter_subsets(TNT_communities, 2, 0))
})

test_that("Filtering fails for threshold of 100", {
  expect_error(phyloseq2ML::filter_subsets(TNT_communities, 100, 1))
})

test_that("Agglomeration fails if tax levels are not among tax ranks", {
  expect_error(phyloseq2ML::create_community_table_subsets(
  subset_list = list(TNT_communities),  
  thresholds = c(0.1500, 0.2),
  taxa_prefix = "ASV",
  tax_ranks = "Space Force"))
})

test_that("Agglomeration fails if taxa_prefix contains underscore", {
  expect_error(phyloseq2ML::create_community_table_subsets(
  subset_list = list(TNT_communities),  
  thresholds = c(0.15, 0.2),
  taxa_prefix = "ASV_",
  tax_ranks = "To_Genus"))
})

test_that("The returning object is a list also without tax ranks specified", {
  expect_true(is.list(phyloseq2ML::create_community_table_subsets(
    subset_list = list(TNT_communities),
    taxa_prefix = "ASV",
    thresholds = c(0.15, 2.0))))
})

test_that("create_counttable_subsets fails if count value vector is empty", {
  empty_vector <- c()
  expect_error(phyloseq2ML::create_community_table_subsets(
    subset_list = list(TNT_communities),
    taxa_prefix = "ASV",
    thresholds = empty_vector))
})

test_that("create_counttable_subsets fails if input is not a list", {
  expect_error(phyloseq2ML::create_community_table_subsets(
    subset_list = TNT_communities,  
    thresholds = 0.5,
    taxa_prefix = "ASV",
    tax_ranks = "Genus"))
})

test_that("create_counttable_subsets fails if threshold is > 100", {
  expect_error(phyloseq2ML::create_community_table_subsets(
    subset_list = TNT_communities,  
    thresholds = 100,
    taxa_prefix = "ASV",
    tax_ranks = "Genus"))
})
