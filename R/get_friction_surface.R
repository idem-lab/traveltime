#' @title Get friction surface
#' @description Wrapper function to download friction surfaces via
#' `malariaAtlas::getRaster`
#'
#' @param surface `"motor2020"` or `"walk2020`
#' @param file_name Character of file name to write raster to disc
#' @param overwrite Overwrite `file_name` if exists
#' @param extent Extent to pass to `malariaAtlas::getRaster`: 2x2 matrix
#'   specifying the spatial extent within which raster data is desired, as
#'   returned by sf::st_bbox() - the first column has the minimum, the second
#'   the maximum values; rows 1 & 2 represent the x & y dimensions respectively
#'   (matrix(c("xmin", "ymin","xmax", "ymax"), nrow = 2, ncol = 2, dimnames =
#'   list(c("x", "y"), c("min", "max")))) (use either shp OR extent; if neither
#'   is specified global raster is returned).
#'
#' @return
#' @export
#'
#' @examples
#'
#' ext <- matrix(
#'   data = c("111", "0", "112", 1),
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
#'    file_name = tempfile(fileext = ".tif"),
#'    extent = ext
#'  )
#'
#' @details Additional details...
#'
get_friction_surface <- function(
  surface = c("motor2020", "walk2020"),
  file_name = "friction_surface.tif",
  overwrite = FALSE,
  extent = NULL
){
  surface <- match.arg(surface)

  if(!overwrite & file.exists(file_name)){

    warning(sprintf(
      "%s exists\n Returning %s. To replace, change overwrite_raster to TRUE",
      file_name,
      file_name
    ))

    return(terra::rast(file_name))
  }

  if(surface == "motor2020"){
    surface_name <- "Explorer__2020_motorized_friction_surface"
  } else if (surface == "walk2020"){
    surface_name <- "Explorer__2020_walking_only_friction_surface"
  }

  fs <- malariaAtlas::getRaster(
    dataset_id = surface_name,
    extent = extent
  )

  names(fs) <- "friction_surface"

  sdmtools::writereadrast(
    x = fs,
    filename = file_name
  )

}
