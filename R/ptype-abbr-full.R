#' Vector type as a string
#'
#' `vec_ptype_full()` displays the full type of the vector. `vec_ptype_abbr()`
#' provides an abbreviated summary suitable for use in a column heading.
#'
#' @section S3 dispatch:
#' The default method for `vec_ptype_full()` uses the first element of the
#' class vector. Override this method if your class has parameters that should
#' be prominently displayed.
#'
#' The default method for `vec_ptype_abbr()` [abbreviate()]s `vec_ptype_full()`
#' to 8 characters. You should almost always override, aiming for 4-6
#' characters where possible.
#'
#' @param x A vector.
#' @keywords internal
#' @return A string.
#' @export
#' @examples
#' cat(vec_ptype_full(1:10))
#' cat(vec_ptype_full(iris))
#'
#' cat(vec_ptype_abbr(1:10))
vec_ptype_full <- function(x) {
  UseMethod("vec_ptype_full")
}

#' @export
#' @rdname vec_ptype_full
vec_ptype_abbr <- function(x) {
  UseMethod("vec_ptype_abbr")
}

vec_ptype_full.NULL <- function(x) "NULL"
vec_ptype_abbr.NULL <- function(x) "NULL"

# Default: base types and fallback for S3/S4 ------------------------------

#' @export
vec_ptype_full.default <- function(x) {
  if (is.object(x)) {
    class(x)[[1]]
  } else if (is_vector(x)) {
    paste0(typeof(x), vec_ptype_shape(x))
  } else {
    abort("Not a vector.")
  }
}

#' @export
vec_ptype_abbr.default <- function(x) {
  if (is.object(x)) {
    unname(abbreviate(vec_ptype_full(x), 8))
  } else if (is_vector(x)) {
    abbr <- switch(typeof(x),
      logical = "lgl",
      integer = "int",
      double = "dbl",
      character = "chr",
      complex = "cpl",
      list = "list",
      expression = "expr"
    )
    paste0(abbr, vec_ptype_shape(x))
  } else {
    abort("Not a vector.")
  }
}

# AsIs --------------------------------------------------------------------

#' @export
vec_ptype_full.AsIs <- function(x) {
  class(x) <- setdiff(class(x), "AsIs")
  paste0("I<", vec_ptype_full(x), ">")
}

#' @export
vec_ptype_abbr.AsIs <- function(x) {
  class(x) <- setdiff(class(x), "AsIs")
  paste0("I<", vec_ptype_abbr(x), ">")
}

# Helpers -----------------------------------------------------------------

vec_ptype_shape <- function(x) {
  dim <- vec_dim(x)
  if (length(dim) == 1) {
    ""
  } else {
    paste0("[,", paste(dim[-1], collapse = ","), "]")
  }
}
