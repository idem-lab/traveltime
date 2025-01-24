#' @title Convert extent to matrix
#'
#' @description
#' This function allows `get_friction_surface()` to accept the argument `extent` as a `vector`, 2x2 `matrix`, `SpatVector`, or `SpatRaster` and extracts and converts into the annoyingly specific format necessary to download the friction surface. See details in `?get_friction_surface`
#'
#' @param extent `vector` of length 4, 2x2 `matrix`, `SpatExtent`, `SpatVector`, or `SpatRaster`
#'
#' @return 2x2 `matrix` with column names "x" and "y" and row names "min"
#'  and "max"
#'
#' @examples
#' # vector/double
#' x <- c(111, 112, 0, 1)
#' ext_matrix(x)
#'
#' # SpatExtent
#' y <-  terra::ext(x)
#' ext_matrix(y)
#'
#' # SpatRaster
#' r <- terra::rast(extent = y)
#' ext_matrix(r)
#'
#' # SpatVector
#' v <- terra::vect(y)
#' ext_matrix(v)
#'
#' @export
ext_matrix <- function(extent){
  UseMethod("ext_matrix")
}

#' @export
ext_matrix.SpatExtent <- function(extent){
  extent <- ext_vect_to_matrix(extent)
  extent
}

#' @export
ext_matrix.SpatRaster <- function(extent){
  extent <- ext_from_terra(extent)
  extent
}

#' @export
ext_matrix.SpatVector <- function(extent){
  extent <- ext_from_terra(extent)
  extent
}

#' @export
ext_matrix.double <- function(extent){
  if (length(extent) != 4){
    cli::cli_abort(
      message = c(
        "{.arg extent} as numeric must be length 4",
        "We see {.arg extent} has having length: {.val {length(extent)}}."
        )
    )
  }
  extent <- ext_vect_to_matrix(extent)
  extent
}

#' @export
ext_matrix.matrix <- function(extent){
  is_2x2 <- identical(dim(extent), c(2L,2L))
  if(!is_2x2){
    cli::cli_abort(
      message = c(
        "If {.arg extent} is of class, {.cls matrix}, it must have dimensions: 2x2",
        "However, we see that {.arg x} has dimensions: \\
        {.val {paste0(dim(extent), collapse = 'x')}}."
        )
    )
  }
  extent
}

#' @export
ext_matrix.default <- function(extent){
  cli::cli_abort(
    message = c(
      "{.arg extent} must be of class {.cls numeric, matrix, \\
      SpatExtent, SpatRaster, SpatVector}",
      "But we see class: {.cls {class(extent)}}."
      )
  )
}
