#' @title Calculate travel time
#' @description Calculate the travel time from a set of points over a friction
#'   surface.
#'
#'
#' @param friction_surface A `SpatRaster` friction surface layer in
#'   resistance units. See Details.
#' @param points A two-column `matrix`, `data.frame`, (including `tibble` types)
#'   with longitude (x) in the first column and latitude (y) in the second, or a
#'   `SpatVector`, in the same coordinate reference system as
#'   `friction_surface`. Points that fall outside `friction_surface` are dropped
#'   with a warning; if none fall within it, an error is raised.
#' @param filename `character`. Output file name with extension suitable for
#'   `terra::writeRaster`. If `NULL` (default), output will be returned in
#'   memory
#' @param overwrite `logical`. If `TRUE` `filename` is overwritten. If `FALSE`
#'   (default) and `filename` already exists, the existing file is returned
#'   with a warning and no calculation is performed.
#'
#' @details Implements methods from Weiss et al. 2018, 2020 to calculate travel
#'   time from given locations over a friction surface.
#'
#'   Over large areas this function can require significant RAM and will be
#'   slow.
#'
#'   Pre-prepared walking or motorised friction surfaces can be obtained
#'   with [get_friction_surface()]. Users can also provide their own friction
#'   surface. This surface must be in resistance units (1/conductance), e.g.
#'   minutes/meter. See Van Etten 2017.
#'
#'   Note on this implementation: as of package version 1. Earlier versions of
#'   this package  used the `raster` and `gdistance` packages. These
#'   dependencies have been removed and now instead rely exclusively on `terra`
#'   for spatial data handling. The two approaches use the same cost model
#'   (eight-direction movement, edge cost `distance * mean(friction)`) and
#'   produce effectively the same result. `terra::costDist()` computes true
#'   geodesic inter-cell distances, so the new approach is *more* accurate than
#'   the old `gdistance`'s distance approximation away from the equator (the
#'   results are identical at the equator and for projected coordinate systems).
#'   The remaining difference is a boundary convention at the origins:
#'   `gdistance` includes half of the starting cell's own friction when leaving
#'   a point, whereas `terra::costDist` measures cost to the border of the
#'   origin cells and omits it. This appears as a small, near-constant offset
#'   (about half a cell of friction) close to the origin points. See the
#'   validation article
#'   <https://idem-lab.github.io/traveltime/articles/costdist-validation.html>
#'   for the full comparison.
#'
#'   Citations:
#'
#'   D. J. Weiss, A. Nelson, C. A. Vargas-Ruiz, K. Gligoric, S., Bavadekar, E.
#'   Gabrilovich, A. Bertozzi-Villa, J. Rozier, H. S. Gibson, T., Shekel, C.
#'   Kamath, A. Lieber, K. Schulman, Y. Shao, V. Qarkaxhija, A. K. Nandi, S. H.
#'   Keddie, S. Rumisha, P. Amratia, R. Arambepola, E. G. Chestnutt, J. J.
#'   Millar, T. L. Symons, E. Cameron, K. E. Battle, S. Bhatt, and P. W.
#'   Gething. Global maps of travel time to healthcare facilities. (2020) Nature
#'   Medicine. \doi{10.1038/s41591-020-1059-1}
#'
#'   D. J. Weiss, A. Nelson, H.S. Gibson, W. Temperley, S. Peedell, A. Lieber,
#'   M. Hancher, E. Poyart, S. Belchior, N. Fullman, B. Mappin, U. Dalrymple, J.
#'   Rozier, T.C.D. Lucas, R.E. Howes, L.S. Tusting, S.Y. Kang, E. Cameron, D.
#'   Bisanzio, K.E. Battle, S. Bhatt, and P.W. Gething. A global map of travel
#'   time to cities to assess inequalities in accessibility in 2015. (2018).
#'   Nature. \doi{10.1038/nature25181}
#'
#'   van Etten, J. (2017). R package gdistance: Distances and routes on
#'   geographical grids. Journal of Statistical Software
#'   \doi{10.18637/jss.v076.i13}
#'
#'
#'
#' @return A `SpatRaster` of travel time (in the time units of
#'   `friction_surface`, e.g. minutes) from each cell to the nearest of
#'   `points`, with a single layer named `"travel_time"`. Cells that cannot
#'   be reached from any of `points` (e.g. because they are separated from
#'   them by `NA` cells in `friction_surface`) are `NA`.
#' @export
#'
#' @examples
#' # a small synthetic friction surface (minutes per metre), so this example
#' # runs without an internet connection
#' friction_surface <- terra::rast(
#'   nrows = 50,
#'   ncols = 50,
#'   xmin = 111,
#'   xmax = 112,
#'   ymin = 0,
#'   ymax = 1,
#'   crs = "EPSG:4326",
#'   vals = 0.01
#' )
#'
#' from_here <- data.frame(
#'   x = c(111.2, 111.9),
#'   y = c(0.2, 0.35)
#' )
#'
#' calculate_travel_time(
#'   friction_surface = friction_surface,
#'   points = from_here
#' )
#'
#' \donttest{
#' # a real motorised friction surface, downloaded from the Malaria Atlas
#' # Project (requires an internet connection)
#' motor_surface <- get_friction_surface(
#'   surface = "motor2020",
#'   extent = c(111, 112, 0, 1)
#' )
#'
#' if (!is.null(motor_surface)) {
#'   calculate_travel_time(
#'     friction_surface = motor_surface,
#'     points = from_here
#'   )
#' }
#' }
#'
calculate_travel_time <- function(
    friction_surface,
    points,
    filename = NULL,
    overwrite = FALSE
){

  existing <- warn_and_return(
    filename = filename,
    overwrite = overwrite
  )

  if (!is.null(existing)) {
    return(existing)
  }

  if (!inherits(friction_surface, "SpatRaster")){
    cli::cli_abort(
      "{.arg friction_surface} must be a {.cls SpatRaster}."
    )
  }

  point_format_ok <- any(c("matrix", "data.frame", "SpatVector") %in% class(points))

  if(!point_format_ok){
    stop("points must be a SpatVector, data.frame, or matrix")
  }

  if(inherits(points, "SpatVector")){
    points <- terra::geom(points)[, c("x", "y"), drop = FALSE]
  }

  xy.matrix <- as.matrix(points[, 1:2, drop = FALSE])

  # Identify the cells the origin points fall in. terra::costDist computes the
  # cost-distance to the border of cells that hold the `target` value, so the
  # origins are flagged by burning a sentinel value into their cells. The
  # sentinel only identifies the target cells; costDist does not charge the
  # origin cells' own friction, so the value chosen does not affect the result
  # as long as it does not collide with genuine friction values elsewhere.
  origin_cells <- terra::cellFromXY(friction_surface, xy.matrix)

  n_points <- nrow(xy.matrix)
  n_outside <- sum(is.na(origin_cells))

  origin_cells <- unique(origin_cells[!is.na(origin_cells)])

  if (length(origin_cells) == 0) {
    cli::cli_abort(
      "None of {.arg points} fall within {.arg friction_surface}."
    )
  }

  # some, but not all, points fell outside the surface: drop them and warn
  if (n_outside > 0) {
    n_inside <- n_points - n_outside
    cli::cli_warn(
      c(
        "!" = "{n_outside} of {n_points} {.arg points} fell outside \\
        {.arg friction_surface} and {cli::qty(n_outside)}{?was/were} \\
        dropped.",
        "i" = "Travel time is calculated from the remaining \\
        {cli::qty(n_inside)}{n_inside} point{?s}."
      )
    )
  }

  target_value <- -1
  friction_target <- friction_surface
  friction_target[origin_cells] <- target_value

  travel_time <- terra::costDist(
    x = friction_target,
    target = target_value
  )

  names(travel_time) <- "travel_time"

  if(!is.null(filename)){

    terra::writeRaster(
      travel_time,
      filename,
      overwrite = overwrite
    )

    return(terra::rast(filename))

  } else {

    travel_time

  }

}
