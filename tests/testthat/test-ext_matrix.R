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

test_that(
  desc = "ext_matrix fails if too long",
  code = {

    x <- c(1,2:10)

    expect_error(
      object = ext_matrix(x)
    )
  }
)

test_that(
  desc = "ext_matrix fails if double too short",
  code = {

    x <- 1

    expect_error(
      object = ext_matrix(x)
    )
  }
)

test_that(
  desc = "ext_matrix fails if integer incorrect length",
  code = {

    x <- c(1,2)

    expect_error(
      object = ext_matrix(x)
    )
  }
)



test_that(
  desc = "ext_matrix fails if dim incorrect",
  code = {

    x <- matrix(1)

    expect_error(
      object = ext_matrix(x)
    )
  }
)


test_that(
  desc = "ext_matrix fails if inappropriate class",
  code = {

    x <- "junk"

    expect_error(
      object = ext_matrix(x)
    )
  }
)

test_that(
  desc = "ext_matrix parses double",
  code = {

    x <- c(111, 112, 0, 1)

    y <- ext_matrix(extent = x)

    expect_true(
      object = inherits(
        x = y,
        what = "matrix"
      )
    )
  }
)

