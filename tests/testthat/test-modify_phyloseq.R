#test_that("this fails", {
#  expect_equal(1, 2)
#}) 

test_that("Breaks when no sequences are available and use_sequences = TRUE", {
  expect_error(phyloseq2ML::standardize_phyloseq_headers(TNT_communities, taxa_prefix = "ASV", use_sequences = TRUE))
})


test_that("Names changed after function call", {
  expect_true(
    all(grepl("blabla", phyloseq::taxa_names(phyloseq2ML::standardize_phyloseq_headers(
      TNT_communities, taxa_prefix = "blabla", use_sequences = FALSE)))
    ))
})

test_that("Correct number of digits", {
  expect_equal(
    nchar(gsub("[^0-9]+", "", phyloseq::taxa_names(phyloseq2ML::standardize_phyloseq_headers(
      TNT_communities, taxa_prefix = "blabla", use_sequences = FALSE))[1])), 2)
})