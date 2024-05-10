testthat::test_that("Is SpatRaster", {
library(traveltime)

  ext <- matrix(
    data = c("111", "0", "112", 1),
    nrow = 2,
    ncol = 2,
    dimnames = list(
      c("x", "y"),
      c("min", "max")
    )
  )

  wfs <- get_friction_surface(
    surface = "walk2020",
    extent = ext
  )

  testthat::expect_s4_class(wfs, "SpatRaster")

  from_here <- data.frame(
    x = c(111.2, 111.9),
    y = c(0.2, 0.35)
  )

  tt1 <- calculate_travel_time(
    friction_surface = wfs,
    points = from_here
  )

  testthat::expect_s4_class(tt1, "SpatRaster")

  tt2 <- calculate_travel_time(
    friction_surface = wfs,
    points = from_here,
    file_name = tempfile(fileext = ".tif")
  )

  testthat::expect_s4_class(tt2, "SpatRaster")
})
