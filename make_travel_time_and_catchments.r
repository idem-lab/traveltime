# make_travel_time_and_catchments.r
#
# Dan Weiss
# Malaria Atlas Project 
# 2022-01-18
#
# This script produces raster (.tif) outputs for (a) travel time (in minutes) and (b) a catchment raster with the ID (integer) 
# of the point with the lowest travel time.
# 
# The logic here is to make a unique travel time map for each point and then aggregate them to make an overall travel time map 
# (i.e., what would be made if all the points were run simultaneously). The rational for processing the points iteratively is to
# retain the information for which facility is "closest" to each pixel, which is saved in a catchment raster in which each pixel 
# value will be the interger ID of the most accessibilty point.
# 
# Warning, this task can be very slow and may only run for small areas due to computational limitations of user's machines or, 
# if they have a good machine with lots of RAM, they will eventually hit R's object-size restriction.

t.start <- Sys.time() # for benchmarking

## Required Packages
require(gdistance) # this will also load the raster package
#library(tictoc) # for benchmarking

## Define the spatial extent of analysis 
x.min <- -18.0 # Longitude of the left edge
x.max <- -11.0 # Longitude of the right edge
y.min <- 12.0  # Latitude of the bottom edge
y.max <- 17.0  # Latitude of the top edge

## Input Variables
friction.surface.filename     <- 'Z:/temp/Accessibility/redux2019/friction_surface_v51.tif'
transition.matrix.exists.flag <- 0 # set to zero if new T and T.GC files are required, otherwise set to 1 to recycle and save time
T.filename                    <- 'Z:/temp/Accessibility/senegal/senegal.T.rds'
T.GC.filename                 <- 'Z:/temp/Accessibility/senegal/senegal.T.GC.rds'
point.filename                <- 'Z:/temp/Accessibility/senegal/senegal_facilities.csv'

## Output Variables
output.path                   <- 'Z:/temp/Accessibility/senegal/output_R/'
travel.time.filename          <- paste(output.path, 'travel_time.tif', sep='')
catchments.filename           <- paste(output.path, 'catchments.tif', sep='')

## Read, crop, and transform the friction surface into the geocorrected transition matrix
friction <- raster(friction.surface.filename)
fs1      <- crop(friction, extent(x.min, x.max, y.min, y.max))

if (transition.matrix.exists.flag == 1) {
  ## Read in the transition matrix object if it has been pre-computed
  T.GC <- readRDS(T.GC.filename)
} else {
  ## Make and geocorrect the transition matrix (i.e., the graph)
  T    <- transition(fs1, function(x) 1/mean(x), 8) # RAM intensive, can be very slow for large areas
  saveRDS(T, T.filename)
  T.GC <- geoCorrection(T)                    
  saveRDS(T.GC, T.GC.filename)
}

## Read in the points of interest - here is where users must adjust the column names according to each point file
point.table  <- read.csv(file = point.filename)
point.id.vec <- point.table$ID   # change column name to match your data
point.x.vec  <- point.table$Long # change column name to match your data
point.y.vec  <- point.table$Lat  # change column name to match your data
n.points     <- length(point.id.vec)

## Iterate through the all facilities to calculate the overall accessibility surface and the per-facility surfaces
for (a in 1:n.points){
  # a <- 1 # for testing - I recommend running a point with benchmarking to determine the per-point runtime and use that to calculate overall runtime
  
  temp.point.id     <- point.id.vec[a]
  temp.point.coords <- c(point.x.vec[a],point.y.vec[a])
  
  # Make a single-point travel time surface
  #tic() # for benchmarking
  temp.raster <- accCost(T.GC, temp.point.coords)
  #toc() # for benchmarking
  
  if (a == 1){
    travel.time.raster <- temp.raster
    catchment.raster   <- temp.raster * 0 + temp.point.id
  } else {
    swap.pixels                     <- Which(temp.raster < travel.time.raster) # create a binary raster (true and false), this is the raster library Which(), note the capital 'W'  
    travel.time.raster[swap.pixels] <- temp.raster[swap.pixels]
    catchment.raster[swap.pixels]   <- temp.point.id
  }
}

## Write out the cost path raster showing travel time to the closest (by time) point for all pixels
writeRaster(travel.time.raster, travel.time.filename)
writeRaster(catchment.raster, catchments.filename)

# For benchmarking
t.end <- Sys.time()
t.run <- t.end - t.start
print(t.run)
