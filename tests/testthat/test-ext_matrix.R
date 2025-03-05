test_that(
  desc = "takes SpatExtent",
  code = {
    x <- c(111, 112, 0, 1)

    y <-  terra::ext(x)

    z <- ext_matrix(y)

    expect_type(
      object = z,
      type = "double"
    )

    expect_equal(
      object = dim(z),
      expected = c(2, 2)
    )
  }
)
