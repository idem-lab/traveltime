testthat::test_that("extent is extent", {

  r <- terra::rast(
     extent = terra::ext(c(111, 112, 0, 1))
   )

  x <- ext_from_spatraster(r)

  testthat::expect_is(x, "matrix")

  testthat::expect_equal(dim(x), c(2, 2))
})
