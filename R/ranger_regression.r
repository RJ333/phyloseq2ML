#' Run ranger regression with parameters of data.frame rows.
#'
#' This functions calls ranger using the parameter values in each row of the 
#' provided master_grid, using the data of the list elements. Please have
#' a look at the [ranger doc](https://cran.r-project.org/web/packages/ranger/ranger.pdf)
#' for explanation on the ranger related variables, the arguments are beginning 
#' with "ranger" in the description. Except for `the list`, `master_grid` and `.row`
#' all arguments need to be column names of `master_grid`
#'
#' @param Target character, the response variable
#' @param ML_object factor or character, the name of the corresponding `the_list` item
#' @param Cycle integer, the current repetition
#' @param Number_of_trees ranger, integer, number of trees per forest
#' @param Mtry_factor ranger, factor to multiply default ranger mtry argument
#' @param .row current row of master_grid
#' @param the_list The input tables list
#' @param master_grid the data frame containing all parameter combinations
#' @param step character declaring `training` or `prediction`
#' @param ... further parameters passed on to subfunctions
#'
#' @return a data frame with results and metrics for each row of the master_grid
#'
#' @export
ranger_regression <- function(master_grid, Target, ML_object, Cycle, 
  Number_of_trees, Mtry_factor, .row, the_list, step, ...) {
  
  if(!all(c("Target", "ML_object", "Cycle", "Number_of_trees", "Mtry_factor") %in% 
      colnames(master_grid))) {
    stop("Ranger parameters do not match column names in master_grid")
  }
  if(is.null(the_list[[ML_object]])) {
    stop("Names in the_list and master_grid do not match")
  }
  if(!is.character(Target)) {
    stop("ranger requires Target as character to work with purr::pmap()")
  }
  if(!is.numeric(the_list[[ML_object]][["train_set"]][[Target]])) {
    stop("Response variable is not numeric")
  }
  stopifnot(step == "training" | step == "prediction")
  
  state <- paste("Row", .row, "of", nrow(master_grid))
  futile.logger::flog.info(state)
  all_vars <- ncol(the_list[[ML_object]][["train_set"]]) - 1
  # multiply sqrt of variables with Mtry_factor; if greater than available 
  # number of variables, select all variables
  for_mtry <- ifelse(((all_vars / 3) * Mtry_factor) < all_vars,
    (all_vars / 3) * Mtry_factor, all_vars)
  
  RF_train <- ranger::ranger(
    dependent.variable.name = Target,  # needs to character, not factor
    data = the_list[[ML_object]][["train_set"]],  # referring to named list item
    num.trees = Number_of_trees,
    mtry = for_mtry,  
    importance = "none")

  if (step == "prediction") {

    RF_prediction <- stats::predict(object = RF_train, 
      data = the_list[[ML_object]][["test_set"]])
    
    store_regression(trained_rf = RF_train, predicted_rf = RF_prediction, 
      training_data = the_list[[ML_object]][["train_set"]], 
      test_data = the_list[[ML_object]][["test_set"]], step = step)
      
  } else {  
  
    store_regression(trained_rf = RF_train,
      training_data = the_list[[ML_object]][["train_set"]], step = step)
  }
}

#' Store results from ranger regression training and prediction.
#'
#' This function extracts information from the ranger objects generated by
#' training or prediction and stores them in a data.frame. It compares the pre-
#' dicted values in training and prediction to their true values and calculates
#' various measures to describe the difference. `Rsquared_all` refers to R2 calcu-
#' lated on all samples instead of only out-of-bag samples in `Rsquared`. This is
#' only relevant for training, as there is no out-of-bag in prediction.
#'
#' @param trained_rf the ranger object generated by training with `ranger()`
#' @param predicted_rf the ranger object generated by prediction with `predict()`,
#'   (default: `NULL`)
#' @param step character declaring whether `training` or `prediction` occurs
#' @param training_data data frame the ranger object was trained with
#' @param test_data data frame the ranger object used for prediction
#' 
#' @return A data frame with one row per ranger run and class
#'
#' @export
store_regression <- function(trained_rf, predicted_rf = NULL, 
  step, training_data, test_data = NULL) {
  
  stopifnot(step == "training" | step == "prediction")
  if(class(trained_rf) != "ranger") {
    stop("trained_rf is not of class ranger")
  }
  if(!is.data.frame(training_data)) {
    stop("training_data is not a data.frame")
  }
  if(step == "prediction" & !is.data.frame(test_data)) {
    stop("Provided test_data is not a data frame")
  }
  
  results <- data.frame(
    Tree_type = trained_rf$treetype,
    Variables_sampled = as.numeric(trained_rf$mtry),
    Number_independent_vars = as.numeric(trained_rf$num.independent.variables))
    
  if (step == "training") {
    
    residuals <- training_data[, ncol(training_data)] - unname(unlist(trained_rf[1]))
    results$Number_of_samples <- as.numeric(trained_rf$num.samples)
    results$Rsquared <- as.numeric(trained_rf$r.squared)
    # calculate R squared https://stackoverflow.com/a/40901487
    results$Rsquared_all <- stats::cor(training_data[, ncol(training_data)],
      unname(unlist(trained_rf[1]))) ^ 2
    results$Rsquared_adjusted <- 1 - (1 - results$Rsquared) * 
      ((results$Number_of_samples - 1) / (results$Number_of_samples - trained_rf$mtry - 1))
    results$Scatter_index = as.numeric(sqrt(trained_rf$prediction.error) / 
      mean(training_data[, ncol(training_data)]))
    
  } else if (step == "prediction") {
    
    residuals <- test_data[, ncol(test_data)] - predicted_rf$predictions
    results$Number_of_samples <- as.numeric(predicted_rf$num.samples)
    results$Rsquared_all <- stats::cor(test_data[, ncol(test_data)], 
      predicted_rf$predictions) ^ 2
    results$Scatter_index <- as.numeric(sqrt(mean(residuals^2)) / 
      mean(test_data[, ncol(test_data)]))
  }
  # increase number of trees if below contains NaN --> leads to columns MAE being NaN
  results$MSE <- mean(residuals^2)
  results$RMSE <- sqrt(mean(residuals^2))
  results$Rsquared_all_adjusted <- 1 - (1 - results$Rsquared_all) * 
    ((results$Number_of_samples - 1) / (results$Number_of_samples - trained_rf$mtry - 1))
  results$MAE <- mean(abs(residuals))
  results$Residual_sum_squares <- as.numeric(sum(residuals^2))
  results$Vars_percent <- as.numeric(results$Variables_sampled / 
    results$Number_independent_vars) * 100
  results$Class <- "Continuous"
  if (any(sapply(results, is.nan))) {
    futile.logger::flog.warn("Regression metrics containing NaN have been 
      generated. Try increasing the number of trees.")
  }
  results
}
