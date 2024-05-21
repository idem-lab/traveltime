test_that("ext vect to matrix", {
  x <- ext_vect_to_matrix(c(111,112,0, 1))

  expect_is(x, "matrix")

  expect_equal(dim(x), c(2, 2))

})
