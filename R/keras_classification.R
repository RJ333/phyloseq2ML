#' Build and compile keras sequential models with 2 hidden layers for classification
#' 
#' This function can setup and compile sequential models for classification.
#' 
#' @param train_data a table of training data
#' @param first_layer_units integer, number of units in the first hidden layer
#' @param second_layer_units integer, number of units in the second hidden layer
#' @param classes integer, number of classes and therefore number of units in 
#'   the output layer
#' @param dropout_rate_1 the rate of dropout nodes for layer 1
#' @param dropout_rate_2 the rate of dropout nodes for layer 2
#' @param dense_activation_fun the activation function for the hidden layers
#' @param output_activation_fun the activation function for the output layer
#' @param optimizer_param the optimizer function
#' @param loss_param the loss function
#' @param metric which metrics to monitor
#'
#' @return a compiled keras sequential model with two hidden layers
#'
#' @export
build_the_model <- function(train_data, first_layer_units, second_layer_units, 
  classes, dropout_rate_1, dropout_rate_2, dense_activation_fun, 
  output_activation_fun, optimizer_param, loss_param, metric) {
  
  model <- keras::keras_model_sequential() %>%
    keras::layer_dense(units = first_layer_units, 
      activation = dense_activation_fun,
      input_shape = dim(train_data)[[2]]) %>%
    keras::layer_dropout(rate = dropout_rate_1) %>%
    keras::layer_dense(units = second_layer_units, activation = dense_activation_fun) %>%
    keras::layer_dropout(rate = dropout_rate_2) %>%
    keras::layer_dense(units = classes, activation = output_activation_fun)
  
  model %>% keras::compile(
    optimizer = optimizer_param,
    loss = loss_param,
    metrics = metric)
  model
}
  
#' Run keras tensorflow classification
#' 
#' This functions calls keras tensorflow using the parameter values in each row 
#' of the provided master_grid, using the data of the list elements.
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
#' @param ... further parameters passed on to `build_the_model()`
#'
#' @return a compiled keras sequential model with two hidden layers
#'
#' @export
run_keras <- function(Target, ML_object, Cycle, Epochs, Batch_size, k_fold, 
  current_k_fold, Early_callback, Delay, step, the_list, master_grid, .row, ...) {
  if(!all(c("Target", "ML_object", "Cycle", "Epochs", "Batch_size", "k_fold", 
    "current_k_fold", "Early_callback", "Delay") %in% colnames(master_grid))) {
    stop("Keras parameters do not match column names in master_grid")
  }
  if(is.null(the_list[[ML_object]])) {
    stop("Names in the_list and master_grid do not match")
  }
  stopifnot(step == "training" | step == "prediction")
  
  futile.logger::flog.info(.row, "of", nrow(master_grid), capture = TRUE)
  
  community_table <- the_list[[ML_object]]
  training_data <- community_table[["trainset_data"]]
  training_labels <- community_table[["trainset_labels"]]
  classes <- ncol(training_labels)
  lookup <- stats::setNames(c(colnames(training_labels)), c(0:(classes - 1)))
  
  if (step == "prediction" & (k_fold != 1 | current_k_fold != 1)) {
    futile.logger::flog.info("current k_fold of", k_fold, "set to 1 for prediction step", capture = TRUE)
    k_fold <- 1
    current_k_fold <- 1
  } else if (step == "training") {
    indices <- sample(1:nrow(training_data))
    folds <- cut(1:length(indices), breaks = k_fold, labels = FALSE)
  }
  
  if (step == "training") {
    futile.logger::flog.info("k_fold", current_k_fold, "of", k_fold, capture = TRUE)
    validation_indices <- which(folds == current_k_fold, arr.ind = TRUE)    
    validation_data <- training_data[validation_indices, ]
    validation_targets <- training_labels[validation_indices, ]
    partial_train_data <- training_data[-validation_indices, ]
    partial_train_targets <- training_labels[-validation_indices, ]
    
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
          verbose = 1),
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
          verbose = 1),
        test_split = 0.0,
        verbose = 0)
    })
  }
  
  # predict classes
  timing_part_2 <- system.time({val_predictions <- model %>% keras::predict_classes(validation_data)})
  
  # prepare results
  factor_targets <- categoric_to_factor(validation_targets)
  predicted <- data.frame(factor_targets, val_predictions)
  predicted_labels <- data.frame(lapply(predicted, function(i) lookup[as.character(i)]))
  row.names(predicted_labels) <- row.names(validation_data)
  # calculate confusion matrix
  confusion_matrix <- table(
    true = predicted_labels$factor_targets,
    predicted = predicted_labels$val_predictions
  )
  
  # store all results
  store_binary_results(hist = history, timing = timing_part_1 + timing_part_2, 
    prediction_table = predicted_labels, confusion_matrix = confusion_matrix, 
    train_data = training_data, n_classes = classes)
  
  # print(confusion_matrix)
  # print(model)
  # print(history)
}

#' Reverse keras::to_categorical
#'
#' This function takes a binary matrix and returns one column representing
#' the factor levels. That way, `keras::to_categorical` can be reversed after
#' the machine learning step and compared to the predictions
#'
#' @param matrix the binary matrix which needs to be converted
#' 
#' @return An integer vector with numeric factor levels
#'
categoric_to_factor <- function(matrix) {
  if(!is.matrix(matrix)) {
    stop("Provided data is not a matrix")
  }
  
  apply(matrix, 1, function(row) which(row == max(row)) - 1)
}

#' Store results from keras tf classification training and prediction
#'
#' This function extracts information from the keras model generated by training
#' or prediction and stores them in a data.frame. It calls the functions 
#' `classification_metrics` for more data.
#'
#' @param hist the keras history object
#' @param timing the timings from the machine learning steps
#' @param prediction_table the data.frame comparing predictions and true values
#' @param n_classes the number of classes for classification
#' @param confusion_matrix the confusion matrix generated from `prediction_table`
#' @param train_data the training set data.frame
#' 
#' @return A data frame with one row per ranger run
#'
#' @export
store_binary_results <- function(hist, timing, prediction_table, n_classes,
  confusion_matrix, train_data) {

  results <- data.frame()
  # extract classifications for each class, every class becomes own row
  for (class in 1:n_classes) {
    results[class, "Class"] <- row.names(confusion_matrix)[class] 
    results[class, "True_positive"] <- confusion_matrix[class, class]
    results[class, "False_positive"] <- sum(confusion_matrix[,class]) - 
      confusion_matrix[class,class]
    results[class, "True_negative"] <- sum(confusion_matrix[-class, -class])
    results[class, "False_negative"] <- sum(confusion_matrix[class,]) - 
      confusion_matrix[class,class]
  }  
  results$Number_of_samples_train <- hist$params$samples
  results$Number_of_samples_validate <- nrow(prediction_table)
  results$Number_independent_vars <- ncol(train_data)
  results$Seconds_elapsed <- timing[["elapsed"]]
  #results <- calculate_classification_metrics(results)
  results
}
