test_that("Are SpatRasters", {
  ext <- matrix(
    data = c("111", "0", "112", 1),
    nrow = 2,
    ncol = 2,
    dimnames = list(
      c("x", "y"),
      c("min", "max")
    )
  )

  mfs <- get_friction_surface(
    surface = "motor2020",
    extent = ext,
    file_name = tempfile(fileext = ".tif")
  )

  expect_s4_class(mfs, "SpatRaster")

  wfs <- get_friction_surface(
    surface = "walk2020",
    extent = ext
  )

  expect_s4_class(wfs, "SpatRaster")

})
