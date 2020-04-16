#' Run keras tensorflow regression
#' 
#' This functions calls keras tensorflow for regression using the parameter 
#' values in each row of the provided master_grid, using the data of the list elements.
#' 
#' @param Target The respective column from the master_grid
#' @param ML_object The respective column from the master_grid
#' @param Cycle The respective column from the master_grid
#' @param Epochs The respective column from the master_grid
#' @param Batch_size The respective column from the master_grid
#' @param k_fold The respective column from the master_grid
#' @param current_k_fold The respective column from the master_grid
#' @param Early_callback The respective column from the master_grid
#' @param Delay The respective column from the master_grid
#' @param step character declaring `training` or `prediction`
#' @param the_list The input tables list
#' @param master_grid the data frame containing all parameter combinations
#' @param .row current row of master_grid
#' @param ... additional features passed by pmap call
#'
#' @return a compiled keras sequential model with two hidden layers
#'
#' @export
keras_regression <- function(Target, ML_object, Cycle, Epochs, Batch_size, k_fold, 
  current_k_fold, Early_callback, Delay, step, the_list, master_grid, .row, ...) {
  
  if(!all(c("Target", "ML_object", "Cycle", "Epochs", "Batch_size", "k_fold", 
    "current_k_fold", "Early_callback", "Delay", "step") %in% colnames(master_grid))) {
    stop("Keras parameters do not match column names in master_grid")
  }
  if(is.null(the_list[[ML_object]])) {
    stop("Names of items in the_list and ML_object in master_grid do not match")
  }
  if(!exists(c("trainset_labels", "trainset_data", "testset_labels", 
    "testset_data"), where = the_list[[1]])) {
    stop("Item in the_list does not have all required elements:
      trainset_labels, trainset_data, testset_labels, testset_data")
  }
  stopifnot(step == "training" | step == "prediction")

  state <- paste("Row", .row, "of", nrow(master_grid))
  futile.logger::flog.info(state)
  community_table <- the_list[[ML_object]]
  training_data <- community_table[["trainset_data"]]
  training_labels <- community_table[["trainset_labels"]]
  if (is.vector(training_labels)) {
    classes <- 1
  } else {
    stop("Training labels have more than one column, response variable setup seems incorrect")
  }

  if (step == "prediction" & (k_fold != 1 | current_k_fold != 1)) {
    stop("k_fold and current_k_fold need to be 1 for prediction")
  } else if (step == "training") {
    indices <- sample(1:nrow(training_data))
    folds <- cut(1:length(indices), breaks = k_fold, labels = FALSE)
  }
  
  if (step == "training") {

    kfold_msg <- paste("k_fold", current_k_fold, "of", k_fold)
    futile.logger::flog.info(kfold_msg)
    # split training data into train and validation, by number of folds
    validation_indices <- which(folds == current_k_fold, arr.ind = TRUE)    
    validation_data <- training_data[validation_indices, ]
    validation_targets <- training_labels[validation_indices]
    partial_train_data <- training_data[-validation_indices, ]
    partial_train_targets <- training_labels[-validation_indices]
    
    # build and compile model
    model <- build_the_model(train_data = training_data, classes = classes, ...)
  
    # train model 
    timing_part_1 <- system.time({
      history <- model %>% keras::fit(
        partial_train_data, 
        partial_train_targets,
        epochs = Epochs, 
        batch_size = Batch_size, 
        callbacks = keras::callback_early_stopping(
          monitor = Early_callback,
          patience = Delay,          
          verbose = 0),
        validation_data = list(validation_data, validation_targets),
        verbose = 0)
    })
  } else if (step == "prediction") {
    validation_data <- community_table[["testset_data"]]
    validation_targets <- community_table[["testset_labels"]]
    partial_train_data <- training_data
    partial_train_targets <- training_labels
    
    # build and compile model
    model <- build_the_model(train_data = training_data, classes = classes, ...)
    
    # train model 
    timing_part_1 <- system.time({
      history <- model %>% keras::fit(
        partial_train_data, 
        partial_train_targets,
        epochs = Epochs, 
        batch_size = Batch_size, 
        callbacks = keras::callback_early_stopping(
          monitor = Early_callback,
          patience = Delay,          
          verbose = 0),
        test_split = 0.0,
        verbose = 0)
    })
  }
  
  # predict classes
  timing_part_2 <- system.time({val_predictions <- model %>% 
    stats::predict(validation_data)})

  # return results data.frame
  store_regression_results(hist = history, timing = timing_part_1 + timing_part_2, 
    predicted_values = val_predictions, true_values = validation_targets, 
    training_data = training_data)
}

#' Store results from keras tf regression training and prediction
#'
#' This function extracts information from the keras model generated by training
#' or prediction and stores them in a data.frame. It compares the pre-
#' dicted values in training and prediction to their true values and calculates
#' various measures to describe the difference.
#'
#' @param hist the keras history object
#' @param timing the timings from the machine learning steps
#' @param true_values the values to be predicted from `trainset_labels` or `testset_labels`
#' @param predicted_values numerical vector of predicted values
#' @param training_data the training set data.frame
#' 
#' @return A data frame with one row per keras run and class
#'
#' @export
store_regression_results <- function(hist, timing, true_values, predicted_values, training_data) {
  
  if(!is.matrix(training_data)) {
    stop("training_data is not a matrix")
  } else if(nrow(training_data) == 0) {
    stop("training_data is empty")
  }
  if(is.dummy(predicted_values)) {
    futile.logger::flog.warn("Predicted values are only 0 or 1, did you rather predict classes?")
  }
  residuals <- true_values - predicted_values
  results <- data.frame(
    Number_of_samples_train = hist$params$samples,
    Number_of_samples_validate = length(true_values),
    Number_independent_vars = ncol(training_data),
    MSE = mean(residuals^2),
    RMSE = sqrt(mean(residuals^2)),
    MAE = mean(abs(residuals)),
    Residual_sum_squares = as.numeric(sum(residuals^2)),
    Scatter_index = as.numeric(sqrt(mean(residuals^2)) / 
      mean(true_values)),
    Seconds_elapsed = timing[["elapsed"]]
  )
  # calculate R squared https://stackoverflow.com/a/40901487
  results$Rsquared <- stats::cor(true_values, predicted_values) ^ 2
  results$Rsquared_adjusted <- 1 - (1 - results$Rsquared) * 
      ((results$Number_of_samples_validate - 1) / 
      (results$Number_of_samples_validate - ncol(training_data) - 1))
  results$Class <- "Continuous"
  results
}
