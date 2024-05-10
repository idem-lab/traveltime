#' @title Extent from `SpatRaster` or `SpatVector`
#' @description Formats spatial extent for use in `get_friction_surface`.
#'
#' @param r `terra::SpatRaster` or `terra::SpatVector`
#'
#' @return 2x2 `matrix`
#' @export
#'
#' @examples
#'
#' library(terra)
#' r <- terra::rast(
#'     extent = terra::ext(c(111, 112, 0, 1))
#'   )
#'
#' ext_from_terra(r)
ext_from_terra <- function(r){

  x <- terra::ext(r)

  matrix(
    data = c(x[1], x[3], x[2], x[4]),
    nrow = 2,
    ncol = 2,
    dimnames = list(
      c("x", "y"),
      c("min", "max")
    )
  )

}
