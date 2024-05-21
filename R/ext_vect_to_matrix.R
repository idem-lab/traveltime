#' @title Extent vector to matrix
#'
#' @param x `numeric` length 4, consisting of `c(xmin, xmax, ymin, ymax)`
#' dimensions of extent
#'
#' @return 2x2 `matrix`
#' @export
#'
#' @examples
#'
#' ext_vect_to_matrix(c(111,112,0, 1))
#'
ext_vect_to_matrix <- function(x){

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
