test_that("Is SpatRaster", {

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

  expect_s4_class(wfs, "SpatRaster")

  from_here <- data.frame(
    x = c(111.2, 111.9),
    y = c(0.2, 0.35)
  )

  tt1 <- calculate_travel_time(
    friction_surface = wfs,
    points = from_here
  )

  expect_s4_class(tt1, "SpatRaster")

  tt2 <- calculate_travel_time(
    friction_surface = wfs,
    points = from_here,
    filename = tempfile(fileext = ".tif")
  )

  expect_s4_class(tt2, "SpatRaster")


  # check throws error if points is junk
  expect_error(
    calculate_travel_time(
      friction_surface = wfs,
      points = 1
    )
  )

  # check parses points as SpatVector OK
  from_here_SpatVector <- terra::vect(
    x = from_here,
    geom = c(
      "x",
      "y"
    )
  )

  tt3 <- calculate_travel_time(
    friction_surface = wfs,
    points = from_here_SpatVector,
    filename = tempfile(
      fileext = ".tif"
    )
  )

  expect_s4_class(tt3, "SpatRaster")



})

test_that(
  desc = "aborts if friction surface is not a SpatRaster",
  code = {
    expect_error(
      calculate_travel_time(
        friction_surface = TRUE
      )
    )
  }
)
