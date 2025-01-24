test_that("extent is extent", {

  r <- terra::rast(
     extent = terra::ext(c(111, 112, 0, 1))
   )

  x <- ext_matrix(r)

  expect_type(x, "double")
  expect_true(inherits(x, "matrix"))
  expect_equal(dim(x), c(2, 2))

  v <- terra::vect(
    x = terra::ext(c(111, 112, 0, 1))
  )

  y <- ext_matrix(v)

  expect_type(y, "double")
  expect_true(inherits(y, "matrix"))
  expect_equal(dim(y), c(2, 2))

})
