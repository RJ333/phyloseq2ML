test_that("Integer check fails when character or factor is added", {
  expect_error(phyloseq2ML:::is.wholenumber(c("blabla")))
})

test_that("Integer check returns TRUE for decimals without rest", {
  expect_true(phyloseq2ML:::is.wholenumber(c(7.0)))
})

test_that("Integer check works for vectors", {
  expect_true(phyloseq2ML:::is.wholenumber(c(7, 7.0, 9, 500, 0, -1)))
})

test_that("Integer check returns FALSE if one value is not wholenumber", {
  expect_false(phyloseq2ML:::is.wholenumber(c(7, 7.0, 3.1)))
})

test_that("Integer check returns TRUE for decimals without rest", {
  expect_true(phyloseq2ML:::is.wholenumber(c(7, 7.0)))
})

test_that("Integer check returns TRUE for number", {
  expect_false(phyloseq2ML:::is.wholenumber(c(7.1)))
})


## is.dummy
test_that("Dummy check works for vectors", {
  expect_true(phyloseq2ML:::is.dummy(c(1, 0, 0, 1)))
  expect_true(phyloseq2ML:::is.dummy(c(0, 0)))
  expect_true(phyloseq2ML:::is.dummy(c(1, 1)))
})

test_that("Dummy check returns FALSE for numerical vectors unlike 0 or 1", {
  expect_false(phyloseq2ML:::is.dummy(c(7, 7.0, 9, 500, 0, -1)))
})

test_that("Dummy check returns FALSE for decimal with rest", {
  expect_false(phyloseq2ML:::is.dummy(c(1, 0, 1.1)))
  expect_true(phyloseq2ML:::is.dummy(c(1, 0, 1.0)))
})

test_that("Dummy check returns FALSE for negative value", {
  expect_false(phyloseq2ML:::is.dummy(c(-1)))
})

test_that("Dummy check returns FALSE for text or factor", {
  expect_false(phyloseq2ML:::is.dummy(c("word", "word2")))
  expect_false(phyloseq2ML:::is.dummy(as.factor(c("word", "word2"))))
})