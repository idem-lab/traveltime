#' @title Convert extent to matrix
#'
#' @description
#' This function converts from formats ...
#' TODO - explain why we need to do this, which is that we need a special esoteric format
#'
#' @param x `numeric` length 4, consisting of `c(xmin, xmax, ymin, ymax)`
#' dimensions of extent
#'
#' @return 2x2 `matrix` - explain esoteric format of matrix
#'
#' @examples
#' ext_matrix(c(111,112,0, 1))
#' # TODO
#' # add examples of all SpatRaster, SpatVector, etc.
#' @export
ext_matrix <- function(x, ...){
  UseMethod("ext_matrix")
}

#' @export
ext_matrix.SpatExtent <- function(x, ...){
  extent <- ext_vect_to_matrix(x)
  extent
}

#' @export
ext_matrix.SpatRaster <- function(x, ...){
  extent <- ext_from_terra(x)
  extent
}

#' @export
ext_matrix.SpatVector <- function(x, ...){
  extent <- ext_from_terra(x)
  extent
}

#' @export
ext_matrix.vector <- function(x){
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
ext_matrix.matrix <- function(x, ...){
  is_2x2 <- identical(dim(x), c(2L,2L))
  if(!is_2x2){
    cli::cli_abort(
      message = c(
        "If {.arg x} is of class, {.cls matrix}, it must have dimensions: 2x2",
        "However, we see that {.arg x} has dimensions: \\
        {.val {paste0(dim(x), collapse = 'x')}}."
        )
    )
  }
}

#' @export
ext_matrix.default <- function(x, ...){
  cli::cli_abort(
    message = c(
      "{.arg extent} must be of class {.cls numeric, matrix, \\
      SpatExtent, SpatRaster}",
      "But we see class: {.cls {class(x)}."
      )
  )
}
