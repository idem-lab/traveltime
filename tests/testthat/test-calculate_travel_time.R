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

test_that(
  desc = "aborts if no points fall within the friction surface",
  code = {
    # synthetic surface, no network dependency
    fs <- terra::rast(
      nrow = 10,
      ncol = 10,
      xmin = 0,
      xmax = 1,
      ymin = 0,
      ymax = 1,
      crs = "EPSG:4326"
    )
    terra::values(fs) <- 0.01

    expect_error(
      calculate_travel_time(
        friction_surface = fs,
        points = data.frame(x = c(5, 6), y = c(5, 6))
      ),
      regexp = "fall within"
    )
  }
)

test_that(
  desc = "warns, but does not abort, when some points fall outside the surface",
  code = {
    # synthetic surface, no network dependency
    fs <- terra::rast(
      nrow = 10,
      ncol = 10,
      xmin = 0,
      xmax = 1,
      ymin = 0,
      ymax = 1,
      crs = "EPSG:4326"
    )
    terra::values(fs) <- 0.01

    # one point inside the extent, one outside (out-of-extent origin cell is NA)
    expect_warning(
      tt <- calculate_travel_time(
        friction_surface = fs,
        points = data.frame(x = c(0.5, 9), y = c(0.5, 9))
      ),
      regexp = "outside"
    )

    expect_s4_class(tt, "SpatRaster")
    # cost distance from an origin cell is zero at the origin
    expect_equal(unname(terra::minmax(tt)[1]), 0)
  }
)
