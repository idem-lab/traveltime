# Development check: compare the new terra::costDist implementation of
# calculate_travel_time() against the original raster + gdistance pipeline.
#
# This is not part of the package test suite (it depends on raster + gdistance,
# which the package no longer imports). Run interactively to verify equivalence.

suppressMessages({
  library(terra)
  library(gdistance)
  library(raster)
})

# Original implementation (raster + gdistance) kept here for comparison only.
tt_gdistance <- function(friction_surface, points) {
  if (inherits(points, "SpatVector")) {
    points <- terra::geom(points)[, c("x", "y")]
  }
  friction <- raster::raster(friction_surface)
  tsn <- gdistance::transition(friction, function(x) 1 / mean(x), 8)
  tgc <- gdistance::geoCorrection(tsn)
  xy <- as.matrix(points[, 1:2])
  tt <- gdistance::accCost(tgc, xy)
  names(tt) <- "travel_time"
  terra::rast(tt)
}

# Load the new terra-only implementation.
source(file.path("R", "calculate_travel_time.R"))
source(file.path("R", "utils.R"))

compare_one <- function(friction_surface, points, label) {
  new <- calculate_travel_time(friction_surface, points)
  old <- tt_gdistance(friction_surface, points)

  x <- terra::values(new)[, 1]
  y <- terra::values(old)[, 1]
  ok <- is.finite(x) & is.finite(y)
  d <- x[ok] - y[ok]

  # gdistance charges half the origin cell's own friction on the first step;
  # costDist (distance to target-cell border) does not. Neutralising the origin
  # cells in the gdistance run isolates whether the geographic correction and
  # every downstream edge agree.
  pts <- if (inherits(points, "SpatVector")) {
    terra::geom(points)[, c("x", "y")]
  } else {
    as.matrix(points[, 1:2])
  }
  cn <- terra::cellFromXY(friction_surface, as.matrix(pts[, 1:2]))
  fs0 <- friction_surface
  fs0[cn] <- 1e-9
  old0 <- tt_gdistance(fs0, points)
  y0 <- terra::values(old0)[, 1]
  d0 <- x[ok] - y0[ok]

  cat(sprintf("\n=== %s ===\n", label))
  cat(sprintf("  cells compared: %d\n", sum(ok)))
  cat(sprintf("  travel time (gdistance) median=%.2f max=%.2f\n",
              median(y[ok]), max(y[ok])))
  cat(sprintf("  raw diff vs gdistance:            max|d|=%.4g mean|d|=%.4g\n",
              max(abs(d)), mean(abs(d))))
  cat(sprintf("  diff vs gdistance (origin zeroed): max|d|=%.4g mean|d|=%.4g\n",
              max(abs(d0)), mean(abs(d0))))
}

set.seed(2024)

# Case 1: lon/lat near equator (as in the package examples/tests)
fs1 <- rast(xmin = 111, xmax = 112, ymin = 0, ymax = 1,
            resolution = 1 / 120, crs = "EPSG:4326")
values(fs1) <- 0.012 * exp(rnorm(ncell(fs1), 0, 0.4))
pts1 <- data.frame(x = c(111.2, 111.9), y = c(0.2, 0.35))
compare_one(fs1, pts1, "lon/lat equator, data.frame points")

# Case 2: SpatVector points
pts1v <- vect(pts1, geom = c("x", "y"), crs = "EPSG:4326")
compare_one(fs1, pts1v, "lon/lat equator, SpatVector points")

# Case 3: higher latitude (stronger meridian convergence -> stronger geo effect)
fs2 <- rast(xmin = 10, xmax = 11, ymin = 55, ymax = 56,
            resolution = 1 / 120, crs = "EPSG:4326")
values(fs2) <- 0.02 * exp(rnorm(ncell(fs2), 0, 0.5))
pts2 <- data.frame(x = c(10.3, 10.8), y = c(55.2, 55.7))
compare_one(fs2, pts2, "lon/lat 55N, data.frame points")

# Case 4: projected (planar) CRS
fs3 <- rast(xmin = 0, xmax = 30000, ymin = 0, ymax = 30000,
            resolution = 100, crs = "+proj=utm +zone=32 +datum=WGS84")
values(fs3) <- 0.01 * exp(rnorm(ncell(fs3), 0, 0.4))
pts3 <- data.frame(x = c(5000, 24000), y = c(6000, 22000))
compare_one(fs3, pts3, "projected UTM, data.frame points")
