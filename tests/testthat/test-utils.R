test_that(
  desc = "Warn and return throws error",
  code = {

    temptif <- tempfile(
      fileext = ".tif"
    )

    temprast <- terra::rast()

    temprast[] <- 1

    terra::writeRaster(
      x = temprast,
      filename = temptif
    )

    temprast <- terra::rast(
      x = temptif
    )


    expect_warning(
      existing <- warn_and_return(
        filename = temptif,
        overwrite = FALSE
      )
    )

    expect_s4_class(existing, "SpatRaster")

    # nothing to return if no filename, or if overwriting
    expect_null(warn_and_return(filename = NULL, overwrite = FALSE))
    expect_null(warn_and_return(filename = temptif, overwrite = TRUE))

  }
)
