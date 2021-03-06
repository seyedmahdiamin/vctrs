#' A 1d vector of unspecified type
#'
#' This is a [partial type](new_partial) used to represent logical vectors
#' that only contain `NA`. These require special handling because we want to
#' allow `NA` to specify missingness without requiring a type.
#'
#' @keywords internal
#' @param n Length of vector
#' @export
#' @examples
#' vec_ptype()
#' vec_ptype(NA)
#'
#' vec_c(NA, factor("x"))
#' vec_c(NA, Sys.Date())
#' vec_c(NA, Sys.time())
#' vec_c(NA, list(1:3, 4:5))
unspecified <- function(n = 0) {
  .Call(vctrs_unspecified, n)
}

#' @export
`[.vctrs_unspecified` <- function(x, i, ...) {
  unspecified(length(NextMethod()))
}

#' @export
print.vctrs_unspecified <- function(x, ...) {
  cat("<unspecified> [", length(x), "]\n", sep = "")
}

#' @export
vec_ptype_abbr.vctrs_unspecified <- function(x) {
  "???"
}

is_unspecified <- function(x) {
  .Call(vctrs_is_unspecified, x)
}

ununspecify <- function(x) {
  if (is_unspecified(x)) {
    new_logical(length(x))
  } else {
    x
  }
}

# Type system -------------------------------------------------------------

#' @rdname unspecified
#' @export vec_type2.vctrs_unspecified
#' @export
vec_type2.vctrs_unspecified <- function(x, y, ...) vec_type(y)

#' @method vec_type2.logical vctrs_unspecified
#' @export
vec_type2.logical.vctrs_unspecified <- function(x, y, ...) vec_type(x)
#' @method vec_type2.integer vctrs_unspecified
#' @export
vec_type2.integer.vctrs_unspecified <- function(x, y, ...) vec_type(x)
#' @method vec_type2.double vctrs_unspecified
#' @export
vec_type2.double.vctrs_unspecified <- function(x, y, ...) vec_type(x)
#' @method vec_type2.character vctrs_unspecified
#' @export
vec_type2.character.vctrs_unspecified <- function(x, y, ...) vec_type(x)
#' @method vec_type2.factor vctrs_unspecified
#' @export
vec_type2.factor.vctrs_unspecified <- function(x, y, ...) vec_type(x)
#' @method vec_type2.ordered vctrs_unspecified
#' @export
vec_type2.ordered.vctrs_unspecified <- function(x, y, ...) vec_type(x)
#' @method vec_type2.list vctrs_unspecified
#' @export
vec_type2.list.vctrs_unspecified <- function(x, y, ...) vec_type(x)
#' @method vec_type2.vctrs_list_of vctrs_unspecified
#' @export
vec_type2.vctrs_list_of.vctrs_unspecified <- function(x, y, ...) vec_type(x)
#' @method vec_type2.Date vctrs_unspecified
#' @export
vec_type2.Date.vctrs_unspecified <- function(x, y, ...) vec_type(x)
#' @method vec_type2.POSIXt vctrs_unspecified
#' @export
vec_type2.POSIXt.vctrs_unspecified <- function(x, y, ...) vec_type(x)
#' @method vec_type2.difftime vctrs_unspecified
#' @export
vec_type2.difftime.vctrs_unspecified <- function(x, y, ...) vec_type(x)
