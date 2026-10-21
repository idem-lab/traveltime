#' @title Get friction surface
#' @description Wrapper function to download friction surfaces via
#'   [malariaAtlas::getRaster()].
#'
#' @param surface `"motor2020"` or `"walk2020"`.
#' @param filename `character`. File name for output layer.
#' @param overwrite `logical`. If `TRUE` `filename` is overwritten. If `FALSE`
#'   (default) and `filename` already exists, the existing file is returned
#'   with a warning and nothing is downloaded.
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
#'   Here ---
#'
#'  - `surface = "motor2020"` will download
#'   `"Accessibility__202001_Global_Motorized_Friction_Surface"`, and
#'  - `surface = "walk2020"` will download
#'   `"Accessibility__202001_Global_Walking_Only_Friction_Surface"`.
#'
#'   D. J. Weiss, A. Nelson, C. A. Vargas-Ruiz, K. Gligoric, S., Bavadekar, E.
#'   Gabrilovich, A. Bertozzi-Villa, J. Rozier, H. S. Gibson, T., Shekel, C.
#'   Kamath, A. Lieber, K. Schulman, Y. Shao, V. Qarkaxhija, A. K. Nandi, S. H.
#'   Keddie, S. Rumisha, P. Amratia, R. Arambepola, E. G. Chestnutt, J. J.
#'   Millar, T. L. Symons, E. Cameron, K. E. Battle, S. Bhatt, and P. W.
#'   Gething. Global maps of travel time to healthcare facilities. (2020) Nature
#'   Medicine. \doi{10.1038/s41591-020-1059-1}
#'
#'   `extent` is formatted and then passed through to
#'   [malariaAtlas::getRaster()] as a 2x2 matrix. It is converted into a matrix
#'   using `ext_matrix`. The `matrix` format used is as returned by
#'   `sf::st_bbox()` --- the first column has the minimum, the second the
#'   maximum values; rows 1 & 2 represent the x & y dimensions respectively:
#'   `matrix(c("xmin", "ymin", "xmax", "ymax"), nrow = 2, ncol = 2, dimnames =
#'   list(c("x", "y"), c("min", "max")))`. `extent` must be supplied.
#'
#'   Troubleshooting: this function requires an internet connection. If the
#'   download fails (e.g. a warning `Failed to connect to MAP geoserver`), a
#'   warning is given and `NULL` is returned. This is an issue with fetching
#'   the friction surface using [malariaAtlas::getRaster()], and not an issue
#'   with `traveltime` itself. The server may be down or there may be an issue
#'   with that package.
#'
#' @return A `SpatRaster` friction surface with a single layer named
#'   `"friction_surface"`, or `NULL` (with a warning) if the download fails.
#' @export
#'
#' @examples
#' \donttest{
#' # requires an internet connection
#' # for more examples of passing extent types see ?ext_matrix
#'
#' ext <- c(111, 112, 0, 1)
#'
#' get_friction_surface(
#'   surface = "motor2020",
#'   extent = ext
#' )
#' }
#'
get_friction_surface <- function(
  surface = c("motor2020", "walk2020"),
  filename = NULL,
  overwrite = FALSE,
  extent = NULL
){
  surface <- match.arg(surface)

  existing <- warn_and_return(
    filename = filename,
    overwrite = overwrite
  )

  if (!is.null(existing)) {
    return(existing)
  }

  surface_name <- switch(
    surface,
    "motor2020" = "Accessibility__202001_Global_Motorized_Friction_Surface",
    "walk2020" = "Accessibility__202001_Global_Walking_Only_Friction_Surface"
  )

  if (is.null(extent)) {
    cli::cli_abort("{.arg extent} must be specified.")
  }

  extent <- ext_matrix(extent)

  # fail gracefully (warning and NULL, not an error) if the Malaria Atlas
  # Project server cannot be reached or the download otherwise fails
  fs <- tryCatch(
    malariaAtlas::getRaster(
      dataset_id = surface_name,
      extent = extent
    ),
    error = function(e) {
      cli::cli_warn(
        message = c(
          "!" = "Could not download the {.val {surface}} friction surface \
          from the Malaria Atlas Project; returning {.code NULL}.",
          "i" = "Check your internet connection, or try again later as the \
          server may be unavailable.",
          "x" = "{conditionMessage(e)}"
        )
      )
      NULL
    }
  )

  if (!inherits(fs, "SpatRaster")) {
    if (!is.null(fs)) {
      cli::cli_warn(
        "Download of the {.val {surface}} friction surface did not return a \
        {.cls SpatRaster}; returning {.code NULL}."
      )
    }
    return(NULL)
  }

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
