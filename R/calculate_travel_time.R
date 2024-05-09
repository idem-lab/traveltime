#' @title Calculate travel time
#' @description
#' Implements Weiss et al method to calculate travel time given a
#'
#'
#' @param friction_surface
#' @param points
#' @param file_name
#' @param overwrite_raster
#'
#' @return
#' @export
#'
#' @examples
calculate_travel_time <- function(
    friction_surface,
    points,
    file_name = "outputs/travel_time.tif",
    overwrite_raster = FALSE
){

  if(file.exists(file_name) & !overwrite_raster){

    warning(sprintf(
      "%s exists\nUsing existing file\nto re-generate, change overwrite_raster to TRUE %s",
      file_name,
      file_name
    ))

    return(terra::rast(file_name))

  }

  npoints <- nrow(points)

  friction <- raster::raster(friction_surface)

  tsn <- gdistance::transition(friction, function(x) 1/mean(x), 8) # RAM intensive, can be very slow for large areas
  tgc <- gdistance::geoCorrection(tsn)

  xy.data.frame <- data.frame()
  xy.data.frame[1:npoints,1] <- points[,1]
  xy.data.frame[1:npoints,2] <- points[,2]
  xy.matrix <- as.matrix(xy.data.frame)

  travel_time <- gdistance::accCost(tgc, xy.matrix)

  raster::writeRaster(
    travel_time,
    file_name,
    overwrite = overwrite_raster
  )

  terra::rast(file_name)

}
