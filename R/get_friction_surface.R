#' @title Get friction surface
#' @description Wrapper function to download friction surfaces via
#'   [malariaAtlas::getRaster()].
#'
#' @param surface `"motor2020"` or `"walk2020`.
#' @param filename `character`. File name for output layer.
#' @param overwrite Overwrite `filename` if exists
#' @param extent Spatial extent as one of:
#'  - a numeric vector specifying `c(xmin,
#'   xmax, ymin, ymax)`,
#'   - a `terra` `SpatExtent`, `SpatVector`, or `SpatRaster` from which
#'   the extent will be taken, or
#'   -  or 2x2 `matrix`
#'
#'   See details
#'
#' @details Convenience wrapper to [malariaAtlas::getRaster()] to access
#'   motorised and walking travel friction layers per Weiss et al. 2020, that
#'   adds safety to check existing files before download. Surfaces can be
#'   downloaded directly from:
#'   \url{https://malariaatlas.org/project-resources/accessibility-to-healthcare/}.
#'
#'   Here when
#'
#'  - `surface = "motor2020"` will download
#'   `"Explorer__2020_motorized_friction_surface"`, and
#'  - `surface = "walk2020"` will download
#'   `"Explorer__2020_walking_only_friction_surface"`.
#'
#'   D. J. Weiss, A. Nelson, C. A. Vargas-Ruiz, K. Gligoric, S., Bavadekar, E.
#'   Gabrilovich, A. Bertozzi-Villa, J. Rozier, H. S. Gibson, T., Shekel, C.
#'   Kamath, A. Lieber, K. Schulman, Y. Shao, V. Qarkaxhija, A. K. Nandi, S. H.
#'   Keddie, S. Rumisha, P. Amratia, R. Arambepola, E. G. Chestnutt, J. J.
#'   Millar, T. L. Symons, E. Cameron, K. E. Battle, S. Bhatt, and P. W.
#'   Gething. Global maps of travel time to healthcare facilities. (2020) Nature
#'   Medicine. \url{https://doi.org/10.1038/s41591-020-1059-1}
#'
#'   `extent` is formatted and then passed through to
#'   [malariaAtlas::getRaster()] as a 2x2 matrix. It is converted into a matrix
#'   using `ext_matrix`. The `matrix` format used is as returned by
#'   `sf::st_bbox()` --- the first column has the minimum, the second the
#'   maximum values; rows 1 & 2 represent the x & y dimensions respectively:
#'   `matrix(c("xmin", "ymin", "xmax", "ymax"), nrow = 2, ncol = 2, dimnames =
#'   list(c("x", "y"), c("min", "max")))`. `NULL` extent downloads (large)
#'   global layer.
#'
#' @return `SpatRaster`
#' @export
#'
#' @examples
#'
#' # for more examples of passing exten types see ?ext_matrix
#'
#' ext <- c(111, 0, 112, 1)
#'
#'  get_friction_surface(
#'    surface = "motor2020",
#'    extent = ext
#'  )
#'
get_friction_surface <- function(
  surface = c("motor2020", "walk2020"),
  filename = NULL,
  overwrite = FALSE,
  extent = NULL
){
  surface <- match.arg(surface)

  warn_and_return(
    filename = filename,
    overwrite = overwrite
  )

  surface_name <- switch(
    surface,
    "motor2020" = "Accessibility__202001_Global_Motorized_Friction_Surface",
    "walk2020" = "Accessibility__202001_Global_Walking_Only_Friction_Surface"
  )

  if (is.null(extent)) {
    cli::cli_abort("{.arg extent} must be specified.")
  }

  extent <- ext_matrix(extent)

  fs <- malariaAtlas::getRaster(
    dataset_id = surface_name,
    extent = extent
  )

  names(fs) <- "friction_surface"

  if(!is.null(filename)){
    terra::writeRaster(
      x = fs,
      filename = filename,
      overwrite = overwrite
    )

    fs <- terra::rast(filename)

  } else {
    fs
  }

}
