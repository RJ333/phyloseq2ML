#' Turn response column levels into dummy variables.
#'
#' The factor columns of an input table must be turned into dummy tables so 
#' keras can work with it. This function detects factor columns and turns them 
#' into dummy columns. In theory, a two level factor column would be represented 
#' by two complementary columns consisting of 0 and 1, which are dependent on
#' each other. To prevent this known as the dummy trap, the first of these 
#' columns is always removed. If no factor columns are detected, the list will 
#' be returned unmodified along with an info.
#'
#' @param input_tables a list of input tables before splitting or oversampling
#'
#' @return A list input_tables with factor variable turned into dummy variables
#'
#' @export
dummify_input_tables <- function(input_tables) {
  dummy_data_list <- vector(mode = "list", length = length(input_tables))
  for (table_index in seq_along(input_tables)) {
    
    current_name <- names(input_tables)[table_index]
    current_table <- input_tables[[table_index]]
    # which of the variables are factors
    factor_column_ids <- names(current_table)[sapply(current_table, is.factor)]
    
    if (length(factor_column_ids) > 0) {
      # if factor columns present, replace those with dummy columns
      tmp <- fastDummies::dummy_cols(current_table, remove_first_dummy = TRUE)
      #print(names(tmp))
      #print(!names(tmp) %in% factor_column_ids)
      row.names(tmp) <- row.names(current_table)
      # only update the former factor columns
      dummy_data_list[[table_index]] <- tmp[ , !names(tmp) %in% factor_column_ids]
      futile.logger::flog.info("names of columns changed to dummy columns: \n", 
        factor_column_ids, "\n")
    } else {
      dummy_data_list[[table_index]] <- current_table
      futile.logger::flog.info("No categorical columns detected, returning unmodified input table")
    }
    # pass the names on
    names(dummy_data_list)[table_index] <- current_name
  }
  dummy_data_list
}
