get_friction_surface <- function(
  surface = c("motor2020", "walk2020"),
  file_name = "friction_surface.tif",
  overwrite = FALSE
){
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
}
