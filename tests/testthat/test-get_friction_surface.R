test_that("Are SpatRasters", {

  # downloads friction surface from the Malaria Atlas Project
  skip_on_cran()
  skip_if_offline()
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
    filename = tempfile(fileext = ".tif")
  )

  expect_s4_class(mfs, "SpatRaster")

  wfs <- get_friction_surface(
    surface = "walk2020",
    extent = ext
  )

  expect_s4_class(wfs, "SpatRaster")

})


test_that(
  desc = "throws error",
  code = {
    expect_error(
      get_friction_surface(
        extent = NULL
      )
    )
  }
)

test_that(
  desc = "fails gracefully with a warning and NULL if download fails",
  code = {
    local_mocked_bindings(
      getRaster = function(...) stop("Failed to connect to MAP geoserver"),
      .package = "malariaAtlas"
    )

    expect_warning(
      fs <- get_friction_surface(
        surface = "walk2020",
        extent = c(111, 112, 0, 1)
      ),
      regexp = "Could not download"
    )

    expect_null(fs)
  }
)

test_that(
  desc = "returns NULL with a warning if download is not a SpatRaster",
  code = {
    local_mocked_bindings(
      getRaster = function(...) "not a raster",
      .package = "malariaAtlas"
    )

    expect_warning(
      fs <- get_friction_surface(
        surface = "motor2020",
        extent = c(111, 112, 0, 1)
      ),
      regexp = "did not return"
    )

    expect_null(fs)
  }
)

test_that(
  desc = "returns existing file without downloading if overwrite is FALSE",
  code = {
    f <- tempfile(fileext = ".tif")
    r <- terra::rast(nrow = 2, ncol = 2, vals = 1)
    terra::writeRaster(r, f)

    local_mocked_bindings(
      getRaster = function(...) stop("should not be called"),
      .package = "malariaAtlas"
    )

    expect_warning(
      fs <- get_friction_surface(
        surface = "motor2020",
        extent = c(111, 112, 0, 1),
        filename = f
      ),
      regexp = "already exists"
    )

    expect_s4_class(fs, "SpatRaster")
  }
)
