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
      warn_and_return(
        filename = temptif,
        overwrite = FALSE
      )
    )

    # returned_rast <- warn_and_return(
    #   filename = temptif,
    #   overwrite = FALSE
    # )
#
#     expect_s4_class(
#       object = warn_and_return(
#         filename = temptif,
#         overwrite = FALSE
#       ),
#       class = "SpatRaster"
#     )

  }
)
