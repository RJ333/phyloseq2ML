test_that("Generate tax dictionary with two entries", {
  expect_equal(length(phyloseq2ML::create_taxonomy_lookup(
    phyloseq_object = TNT_communities,  
    taxonomic_ranks = c("Genus", "Family"))), 2)
})

test_that("Provided non existent taxonomic ranks", {
  expect_error(length(phyloseq2ML::create_taxonomy_lookup(
    phyloseq_object = TNT_communities,  
    taxonomic_ranks = c("blabla"))))
})

test_that("How many strings are translated with and withoutout NA", {
  expect_equal(length(phyloseq2ML::translate_ID(ID = c("ASV02", "ASV31"), 
    tax_rank = c("Genus"), lookup_table = taxa_vector_list)), 1)
  expect_equal(length(phyloseq2ML::translate_ID(ID = c("ASV02", "ASV31"), 
    tax_rank = c("Genus"), lookup_table = taxa_vector_list, na.rm = FALSE)), 2)
})
