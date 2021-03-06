context("test-names")


# vec_names() ---------------------------------------------------------

test_that("vec_names() retrieves names", {
  expect_null(vec_names(letters))
  expect_identical(vec_names(set_names(letters)), letters)
  expect_null(vec_names(mtcars))
  expect_identical(vec_names(Titanic), dimnames(Titanic)[[1]])
})

test_that("vec_names() dispatches", {
  scoped_global_bindings(
    names.vctrs_foobar = function(x) "dispatched!"
  )
  expect_identical(vec_names(foobar()), "dispatched!")
})

test_that("vec_names<- sets names", {
  x <- letters
  vec_names(x) <- letters
  expect_identical(vec_names(x), letters)
  vec_names(x) <- NULL
  expect_null(vec_names(x))

  y <- iris
  vec_names(y) <- as.character(-seq_len(vec_size(y)))
  expect_identical(row.names(y), row.names(iris))
  expect_null(vec_names(y))

  z <- ones(3, 2, 1)
  vec_names(z) <- as.character(1:3)
  expect_identical(vec_names(z), as.character(1:3))
})


# vec_names2() -------------------------------------------------------------

test_that("vec_names2() repairs names", {
  expect_identical(vec_names2(1:2), c("", ""))
  expect_identical(vec_names2(1:2, repair = "unique"), c("...1", "...2"))
  expect_identical(vec_names2(set_names(1:2, c("_foo", "_bar")), repair = "universal"), c("._foo", "._bar"))
})

test_that("vec_names2() treats data frames and arrays as vectors", {
  expect_identical(vec_names2(mtcars), rep_len("", nrow(mtcars)))
  expect_identical(vec_names2(as.matrix(mtcars)), row.names(mtcars))
})

test_that("vec_names2() accepts and checks repair function", {
  expect_identical(vec_names2(1:2, repair = function(nms) rep_along(nms, "foo")), c("foo", "foo"))
  expect_error(vec_names2(1:2, repair = function(nms) "foo"), "length 1 instead of length 2")
})

test_that("vec_names2() repairs names before invoking repair function", {
  x <- set_names(1:2, c(NA, NA))
  expect_identical(vec_names2(x, repair = identity), c("", ""))
})


# vec_as_names() -----------------------------------------------------------

test_that("vec_as_names() requires character vector", {
  expect_error(vec_as_names(NULL), "`names` must be a character vector")
})

test_that("vec_as_names() repairs names", {
  expect_identical(vec_as_names(chr(NA, NA)), c("", ""))
  expect_identical(vec_as_names(chr(NA, NA), repair = "unique"), c("...1", "...2"))
  expect_identical(vec_as_names(chr("_foo", "_bar"), repair = "universal"), c("._foo", "._bar"))
})

test_that("vec_as_names() accepts and checks repair function", {
  expect_identical(vec_as_names(c("", ""), repair = ~ rep_along(.x, "foo")), c("foo", "foo"))
  expect_error(vec_as_names(c("", ""), repair = function(nms) "foo"), "length 1 instead of length 2")
})

test_that("vec_as_names() repairs names before invoking repair function", {
  expect_identical(vec_as_names(chr(NA, NA), repair = identity), c("", ""))
})

test_that("validate_minimal_names() checks names", {
  expect_error(validate_minimal(1), "must return a character vector")
  expect_error(validate_minimal(NULL), "can't return `NULL`")
  expect_error(validate_minimal(chr(NA)), "can't return `NA` values")
})


# vec_repair_names() -------------------------------------------------------

test_that("vec_repair_names() repairs names", {
  expect_identical(vec_repair_names(1:2), set_names(1:2, c("", "")))
  expect_identical(vec_repair_names(1:2, "unique"), set_names(1:2, c("...1", "...2")))
  expect_identical(vec_repair_names(set_names(1:2, c("_foo", "_bar")), "universal"), set_names(1:2, c("._foo", "._bar")))
})

test_that("vec_repair_names() handles data frames and arrays", {
  df <- data.frame(x = 1:2)
  expect_identical(vec_repair_names(df), df)
  expect_identical(row.names(vec_repair_names(as.matrix(df))), c("", ""))
  expect_identical(row.names(vec_repair_names(as.matrix(df), "unique")), c("...1", "...2"))
})


# minimal names -------------------------------------------------------------

test_that("minimal names are made from `n` when `name = NULL`", {
  expect_identical(minimal_names(1:2), c("", ""))
})

test_that("as_minimal_names() checks input", {
  expect_error(as_minimal_names(1:3), "must be a character vector")
})

test_that("minimal names have '' instead of NAs", {
  expect_identical(as_minimal_names(c("", NA, "", NA)), c("", "", "", ""))
})

test_that("repairing minimal names copes with NULL input names", {
  x <- 1:3
  x_named <- vec_repair_names(x)
  expect_equal(names(x_named), rep("", 3))
})

test_that("as_minimal_names() is idempotent", {
  x <- c("", "", NA)
  expect_identical(as_minimal_names(x), as_minimal_names(as_minimal_names(x)))
})

test_that("minimal_names() treats data frames and arrays as vectors", {
  expect_identical(minimal_names(mtcars), rep_len("", nrow(mtcars)))
  expect_identical(minimal_names(as.matrix(mtcars)), row.names(mtcars))
})

test_that("as_minimal_names() copies on write", {
  nms <- chr(NA, NA)
  as_minimal_names(nms)
  expect_identical(nms, chr(NA, NA))

  nms <- c("a", "b")
  out <- as_minimal_names(nms)
  expect_true(is_reference(nms, out))
})


# unique names -------------------------------------------------------------

test_that("unique_names() handles unnamed vectors", {
  expect_identical(unique_names(1:3), c("...1", "...2", "...3"))
})

test_that("as_unique_names() is a no-op when no repairs are needed", {
  x <- c("x", "y")
  out <- as_unique_names(x)
  expect_true(is_reference(out, x))
  expect_identical(out, c("x", "y"))
})

test_that("as_unique_names() eliminates emptiness and duplication", {
  x <- c("", "x", "y", "x")
  expect_identical(as_unique_names(x), c("...1", "x...2", "y", "x...4"))
})

test_that("solo empty or NA gets suffix", {
  expect_identical(as_unique_names(""), "...1")
  expect_identical(as_unique_names(NA_character_), "...1")
})

test_that("ellipsis treated like empty string", {
  expect_identical(as_unique_names("..."), as_unique_names(""))
})

test_that("two_three_dots() does its job and no more", {
  x <- c(".", ".1", "...1", "..1a")
  expect_identical(two_to_three_dots(x), x)

  expect_identical(two_to_three_dots(c("..1", "..22")), c("...1", "...22"))
})

test_that("two dots then number treated like three dots then number", {
  expect_identical(as_unique_names("..2"), as_unique_names("...5"))
})

test_that("as_unique_names() strips positional suffixes, re-applies as needed", {
  x <- c("...20", "a...1", "b", "", "a...2...34")
  expect_identical(as_unique_names(x), c("...1", "a...2", "b", "...4", "a...5"))

  expect_identical(as_unique_names("a...1"), "a")
  expect_identical(as_unique_names(c("a...2", "a")), c("a...1", "a...2"))
  expect_identical(as_unique_names(c("a...3", "a", "a")), c("a...1", "a...2", "a...3"))
  expect_identical(as_unique_names(c("a...2", "a", "a")), c("a...1", "a...2", "a...3"))
  expect_identical(as_unique_names(c("a...2", "a...2", "a...2")), c("a...1", "a...2", "a...3"))
})

test_that("as_unique_names() is idempotent", {
  x <- c("...20", "a...1", "b", "", "a...2")
  expect_identical(as_unique_names(!!x), as_unique_names(as_unique_names(!!x)))
})

test_that("unique-ification has an 'algebraic'-y property", {
  ## inspired by, but different from, this guarantee about base::make.unique()
  ## make.unique(c(A, B)) == make.unique(c(make.unique(A), B))
  ## If A is already unique, then make.unique(c(A, B)) preserves A.

  ## I haven't formulated what we guarantee very well yet, but it's probably
  ## implicit in this test (?)

  x <- c("...20", "a...1", "b", "", "a...2", "d")
  y <- c("", "a...3", "b", "...3", "e")

  ## fix names on each, catenate, fix the whole
  z1 <- as_unique_names(
    c(
      as_unique_names(x), as_unique_names(y)
    )
  )

  ## fix names on x, catenate, fix the whole
  z2 <- as_unique_names(
    c(
      as_unique_names(x), y
    )
  )

  ## fix names on y, catenate, fix the whole
  z3 <- as_unique_names(
    c(
      x, as_unique_names(y)
    )
  )

  ## catenate, fix the whole
  z4 <- as_unique_names(
    c(
      x, y
    )
  )

  expect_identical(z1, z2)
  expect_identical(z1, z3)
  expect_identical(z1, z4)
})

test_that("unique_names() and as_unique_names() are verbose or silent", {
  expect_message(unique_names(1:2), "-> ...1", fixed = TRUE)
  expect_message(as_unique_names(c("", "")), "-> ...1", fixed = TRUE)

  expect_message(regexp = NA, unique_names(1:2, quiet = TRUE))
  expect_message(regexp = NA, as_unique_names(c("", ""), quiet = TRUE))
})


# Universal names ----------------------------------------------------------

test_that("zero-length input", {
  expect_equal(as_universal_names(character()), character())
})

test_that("universal names are not changed", {
  expect_equal(as_universal_names(letters), letters)
})

test_that("as_universal_names() is idempotent", {
  x <- c(NA, "", "x", "x", "a1:", "_x_y}")
  expect_identical(as_universal_names(x), as_universal_names(as_universal_names(x)))
})

test_that("dupes get a suffix", {
  expect_equal(
    as_universal_names(c("a", "b", "a", "c", "b")),
    c("a...1", "b...2", "a...3", "c", "b...5")
  )
})

test_that("solo empty or NA gets suffix", {
  expect_identical(as_universal_names(""), "...1")
  expect_identical(as_universal_names(NA_character_), "...1")
})

test_that("ellipsis treated like empty string", {
  expect_identical(as_universal_names("..."), as_universal_names(""))
})

test_that("solo dot is unchanged", {
  expect_equal(as_universal_names("."), ".")
})

test_that("dot, dot gets suffix", {
  expect_equal(as_universal_names(c(".", ".")), c("....1", "....2"))
})

test_that("dot-dot, dot-dot gets suffix", {
  expect_equal(as_universal_names(c("..", "..")), c(".....1", ".....2"))
})

test_that("empty, dot becomes suffix, dot", {
  expect_equal(as_universal_names(c("", ".")), c("...1", "."))
})

test_that("empty, empty, dot becomes suffix, suffix, dot", {
  expect_equal(as_universal_names(c("", "", ".")), c("...1", "...2", "."))
})

test_that("dot, dot, empty becomes suffix, suffix, suffix", {
  expect_equal(as_universal_names(c(".", ".", "")), c("....1", "....2", "...3"))
})

test_that("dot, empty, dot becomes suffix, suffix, suffix", {
  expect_equal(as_universal_names(c(".", "", ".")), c("....1", "...2", "....3"))
})

test_that("empty, dot, empty becomes suffix, dot, suffix", {
  expect_equal(as_universal_names(c("", ".", "")), c("...1", ".", "...3"))
})

test_that("'...j' gets stripped then names are modified", {
  expect_equal(as_universal_names(c("...6", "...1...2")), c("...1", "...2"))
  expect_equal(as_universal_names("if...2"), ".if")
})

test_that("complicated inputs", {
  expect_equal(
    as_universal_names(c("", ".", NA, "if...4", "if", "if...8", "for", "if){]1")),
    c("...1", ".", "...3", ".if...4", ".if...5", ".if...6", ".for", "if...1")
  )
})

test_that("message", {
  expect_message(
    as_universal_names(c("a b", "b c")),
    "New names:\n* `a b` -> a.b\n* `b c` -> b.c\n",
    fixed = TRUE
  )
})

test_that("quiet", {
  expect_message(
    as_universal_names("", quiet = TRUE),
    NA
  )
})

test_that("unique then universal is universal, with shuffling", {
  x <- c("", ".2", "..3", "...4", "....5", ".....6", "......7", "...")
  expect_identical(as_universal_names(as_unique_names(x)), as_universal_names(x))

  x2 <- x[c(7L, 4L, 3L, 6L, 5L, 1L, 2L, 8L)]
  expect_identical(as_universal_names(as_unique_names(x2)), as_universal_names(x2))

  x3 <- x[c(3L, 2L, 4L, 6L, 8L, 1L, 5L, 7L)]
  expect_identical(as_universal_names(as_unique_names(x3)), as_universal_names(x3))
})

test_that("zero-length inputs given character names", {
  out <- vec_repair_names(character(), "universal")
  expect_equal(names(out), character())
})

test_that("unnamed input gives uniquely named output", {
  out <- vec_repair_names(1:3, "universal")
  expect_equal(names(out), c("...1", "...2", "...3"))
})

test_that("messages by default", {
  expect_message(
    vec_repair_names(set_names(1, "a:b"), "universal"),
    "New names:\n* `a:b` -> a.b\n",
    fixed = TRUE
  )
})

test_that("quiet = TRUE", {
  expect_message(vec_repair_names(set_names(1, ""), "universal", quiet = TRUE), NA)
})

test_that("non-universal names", {
  out <- vec_repair_names(set_names(1, "a b"), "universal")
  expect_equal(names(out), "a.b")

  expect_equal(as_universal_names("a b"), "a.b")
})


# make_syntactic() ---------------------------------------------------------

test_that("make_syntactic(): empty or NA", {
  expect_syntactic(
      c("", NA_character_),
      c(".", ".")
  )
})

test_that("make_syntactic(): reserved words", {
  expect_syntactic(
    c("if", "TRUE", "Inf", "NA_real_", "normal"),
    c(".if", ".TRUE", ".Inf", ".NA_real_", "normal")
  )
})

test_that("make_syntactic(): underscore", {
  expect_syntactic(
    c( "_",  "_1",  "_a}"),
    c("._", "._1", "._a.")
  )
})

test_that("make_syntactic(): dots", {
  expect_syntactic(
    c(".", "..",  "...", "...."),
    c(".", "..", "....", "....")
  )
})

test_that("make_syntactic(): number", {
  expect_syntactic(
      c(   "0",    "1",    "22",    "333"),
      c("...0", "...1", "...22", "...333")
  )
})

test_that("make_syntactic(): number then character", {
  expect_syntactic(
    c(  "0a",   "1b",   "22c",   "333d"),
    c("..0a", "..1b", "..22c", "..333d")
  )
})

test_that("make_syntactic(): number then non-character", {
  expect_syntactic(
    c(  "0)",   "1&",   "22*",   "333@"),
    c("..0.", "..1.", "..22.", "..333.")
  )
})

test_that("make_syntactic(): dot then number", {
  expect_syntactic(
    c(  ".0",   ".1",   ".22",   ".333"),
    c("...0", "...1", "...22", "...333")
  )
})

test_that("make_syntactic(): dot then number then character", {
  expect_syntactic(
    c( ".0a",  ".1b",  ".22c",  ".333d"),
    c("..0a", "..1b", "..22c", "..333d")
  )
})

test_that("make_syntactic(): dot then number then non-character", {
  expect_syntactic(
    c( ".0)",  ".1&",  ".22*",  ".333@"),
    c("..0.", "..1.", "..22.", "..333.")
  )
})

test_that("make_syntactic(): dot dot then number", {
  expect_syntactic(
    c( "..0",  "..1",  "..22",  "..333"),
    c("...0", "...1", "...22", "...333")
  )
})

test_that("make_syntactic(): dot dot dot then number", {
  expect_syntactic(
    c("...0", "...1", "...22", "...333"),
    c("...0", "...1", "...22", "...333")
  )
})

test_that("make_syntactic(): dot dot dot dot then number", {
  expect_syntactic(
    c("....0", "....1", "....22", "....333"),
    c("....0", "....1", "....22", "....333")
  )
})

test_that("make_syntactic(): dot dot dot dot dot then number", {
  expect_syntactic(
    c(".....0", ".....1", ".....22", ".....333"),
    c(".....0", ".....1", ".....22", ".....333")
  )
})

test_that("make_syntactic(): dot dot then number then character", {
  expect_syntactic(
    c("..0a", "..1b", "..22c", "..333d"),
    c("..0a", "..1b", "..22c", "..333d")
  )
})

test_that("make_syntactic(): dot dot then number then non-character", {
  expect_syntactic(
    c("..0)", "..1&", "..22*", "..333@"),
    c("..0.", "..1.", "..22.", "..333.")
  )
})
