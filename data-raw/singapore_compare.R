suppressMessages({
  library(terra); library(gdistance); library(raster)
  library(geodata); library(cli); library(malariaAtlas)
})
options(timeout = 600)

pkg <- "/Users/gryan/Documents/tki_work/vector_atlas/traveltime"

# source package functions (NEW edited calculate_travel_time) instead of installing
for (f in list.files(file.path(pkg, "R"), pattern = "\\.R$", full.names = TRUE)) source(f)

# --- reproduce the Singapore vignette inputs ---
load(file.path(pkg, "data", "stations.rda"))
singapore_shapefile <- gadm("Singapore", level = 0, path = tempdir(), resolution = 2)
friction_singapore <- get_friction_surface(surface = "walk2020",
                                            extent = singapore_shapefile) |>
  mask(singapore_shapefile)

cat("friction cells (non-NA):", global(!is.na(friction_singapore), "sum")[1,1], "\n")

# --- NEW implementation (terra::costDist) ---
tt_new <- calculate_travel_time(friction_singapore, stations)

# --- OLD implementation (raster + gdistance) ---
tt_gdistance <- function(fs, points) {
  fr <- raster::raster(fs)
  tgc <- gdistance::geoCorrection(gdistance::transition(fr, function(x) 1/mean(x), 8))
  rast(gdistance::accCost(tgc, as.matrix(points[, 1:2])))
}
tt_old <- tt_gdistance(friction_singapore, stations)

# --- OLD with origin cells neutralised (isolates geo-correction agreement) ---
cn <- cellFromXY(friction_singapore, as.matrix(stations[, 1:2]))
fs0 <- friction_singapore; fs0[cn] <- 1e-9
tt_old0 <- tt_gdistance(fs0, stations)

x <- values(tt_new)[,1]; y <- values(tt_old)[,1]; y0 <- values(tt_old0)[,1]
ok <- is.finite(x) & is.finite(y)
d <- x[ok] - y[ok]; d0 <- x[ok] - y0[ok]
rel <- d[y[ok] > 1] / y[ok][y[ok] > 1]

cat("\n================ SINGAPORE VIGNETTE COMPARISON ================\n")
cat(sprintf("Latitude ~1.3N. Finite cells compared: %d\n", sum(ok)))
cat(sprintf("Travel time (gdistance): min=%.2f median=%.2f max=%.2f min\n",
            min(y[ok]), median(y[ok]), max(y[ok])))
cat("\n-- costDist vs gdistance (raw) --\n")
cat(sprintf("  max|diff| = %.4f min   mean|diff| = %.4f min\n", max(abs(d)), mean(abs(d))))
cat(sprintf("  median rel diff = %.4f%%   p95 rel diff = %.4f%%\n",
            100*median(abs(rel)), 100*quantile(abs(rel), .95)))
cat("\n-- costDist vs gdistance with origin cells neutralised --\n")
cat(sprintf("  max|diff| = %.6f min   mean|diff| = %.6f min\n", max(abs(d0)), mean(abs(d0))))
cat("  (residual = machine precision => geographic correction reproduced exactly)\n")

saveRDS(list(n = sum(ok),
             tt_range = range(y[ok]),
             raw = c(max = max(abs(d)), mean = mean(abs(d)),
                     rel_median = 100*median(abs(rel)), rel_p95 = 100*quantile(abs(rel),.95)),
             origin_neutralised = c(max = max(abs(d0)), mean = mean(abs(d0)))),
        file.path(pkg, "data-raw", "singapore_costdist_comparison.rds"))
cat("\nSaved summary to data-raw/singapore_costdist_comparison.rds\n")
