# confusion matrix is set up correctly
test_that("Included and own confusion matrix give identical results", {
  data(iris)
  tmp <- ranger::ranger(Species ~., data = iris)
  confusion_matrix <- table(true = iris$Species, 
      predicted = tmp$predictions)
  expect_equal(confusion_matrix, tmp$confusion.matrix)
})

# ranger_classification
test_that("Breaks if neither training nor prediction is supplied as step", {
  expect_error(purrr::pmap(cbind(test_grid, .row = rownames(test_grid)), master_grid = test_grid,
    phyloseq2ML::ranger_classification, the_list = oversampled_input_binary, step = "no")
  )
})

test_that("Length of output equals input times classes in training", {
  test_grid$Target <- as.character(test_grid$Target)
  classes <- length(levels(oversampled_input_multi[[1]][["train_set"]][[test_grid$Target]]))
  results <- purrr::pmap(cbind(test_grid, .row = rownames(test_grid)), master_grid = test_grid,
    phyloseq2ML::ranger_classification, the_list = oversampled_input_multi, step = "training")
  expect_equal(nrow(results[[1]]), classes * nrow(test_grid))
})

test_that("Length of output equals input times classes in prediction", {
  test_grid$Target <- as.character(test_grid$Target)
  classes <- length(levels(oversampled_input_multi[[1]][["train_set"]][[test_grid$Target]]))
  results <- purrr::pmap(cbind(test_grid, .row = rownames(test_grid)), master_grid = test_grid,
    phyloseq2ML::ranger_classification, the_list = oversampled_input_multi, step = "prediction")
  expect_equal(nrow(results[[1]]), classes * nrow(test_grid))
})

test_that("Detect 2 classes for binary_classification", {
  test_grid$Target <- as.character(test_grid$Target)
  classes <- length(levels(oversampled_input_binary[[1]][["train_set"]][[test_grid$Target]]))
  results <- purrr::pmap(cbind(test_grid, .row = rownames(test_grid)), master_grid = test_grid,
    phyloseq2ML::ranger_classification, the_list = oversampled_input_binary, step = "training")
  expect_equal(length(unique(results[[1]]$Class)), classes, 2)
})

test_that("Detect correct number of classes for multi_classification", {
  test_grid$Target <- as.character(test_grid$Target)
  classes <- length(levels(oversampled_input_multi[[1]][["train_set"]][[test_grid$Target]]))
  results <- purrr::pmap(cbind(test_grid, .row = rownames(test_grid)), master_grid = test_grid,
    phyloseq2ML::ranger_classification, the_list = oversampled_input_multi, step = "training")
  expect_equal(length(unique(results[[1]]$Class)), classes)
})

test_that("Breaks if ML_object names in master_grid do not match list item names", {
  expect_error(purrr::pmap(cbind(test_grid, .row = rownames(test_grid)), master_grid = test_grid,
    phyloseq2ML::ranger_classification, the_list = splitted_input_multi, step = "training")
  )
})

test_that("Breaks if master_grid$Target is not character", {
  test_grid$Target <- as.factor(test_grid$Target)
  expect_error(purrr::pmap(cbind(test_grid, .row = rownames(test_grid)), master_grid = test_grid,
    phyloseq2ML::ranger_classification, the_list = oversampled_input_multi, step = "training")
  )
})

test_that("Breaks if master_grid does not contain required columns", {
  expect_error(purrr::pmap(cbind(parameter_df, .row = rownames(parameter_df)), 
    master_grid = parameter_df, phyloseq2ML::ranger_classification, the_list = 
    oversampled_input_multi, step = "training")
  )
})

test_that("Breaks if the input list is not correct", {
  expect_error(purrr::pmap(cbind(test_grid, .row = rownames(test_grid)), 
    master_grid = test_grid, phyloseq2ML::ranger_classification, the_list = 
    test_grid, step = "prediction")
  )
})

# store_classification
test_that("Breaks if no test_set is provided", {
  data(iris)
  tmp <- ranger::ranger(Species ~., data = iris)
  tmp2 <- predict(tmp, data = iris)
  confusion_matrix <- table(true = iris$Species, 
      predicted = tmp2$predictions)
  expect_error(phyloseq2ML::store_classification(trained_rf =  tmp, predicted_rf = tmp2, 
    confusion_matrix = confusion_matrix, n_classes = 3, 
    step = "prediction", test_set = NULL)
  )
})

test_that("Breaks if no prediction.ranger class object is provided", {
  data(iris)
  tmp <- ranger::ranger(Species ~., data = iris)
  tmp2 <- predict(tmp, data = iris)
  confusion_matrix <- table(true = iris$Species, 
      predicted = tmp2$predictions)
  expect_error(phyloseq2ML::store_classification(trained_rf =  tmp, predicted_rf = tmp, 
    confusion_matrix = confusion_matrix, n_classes = 3, 
    step = "prediction", test_set = iris)
  )
})

test_that("Breaks if classes are not provided", {
  data(iris)
  tmp <- ranger::ranger(Species ~., data = iris)
  expect_error(phyloseq2ML::store_classification(tmp, tmp$confusion.matrix, 
    n_classes = NULL, step = "training")
  )
})

test_that("Breaks for using wrong step string", {
  data(iris)
  tmp <- ranger::ranger(Species ~., data = iris)
  expect_error(phyloseq2ML::store_classification(tmp, tmp$confusion.matrix, 
    n_classes = 3, step = "no")
  )
})

test_that("Breaks if not using ranger object", {
  data(iris)
  tmp <- ranger::ranger(Species ~., data = iris)
  expect_error(phyloseq2ML::store_classification("hello", confusion_matrix = tmp$confusion.matrix, 
    n_classes = 3, step = "training")
  )
})

test_that("Breaks if no confusion matrix is provided", {
  data(iris)
  tmp <- ranger::ranger(Species ~., data = iris)
  expect_error(phyloseq2ML::store_classification(tmp, confusion_matrix = NULL, 
    n_classes = 3, step = "training")
  )
})

# prediction_accuracy
test_that("Breaks for non-prediction object", {
  data(iris)
  tmp <- ranger::ranger(Species ~., data = iris)
  expect_error(phyloseq2ML::prediction_accuracy(tmp, iris))
})

test_that("Breaks if test set is not a data.frame", {
  data(iris)
  tmp <- ranger::ranger(Species ~., data = iris)
  prediction <- stats::predict(tmp, data = iris)
  expect_error(phyloseq2ML::prediction_accuracy(prediction, "hello"))
})

test_that("Returns numeric value", {
  data(iris)
  tmp <- ranger::ranger(Species ~., data = iris)
  prediction <- stats::predict(tmp, data = iris)
  expect_true(is.numeric(phyloseq2ML::prediction_accuracy(prediction, iris)))
})