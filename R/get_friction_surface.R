#' @title Get friction surface
#' @details Wrapper function to download friction surfaces via `malariaAtlas::getRaster``
#'
#' @param surface
#' @param file_name
#' @param overwrite
#' @param extent
#'
#' @return
#' @export
#'
#' @examples
get_friction_surface <- function(
  surface = c("motor2020", "walk2020"),
  file_name = "friction_surface.tif",
  overwrite = FALSE,
  extent = NULL
){

  #matrix(c("0", "0", "1", "1"), nrow = 2, ncol = 2, dimnames = list(c("x", "y"), c("min", "max")))
  # function goes and downloads a friction surface
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

  malariaAtlas::getRaster(
    dataset_id = surface_name,
    extent = extent
  ) |>
    terra::rast() |>
    sdmtools::writereadrast(filename = file_name)

}
