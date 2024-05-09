#' @title Calculate travel time
#' @description
#' Implements Weiss et al method to calculate travel time given a
#'
#'
#' @param friction_surface
#' @param points
#' @param travel_time_filename
#' @param overwrite_raster
#'
#' @return
#' @export
#'
#' @examples
calculate_travel_time <- function(
    friction_surface,
    points,
    travel_time_filename = "outputs/travel_time.tif",
    overwrite_raster = FALSE
){

  if(file.exists(travel_time_filename) & !overwrite_raster){

    warning(sprintf(
      "%s exists\nUsing existing file\nto re-generate, change overwrite_raster to TRUE %s",
      travel_time_filename,
      travel_time_filename
    ))

    return(terra::rast(travel_time_filename))

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
    travel_time_filename,
    overwrite = overwrite_raster
  )

  terra::rast(travel_time_filename)

}
