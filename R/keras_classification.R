#' Build and compile keras sequential models with 2 hidden layers
#' 
#' This function can setup and compile sequential models. Please have a look at
#' [keras_model_sequential](https://keras.rstudio.com/reference/keras_model_sequential.html),
#' [layer_dense](https://keras.rstudio.com/reference/layer_dense.html) and 
#' [compile](https://keras.rstudio.com/reference/compile.html) for further details.
#' 
#' @param train_data a table of training data
#' @param Layer1_units integer, number of units in the first hidden layer
#' @param Layer2_units integer, number of units in the second hidden layer
#' @param classes integer, number of classes and therefore number of units in 
#'   the output layer, set to 1 for regression
#' @param Dropout_layer1 numeric, ratio of dropout nodes for layer 1 between 0 and 1
#' @param Dropout_layer2 numeric, ratio of dropout nodes for layer 2 between 0 and 1
#' @param Dense_activation_function char, activation function for the hidden layers
#' @param Output_activation_function char, activation function for the output layer,
#'   (default: NULL, used for regression)
#' @param Optimizer_function char, the optimizer function
#' @param Loss_function char, the loss function
#' @param Metric char vector, which metrics to monitor
#' @param ... further arguments
#'
#' @return a compiled keras sequential model with two hidden layers
#'
#' @export
build_the_model <- function(train_data, Layer1_units, Layer2_units, classes, 
  Dropout_layer1, Dropout_layer2, Dense_activation_function, 
  Output_activation_function = NULL, Optimizer_function, Loss_function, Metric, ...) {
  
  if(dim(train_data)[[2]] < 1) {
    stop("Provided training data has no columns, can't determine input layer shape")
  }

  # network architecture
  model <- keras::keras_model_sequential() %>%
    keras::layer_dense(units = Layer1_units, 
      activation = Dense_activation_function,
      input_shape = dim(train_data)[[2]]) %>%
    keras::layer_dropout(rate = Dropout_layer1) %>%
    keras::layer_dense(units = Layer2_units, activation = Dense_activation_function) %>%
    keras::layer_dropout(rate = Dropout_layer2) %>%
    keras::layer_dense(units = classes, activation = Output_activation_function)
  
  # compiling the model
  model %>% keras::compile(
    optimizer = Optimizer_function,
    loss = Loss_function,
    metrics = Metric)
  model
}
  
#' Run keras tensorflow classification.
#' 
#' This functions calls keras tensorflow using the parameter values in each row 
#' of the provided master_grid, using the data of the list elements. Please have
#' a look at the keras [fit doc](https://keras.rstudio.com/reference/fit.html)
#' for explanation on the keras related variables, the arguments are beginning 
#' with "keras" in the description. Except for `the list`, `master_grid` and `.row`
#' all arguments need to be column names of `master_grid`
#' 
#' @param Target factor, the response variable
#' @param ML_object factor or char, the name of the corresponding `the_list` item
#' @param Cycle integer, the current repetition
#' @param Epochs keras, integer, how many times should the whole data set be 
#'   passed through the network?
#' @param Batch_size keras, integer, how many samples before updating the weights?
#' @param k_fold integer, the total number of k_folds for cross validation 
#' @param current_k_fold integer, the current k_fold in range 1 : k_fold 
#' @param Early_callback keras, string, a callback metric
#' @param Delay keras, integer, wait for how many epochs before callback happens?
#' @param step character declaring `training` or `prediction`
#' @param the_list The input tables list
#' @param master_grid the data frame containing all parameter combinations
#' @param .row current row of master_grid
#' @param ... additional features passed by pmap call
#'
#' @return a compiled keras sequential model with two hidden layers
#'
#' @export
keras_classification <- function(Target, ML_object, Cycle, Epochs, Batch_size, k_fold, 
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
  classes <- ncol(training_labels)
  if(classes < 2) {
    stop("Less then 2 classes found, response variable setup seems incorrect")
  }
  # lookup to translate between factor levels and class labels
  lookup <- stats::setNames(c(colnames(training_labels)), c(0:(classes - 1)))
  
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
    validation_targets <- training_labels[validation_indices, ]
    partial_train_data <- training_data[-validation_indices, ]
    partial_train_targets <- training_labels[-validation_indices, ]
    
    # build and compile model
    model <- build_the_model(train_data = training_data, classes = classes, ...)
  
    # train model 
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
    
  } else if (step == "prediction") {
    validation_data <- community_table[["testset_data"]]
    validation_targets <- community_table[["testset_labels"]]
    partial_train_data <- training_data
    partial_train_targets <- training_labels
    
    # build and compile model
    model <- build_the_model(train_data = training_data, classes = classes, ...)
    
    # train model 
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
  }
  
  # predict classes
  val_predictions <- model %>% keras::predict_classes(validation_data)

  # prepare results
  factor_targets <- categoric_to_factor(validation_targets)
  predicted <- data.frame(factor_targets, val_predictions)
  predicted_labels <- data.frame(lapply(predicted, function(i) 
    lookup[as.character(i)]))
  if (nrow(predicted_labels) != nrow(validation_data)) {
    stop("Length of predictions and data to be predicted differs")
  }
  # provide all classes as factor levels, otherwise confusion matrix breaks if
  # a class is not predicted or present at all
  predicted_labels$val_predictions <- factor(predicted_labels$val_predictions, 
    levels = colnames(training_labels))
  predicted_labels$factor_targets <- factor(predicted_labels$factor_targets, 
    levels = colnames(training_labels))
  # calculate confusion matrix
  confusion_matrix <- table(
    true = predicted_labels$factor_targets,
    predicted = predicted_labels$val_predictions)

  # return results data.frame
  store_classification_results(hist = history,
    prediction_table = predicted_labels, confusion_matrix = confusion_matrix, 
    train_data = training_data, n_classes = classes)
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
#' or prediction and stores them in a data.frame. By calling `classification_metrics` 
#' various metrics for classification performance are calculated for each class.
#'
#' @param hist the keras history object
#' @param prediction_table the data.frame comparing predictions and true values
#' @param n_classes the number of classes for classification
#' @param confusion_matrix the confusion matrix generated from `prediction_table`
#' @param train_data the training set data.frame
#' 
#' @return A data frame with one row per keras run and class
#'
#' @export
store_classification_results <- function(hist, prediction_table, n_classes,
  confusion_matrix, train_data) {
  
  if(!is.data.frame(prediction_table)) {
    stop("prediction table is not a data frame")
  } else if(nrow(prediction_table) == 0) {
    stop("prediction table is empty")
  }
  
  results <- data.frame()
  # extract classifications for each class, every class becomes own row
  for (class in 1:n_classes) {
    results[class, "Class"] <- row.names(confusion_matrix)[class] 
    results[class, "True_positive"] <- confusion_matrix[class, class]
    results[class, "False_positive"] <- sum(confusion_matrix[, class]) - 
      confusion_matrix[class, class]
    results[class, "True_negative"] <- sum(confusion_matrix[-class, -class])
    results[class, "False_negative"] <- sum(confusion_matrix[class, ]) - 
      confusion_matrix[class, class]
  }  
  results$Number_of_samples_train <- hist$params$samples
  results$Number_of_samples_validate <- nrow(prediction_table)
  results$Number_independent_vars <- ncol(train_data)
  results <- classification_metrics(results, results$Number_of_samples_validate)
  results
}
