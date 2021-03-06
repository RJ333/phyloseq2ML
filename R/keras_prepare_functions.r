#' Turn response column levels into dummy variables.
#'
#' The factor columns of an input table must be turned into dummy variables so 
#' keras can work with it. This function detects factor columns and turns them 
#' into dummy columns. First, as many columns are created as there are factor 
#' levels in the origin column, so a 2-level factor column would be represented 
#' by two complementary columns consisting of 0s and 1s. However, these are 
#' dependent on each other, which is known as the dummy trap. Therefore, the first 
#' of a given number of dummy columns per factor column is removed. If no factor 
#' columns are detected, the list will be returned unmodified along with an info. 
#' The response column is ignored, as it will be modified later using 
#' `keras::to_categorical()`.
#'
#' @param input_tables a list of input tables before splitting or oversampling
#'
#' @return A list input_tables with factor variable turned into dummy variables
#'
#' @export
dummify_input_tables <- function(input_tables) {
  
  if(!is.data.frame(input_tables[[1]])) {
    stop('No data frame for dummification found at "input_tables[[1]]"')
  }
  
  dummy_data_list <- list()
  for (table_index in seq_along(input_tables)) {
    
    current_name <- names(input_tables)[table_index]
    current_table <- input_tables[[table_index]]
    predictor_table <- current_table[, -ncol(current_table)]
    response_id <- names(current_table)[ncol(current_table)]
    response_col <- current_table[, ncol(current_table)]
    # which of the variables (except the response) are factors
    factor_column_ids <- names(predictor_table)[sapply(predictor_table, is.factor)]
    
    if (length(factor_column_ids) > 0) {
      # if factor columns present, add corresponding dummy columns
      tmp <- fastDummies::dummy_cols(predictor_table, remove_first_dummy = TRUE)
      row.names(tmp) <- row.names(predictor_table)
      # exclude the original factor columns, add and name response variable
      tmp <- tmp[ , !names(tmp) %in% factor_column_ids]
      tmp2 <- cbind(tmp, response_col)
      names(tmp2)[ncol(tmp2)] <- response_id
      dummy_data_list[[table_index]] <- tmp2
      dummy_msg <- paste("Names of columns changed to dummy columns:", factor_column_ids)
      futile.logger::flog.info(dummy_msg)
    } else {
      dummy_data_list[[table_index]] <- current_table
      futile.logger::flog.info("No categorical columns detected, returning unmodified input table")
    }
    names(dummy_data_list)[table_index] <- current_name
  }
  dummy_data_list
}

#' Apply scaling to numeric columns in test and train sets.
#'
#' To promote the convergence in neural net trainings, it is of advantage to have
#' the input variable values in a similar range. This can be achieved by scaling
#' the numeric values. The mean is subtracted from all values and then all values
#' are divided by the standard deviation (SD). This yields values centered around 
#' 0 with an SD of 1. Mean and SD are calculated ONLY based on training data (
#' e.g. https://stackoverflow.com/a/49444783). Dummy columns and a non-dummy 
#' response variable, as in regression use cases, are excluded from scaling. 
#' 
#' @param input_tables a list of splitted input tables. The "train_set" and 
#'   "test_set" tables need to be located at e.g `input_tables[[1]][["train_set"]]`
#'   and `input_tables[[1]][["test_set"]]`, respectively
#' @return A list of same structure as the input list, with scaled numeric columns
#'
#' @export
scaling <- function(input_tables) {
  
  if(!exists("train_set", where = input_tables[[1]]))
    stop('Error: Provided list does not contain a training set at location 
      "input_tables[[1]][["train_set"]].')
  
  if(!exists("test_set", where = input_tables[[1]]))
    stop('Error: Provided list does not contain a training set at location 
      "input_tables[[1]][["test_set"]].')
  
  counter <- 0
  data_list <- list()
  for (current_table in input_tables) {
    train_set <- current_table$train_set
    test_set <- current_table$test_set
    counter <- counter + 1
    current_name <- names(input_tables)[counter]
    response_column <- names(train_set)[ncol(train_set)]
    dummy_columns <- names(train_set)[vapply(train_set, is.dummy, logical(1))]
    
    #exclude dummy variables and response factor column from scaling
    not_to_scale_columns <- c(dummy_columns, response_column)
    futile.logger::flog.info("Dummy variables and continuous or factor response 
      variable is excluded from scaling")
    
    # calculate mean and standard deviation from training data
    train_mean <- apply(
      train_set[, !names(train_set) %in% not_to_scale_columns], 2, mean)
    train_sd <- apply(
      train_set[, !names(train_set) %in% not_to_scale_columns], 2, stats::sd)

    # apply mean and SD to train and test data
    scaled_train_columns <- scale(
      train_set[, !names(train_set) %in% not_to_scale_columns], 
      center = train_mean, scale = train_sd)
    scaled_test_columns <- scale(
      test_set[, !names(test_set) %in% not_to_scale_columns], 
      center = train_mean, scale = train_sd)
    
    # replace unscaled with scales columns by name
    train_set[, colnames(scaled_train_columns)] <- scaled_train_columns
    test_set[, colnames(scaled_test_columns)] <- scaled_test_columns
    data_list[[current_name]] <- list(train_set = train_set, test_set = test_set)
  }
  data_list 
}

#' Separate independent variables from response column for keras.
#'
#' This functions converts the prepared list into the keras tensorflow required 
#' shape. This means that the independent predictor variables are separated from 
#' the response variable. A given dummy response variable is represented by as 
#' many columns as it originally had levels, because the output layer of the 
#' neural network consists of one node per level. This step is skipped for 
#' non-dummy numerical response variables, e.g. as in case of regression.
#' 
#' @param final_input_tables a list of splitted input tables. The "train_set" and 
#'   "test_set" tables need to be located at e.g `final_input_tables[[1]][["train_set"]]`
#'   and `final_input_tables[[1]][["test_set"]]`, respectively
#'   
#' @return A list of lists of splitted table_list items
#'
#' @export
inputtables_to_keras <- function(final_input_tables) {
  
  if(!exists("train_set", where = final_input_tables[[1]]))
    stop('Error: Provided list does not contain a training set at location 
      "final_input_tables[[1]][["train_set"]].')
  
  if(!exists("test_set", where = final_input_tables[[1]]))
    stop('Error: Provided list does not contain a training set at location 
      "final_input_tables[[1]][["test_set"]].')
  
  
  counter <- 0
  data_list <- list()
  
  for (current_table in final_input_tables) {
    train_set <- current_table$train_set
    test_set <- current_table$test_set
    counter <- counter + 1
    current_name <- names(final_input_tables)[counter]
    response_column <- names(train_set)[ncol(train_set)]
    if(!((is.factor(train_set[[response_column]])) | is.numeric(train_set[[response_column]]))) {
      stop("Response column is neither numeric for regression nor factor for classification")
    }
      
    # separate input data "X" from response variable "y" for keras
    X_train <- as.matrix(train_set[, !names(train_set) %in% response_column])
    X_train[is.nan(X_train)] <- 0
    X_test <- as.matrix(test_set[, !names(test_set) %in% response_column])
    X_test[is.nan(X_test)] <- 0
    if (is.factor(train_set[[response_column]])) {
      # reduce level values by 1 to fit python 0-based indexing
      y_train <- keras::to_categorical(as.numeric(train_set[[response_column]]) - 1)
      y_test <- keras::to_categorical(as.numeric(test_set[[response_column]]) - 1)
      # add class levels as name attribute to matrix
      attr(y_train, "dimnames")[[2]] <- levels(train_set[[response_column]])
      attr(y_test, "dimnames")[[2]] <- levels(test_set[[response_column]])
    } else {
      y_train <- train_set[[response_column]]
      y_test <- test_set[[response_column]]
    }
    data_list[[current_name]] <- list(
      trainset_data = X_train, trainset_labels = y_train, 
      testset_data = X_test, testset_labels = y_test)
  }
  data_list 
}
