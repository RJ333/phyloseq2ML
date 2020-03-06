#' Tests if a numeric vector is completely consisting of integers
#'
#' This function can be used to distinguish e.g. dummy variables (only 0 and 1) 
#' from other numeric columns. Applying to non numeric columns will fail. It also
#' allows for negative whole numbers and decimals with no rest e.g. 3.0, as this
#' can be a matter of print formatting rather of type
#' 
#' @param x the vector to be tested, use `sapply(x, is.wholenumber)` for a data frame
#' @param tolerance numerical specifying the tolerance for rounding a value.
#'   defaults to `.Machine$double.eps^0.5`
#'
#' @return A logical vector returning TRUE for column(s) that are completely integers 
#'
#' @export
is.wholenumber <- function(x, tolerance = .Machine$double.eps^0.5)  {
  all(abs(x - round(x)) < tolerance)
}

#' Tests if a vector is a dummy column
#'
#' This function identifies specifically dummy variables (only 0 and 1) 
#' from all other column types. 1.0 as single value returns TRUE, which is a 
#' matter of print formatting rather of type
#' 
#' @param x the vector to be tested, use `sapply(x, is.wholenumber)` for a data 
#'   frame. Strict testing using 'vapply(x, FUN = is.dummy, FUN.VALUE = logical(1)`
#'
#' @return A logical vector returning TRUE for column(s) that only contain 0 and/or 1
#'
#' @export
is.dummy <- function(x) {
  all(sort(unique(x)) %in% c(0, 1)) == TRUE
}
