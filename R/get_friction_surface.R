#' @title Get friction surface
#' @description Wrapper function to download friction surfaces via
#'   `malariaAtlas::getRaster`
#'
#' @param surface `"motor2020"` or `"walk2020`.
#' @param filename `character`. File name for output layer.
#' @param overwrite Overwrite `filename` if exists
#' @param extent Spatial extent as either numeric vector specifying `c(xmin,
#'   xmax, ymin, ymax)`, `SpatExtent`, `SpatVector` or `SpatRaster` (from which
#'   the extent will be taken), or 2x2 `matrix` (see details).
#'
#' @details Convenience wrapper to `malariaAtlas::getRaster` to access motorised
#' and walking travel friction layers per Weiss et al. 2020, that adds safety to
#' check existing files before download. Surfaces can be downloaded directly
#' from:
#' \url{https://malariaatlas.org/project-resources/accessibility-to-healthcare/}
#'
#' `surface = "motor2020"` downloads
#' `"Explorer__2020_motorized_friction_surface"`.
#'
#' `surface = "walk2020"` downloads
#' `"Explorer__2020_walking_only_friction_surface"`.
#'
#' D. J. Weiss, A. Nelson, C. A. Vargas-Ruiz, K. Gligoric, S., Bavadekar, E.
#' Gabrilovich, A. Bertozzi-Villa, J. Rozier, H. S. Gibson, T., Shekel, C.
#' Kamath, A. Lieber, K. Schulman, Y. Shao, V. Qarkaxhija, A. K. Nandi, S. H.
#' Keddie, S. Rumisha, P. Amratia, R. Arambepola, E. G. Chestnutt, J. J. Millar,
#' T. L. Symons, E. Cameron, K. E. Battle, S. Bhatt, and P. W. Gething. Global
#' maps of travel time to healthcare facilities. (2020) Nature Medicine.
#' \url{https://doi.org/10.1038/s41591-020-1059-1}
#'
#' `extent` is passed through is to pass to `malariaAtlas::getRaster` as a 2x2
#' matrix. If passed in as a numeric vector, `SpatExtent`, `SpatVector`, or
#' `SpatRaster`, it is converted into a matrix using `ext_vect_to_matrix` and
#' `ext_from_terra`. `matrix` format is  as returned by sf::st_bbox() - the
#' first column has the minimum, the second the maximum values; rows 1 & 2
#' represent the x & y dimensions respectively (`matrix(c("xmin", "ymin","xmax",
#' "ymax"), nrow = 2, ncol = 2, dimnames = list(c("x", "y"), c("min", "max")))`)
#' (use either shp OR extent; if neither is specified global raster is
#' returned). `NULL` extent downloads (large) global layer.
#'
#'
#' @return `SpatRaster`
#' @export
#'
#' @examples
#'
#' ext <- matrix(
#'   data = c(111, 0, 112, 1),
#'   nrow = 2,
#'   ncol = 2,
#'   dimnames = list(
#'     c("x", "y"),
#'     c("min", "max")
#'    )
#'  )
#'
#'  get_friction_surface(
#'    surface = "motor2020",
#'    extent = ext
#'  )
#'
#' @details Additional details...
#'
get_friction_surface <- function(
  surface = c("motor2020", "walk2020"),
  filename = NULL,
  overwrite = FALSE,
  extent = NULL
){
  surface <- match.arg(surface)

  if(!is.null(filename)){
    if(!overwrite & file.exists(filename)){

      warning(sprintf(
        "%s exists\n Returning %s. To replace, change overwrite to TRUE",
        filename,
        filename
      ))

      return(terra::rast(filename))
    }
  }

  if (surface == "motor2020") {
    surface_name <- "Explorer__2020_motorized_friction_surface"
  } else if (surface == "walk2020"){
    surface_name <- "Explorer__2020_walking_only_friction_surface"
  }

  if (is.null(extent)) {
    stop("extent missing")
  } else if (is.vector(extent)) {
    if(length(extent) == 4){
      extent <- ext_vect_to_matrix(extent)
    } else {
      stop("extent as numeric must be length 4")
    }
  } else if(any(class(extent) == "SpatExtent")) {
    extent <- ext_vect_to_matrix(extent)
  } else if(any(class(extent) == "SpatRaster")){
    extent <- ext_from_terra(extent)
  }else if(any(class(extent) == "SpatVector")){
    extent <- ext_from_terra(extent)
  } else if(is.matrix(extent)){
    if(!all(dim(extent) == c(2,2))){
      stop("Matrix must be 2x2")
    } else {
      extent <- extent
    }
  } else {
    stop("extent must be numeric, matrix, SpatExtent or SpatRaster")
  }


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

  } else{
    fs
  }

}
