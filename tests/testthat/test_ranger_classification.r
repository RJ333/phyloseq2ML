# confusion matrix is set up correctly
test_that("Included and own confusion matrix give identical results", {
  data(iris)
  tmp <- ranger::ranger(Species ~., data = iris)
  confusion_matrix <- table(true = iris$Species, 
      predicted = tmp$predictions)
  expect_equal(confusion_matrix, tmp$confusion.matrix)
})

# ranger_classification

test_that("Length of output equals input times classes", {
  test_grid$Target <- as.character(test_grid$Target)
  classes <- length(levels(augmented_input_multi[[1]][["train_set"]][[unique(test_grid$Target)]]))
  results <- purrr::pmap(cbind(test_grid, .row = rownames(test_grid)), master_grid = test_grid,
    phyloseq2ML::ranger_classification, the_list = augmented_input_multi)
  expect_equal(nrow(results[[1]]), classes / length(test_grid$Target)* nrow(test_grid))
})

test_that("Number of cases per class corresponds to TP + FN for each class, also
  Number of Samples fits number of predicted cases", {
 trues <- table(augmented_input_multi[[test_grid$ML_object[1]]][["train_set"]][[test_grid$Target[1]]])
 
 test_grid$results <- purrr::pmap(cbind(test_grid, .row = rownames(test_grid)), 
     ranger_classification, the_list = augmented_input_multi, master_grid = test_grid)
 results_df <-  as.data.frame(tidyr::unnest(test_grid, results))
 result_sub <- subset(results_df, ML_object == test_grid$ML_object[1])
 predicteds <- result_sub[["True_positive"]] + result_sub[["False_negative"]]
 expect_true(all(result_sub[["Number_of_samples"]] == result_sub[["True_positive"]] + result_sub[["False_negative"]] + 
     result_sub[["False_positive"]] + result_sub[["True_negative"]]))
 expect_true(all(predicteds %in% trues))
})

test_that("Detect 2 classes for binary_classification", {
  test_grid$Target <- as.character(test_grid$Target)
  classes <- length(levels(augmented_input_binary[[1]][["train_set"]][[unique(test_grid$Target)]]))
  results <- purrr::pmap(cbind(test_grid, .row = rownames(test_grid)), master_grid = test_grid,
    phyloseq2ML::ranger_classification, the_list = augmented_input_binary)
  expect_equal(length(unique(results[[1]]$Class)), classes, 2)
})

test_that("Detect correct number of classes for multi_classification", {
  test_grid$Target <- as.character(test_grid$Target)
  classes <- length(levels(augmented_input_multi[[1]][["train_set"]][[unique(test_grid$Target)]]))
  results <- purrr::pmap(cbind(test_grid, .row = rownames(test_grid)), master_grid = test_grid,
    phyloseq2ML::ranger_classification, the_list = augmented_input_multi)
  expect_equal(length(unique(results[[1]]$Class)), classes)
})

test_that("Breaks if ML_object names in master_grid do not match list item names", {
  expect_error(purrr::pmap(cbind(test_grid, .row = rownames(test_grid)), master_grid = test_grid,
    phyloseq2ML::ranger_classification, the_list = splitted_input_multi)
  )
})

test_that("Breaks if master_grid$Target is not character", {
  test_grid$Target <- as.factor(test_grid$Target)
  expect_error(purrr::pmap(cbind(test_grid, .row = rownames(test_grid)), master_grid = test_grid,
    phyloseq2ML::ranger_classification, the_list = augmented_input_multi)
  )
})

test_that("Breaks if master_grid does not contain required columns", {
  expect_error(purrr::pmap(cbind(parameter_df, .row = rownames(parameter_df)), 
    master_grid = parameter_df, phyloseq2ML::ranger_classification, the_list = 
    augmented_input_multi)
  )
})

test_that("Breaks if the input list is not correct", {
  expect_error(purrr::pmap(cbind(test_grid, .row = rownames(test_grid)), 
    master_grid = test_grid, phyloseq2ML::ranger_classification, the_list = 
    test_grid)
  )
})

test_that("Breaks if the actual response variable is not a factor is not correct", {
  expect_error(purrr::pmap(cbind(test_grid, .row = rownames(test_grid)), 
    master_grid = test_grid, phyloseq2ML::ranger_classification, the_list = 
    augmented_regression)
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

# classification_metrics
test_that("Breaks if number of samples argument is not numeric", {
  df <- data.frame()
  expect_error(phyloseq2ML::classification_metrics(df, "hello"))
})

test_that("Breaks if result table is empty", {
  df <- data.frame()
  expect_error(phyloseq2ML::classification_metrics(df, df$Number_of_samples))
})
