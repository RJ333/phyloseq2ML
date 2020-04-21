# ranger_regression
test_that("Length of output equals input", {
  results <- purrr::pmap(cbind(test_grid_regress, .row = rownames(test_grid_regress)), master_grid = test_grid_regress,
    phyloseq2ML::ranger_regression, the_list = augmented_regression)
  expect_equal(nrow(results[[1]]), nrow(test_grid_regress))
})

test_that("Detect no response classes for regression", {
  classes <- length(levels(augmented_regression[[1]][["train_set"]][[test_grid_regress$Target]]))
  expect_equal(classes, 0)
})

test_that("Breaks if ML_object names in master_grid do not match list item names", {
  expect_error(purrr::pmap(cbind(test_grid_regress, .row = rownames(test_grid_regress)), master_grid = test_grid_regress,
    phyloseq2ML::ranger_regression, the_list = splitted_input_multi)
  )
})

test_that("Breaks if master_grid$Target is not character", {
  test_grid_regress$Target <- as.factor(test_grid_regress$Target)
  expect_error(purrr::pmap(cbind(test_grid_regress, .row = rownames(test_grid_regress)), master_grid = test_grid_regress,
    phyloseq2ML::ranger_regression, the_list = augmented_regression)
  )
})

test_that("Breaks if master_grid does not contain required columns", {
  expect_error(purrr::pmap(cbind(parameter_df, .row = rownames(parameter_df)), 
    master_grid = parameter_df, phyloseq2ML::ranger_regression, the_list = 
    augmented_regression)
  )
})

test_that("Breaks if the input list is not correct", {
  expect_error(purrr::pmap(cbind(test_grid_regress, .row = rownames(test_grid_regress)), 
    master_grid = test_grid_regress, phyloseq2ML::ranger_regression, the_list = 
    test_grid_regress)
  )
})

test_that("Breaks if the actual response variable is not numeric", {
  expect_error(purrr::pmap(cbind(test_grid_regress, .row = rownames(test_grid_regress)), 
    master_grid = test_grid_regress, phyloseq2ML::ranger_regression, the_list = 
    augmented__input_multi)
  )
})

# store_regression
test_that("Breaks if no test_set is provided", {
  data(iris)
  tmp <- ranger::ranger(Petal.Width ~., data = iris)
  tmp2 <- predict(tmp, data = iris)
  expect_error(phyloseq2ML::store_regression(trained_rf = tmp, predicted_rf = tmp2, 
    step = "prediction", training_data = iris, test_data = NULL)
  )
})

test_that("Breaks if no ranger class object is provided", {
  expect_error(phyloseq2ML::store_regression(trained_rf = "hello",  
    step = "training", training_data = augmented_regression[[1]][["train_set"]])
  )
})

test_that("Breaks if no training data.frame is provided", {
  data(iris)
  tmp <- ranger::ranger(Petal.Width ~., data = iris)
  expect_error(phyloseq2ML::store_regression(trained_rf = tmp,  
    step = "training", training_data = "hello")
  )
})

test_that("Breaks for using wrong step string", {
  data(iris)
  tmp <- ranger::ranger(Petal.Width ~., data = iris)
  expect_error(phyloseq2ML::store_regression(trained_rf = tmp, 
   step = "no", training_data = iris)
  )
})
