calculate_travel_time <- function(
    friction_surface,
    points,
    t_filename = "outputs/areaT.rds",
    tgc_filename = "outputs/areaTGC.rds",
    travel_time_filename = "outputs/travel_time.tif",
    overwrite_raster = FALSE,
    overwrite_t = FALSE
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

  if(!file.exists(t_filename) | (file.exists(t_filename) & overwrite_t)){
    tsn <- transition(friction, function(x) 1/mean(x), 8) # RAM intensive, can be very slow for large areas
    saveRDS(tsn, t_filename)
  } else {
    tsn <- readRDS(t_filename)
  }

  tgc <- geoCorrection(tsn)
  saveRDS(tgc, tgc_filename)

  xy.data.frame <- data.frame()
  xy.data.frame[1:npoints,1] <- points[,1]
  xy.data.frame[1:npoints,2] <- points[,2]
  xy.matrix <- as.matrix(xy.data.frame)

  temp.raster <- accCost(tgc, xy.matrix)

  writeRaster(temp.raster, travel_time_filename, overwrite = overwrite_raster)

  rast(travel_time_filename)

}
