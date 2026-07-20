# Visual validation that terra::costDist() reproduces the raster + gdistance
# cost-distance calculation used by earlier versions of calculate_travel_time().
#
# The claim: raw_difference(costDist, gdistance) = geodesic_effect + half_cell
# offset, with nothing else left over. This script demonstrates that visually.
#
#   Figure 1 (projected CRS): the geodesic effect is exactly zero by
#   construction, so the ONLY possible difference is the origin-cell
#   convention. Once that is removed the two maps are identical to machine
#   precision at every cell -> proves there is no third, unexplained difference.
#
#   Figure 2 (lon/lat, high latitude): the only residual after removing the
#   origin-cell offset is a smooth geodesic field (< 0.1 %), the true-geodesic
#   vs approximate-distance difference. terra is the more accurate here.
#
# Not part of the test suite (depends on gdistance + raster, which the package
# no longer imports). Run interactively.

suppressMessages({
  library(terra)
  library(gdistance)
  library(raster)
})

pkg <- "/Users/gryan/Documents/tki_work/vector_atlas/traveltime"
source(file.path(pkg, "R", "calculate_travel_time.R"))
source(file.path(pkg, "R", "utils.R"))
figdir <- Sys.getenv("TT_FIGDIR", unset = file.path(pkg, "data-raw", "figures"))
dir.create(figdir, showWarnings = FALSE, recursive = TRUE)

# ---- old implementation (raster + gdistance) --------------------------------
tt_gdistance <- function(fs, points) {
  fr  <- raster::raster(fs)
  tgc <- gdistance::geoCorrection(
    gdistance::transition(fr, function(x) 1 / mean(x), 8)
  )
  tt <- gdistance::accCost(tgc, as.matrix(points[, 1:2]))
  names(tt) <- "travel_time"
  out <- terra::rast(tt)
  terra::crs(out) <- terra::crs(fs)   # align CRS string (proj4 vs WKT) for arithmetic
  out
}

# ---- structured, realistic-looking friction surface -------------------------
# smooth random field + two low-friction "roads" + a high-friction barrier with
# a gap, so the travel-time maps show genuine least-cost structure.
make_friction <- function(nr, nc, xmin, xmax, ymin, ymax, crs, seed = 1,
                          lo = 0.008, hi = 0.03) {
  r <- rast(nrows = nr, ncols = nc, xmin = xmin, xmax = xmax,
            ymin = ymin, ymax = ymax, crs = crs)
  set.seed(seed)
  values(r) <- rnorm(ncell(r))
  r <- focal(r, w = 9, fun = mean, na.rm = TRUE)
  r <- focal(r, w = 9, fun = mean, na.rm = TRUE)
  mn <- global(r, "min", na.rm = TRUE)[1, 1]
  mx <- global(r, "max", na.rm = TRUE)[1, 1]
  fr <- lo + (hi - lo) * (r - mn) / (mx - mn)

  co <- xyFromCell(fr, 1:ncell(fr))
  xr <- (co[, 1] - xmin) / (xmax - xmin)
  yr <- (co[, 2] - ymin) / (ymax - ymin)
  road1   <- abs(yr - (0.32 + 0.16 * sin(3 * pi * xr))) < 0.018
  road2   <- abs(xr - 0.62) < 0.018 & yr > 0.18
  barrier <- abs(xr - 0.40) < 0.028 & yr < 0.68   # wall with a gap near the top
  v <- values(fr)[, 1]
  v[road1 | road2] <- lo * 0.5
  v[barrier]       <- hi * 3
  values(fr) <- v
  names(fr) <- "friction"
  fr
}

# diverging plot helper centred on zero
plot_diff <- function(r, main, unit = "min") {
  rng <- max(abs(minmax(r)), na.rm = TRUE)
  if (rng == 0) rng <- 1e-12
  plot(r, main = main, col = hcl.colors(101, "Blue-Red 3"),
       range = c(-rng, rng),
       plg = list(title = unit, title.cex = 0.8), mar = c(2, 2, 2.5, 4))
}

add_origins <- function(pts) points(pts[, 1], pts[, 2], pch = 21, bg = "yellow",
                                     col = "black", cex = 1.4, lwd = 1.5)

# =============================================================================
# FIGURE 1 — projected CRS: no geodesic effect, so the only difference is the
# origin half-cell. After removing it the maps are identical to machine precision.
# =============================================================================
utm <- "+proj=utm +zone=32 +datum=WGS84"
frP <- make_friction(180, 180, 0, 18000, 0, 18000, utm, seed = 3)
ptsP <- data.frame(x = c(3200, 13800), y = c(4200, 12800))

new  <- calculate_travel_time(frP, ptsP)                 # terra::costDist
old  <- tt_gdistance(frP, ptsP)                          # gdistance
cn   <- cellFromXY(frP, as.matrix(ptsP[, 1:2]))          # origin cells
fs0  <- frP; fs0[cn] <- 1e-9                             # neutralise origin friction
old0 <- tt_gdistance(fs0, ptsP)                          # gdistance, no half-cell

x  <- values(new)[, 1]; y <- values(old)[, 1]; y0 <- values(old0)[, 1]
ok <- is.finite(x) & is.finite(y) & is.finite(y0)

d_raw   <- new - old        # raw difference
d_resid <- new - old0       # residual after removing origin half-cell
res_ns  <- d_resid * 1e9    # in 1e-9 min, for a legible colourbar

common <- range(c(x[ok], y[ok]))
offset <- median((y - x)[ok], na.rm = TRUE)  # gdistance - costDist ~ half-cell offset

png(file.path(figdir, "fig1_projected_proof.png"),
    width = 1650, height = 1100, res = 135)
par(mfrow = c(2, 3), oma = c(0, 0, 2.2, 0))

plot(frP, main = "(a) Friction surface (min/m)", mar = c(2, 2, 2.5, 4))
add_origins(ptsP)

plot(new, main = "(b) Travel time — terra::costDist (min)", range = common,
     mar = c(2, 2, 2.5, 4)); add_origins(ptsP)
plot(old, main = "(c) Travel time — gdistance (min)", range = common,
     mar = c(2, 2, 2.5, 4)); add_origins(ptsP)

plot_diff(d_raw, "(d) Raw difference: costDist - gdistance")
add_origins(ptsP)
plot_diff(res_ns,
          sprintf("(e) After removing origin half-cell\n max|resid| = %.1e min",
                  max(abs(values(d_resid)), na.rm = TRUE)),
          unit = expression(10^-9 ~ min))
add_origins(ptsP)

# scatter
plot(y[ok], x[ok], pch = 16, cex = 0.25, col = rgb(0.1, 0.2, 0.6, 0.25),
     xlab = "gdistance travel time (min)", ylab = "costDist travel time (min)",
     main = "(f) Cell-by-cell agreement")
abline(0, 1, col = "grey60", lty = 2)
abline(-offset, 1, col = "red", lwd = 1.5)
legend("topleft", bty = "n", cex = 0.85,
       legend = c("y = x", sprintf("y = x - %.2f min (half-cell)", offset)),
       col = c("grey60", "red"), lty = c(2, 1), lwd = c(1, 1.5))

mtext("Projected CRS (geodesic effect = 0): the only difference is the origin half-cell; remove it and the maps are identical",
      outer = TRUE, cex = 0.95, font = 2)
dev.off()

cat(sprintf(
  "FIG1 projected: raw max|diff|=%.3f mean|diff|=%.3f | residual max|diff|=%.3e min\n",
  max(abs(values(d_raw)), na.rm = TRUE), mean(abs(values(d_raw)), na.rm = TRUE),
  max(abs(values(d_resid)), na.rm = TRUE)))

# =============================================================================
# FIGURE 2 — lon/lat at high latitude: after removing the origin half-cell the
# only residual is the smooth geodesic field (true vs approximate distance).
# =============================================================================
frG  <- make_friction(150, 150, 10, 11, 55, 56, "EPSG:4326", seed = 7,
                      lo = 0.015, hi = 0.04)
ptsG <- data.frame(x = c(10.25, 10.78), y = c(55.22, 55.75))

newG  <- calculate_travel_time(frG, ptsG)
oldG  <- tt_gdistance(frG, ptsG)
cnG   <- cellFromXY(frG, as.matrix(ptsG[, 1:2]))
fs0G  <- frG; fs0G[cnG] <- 1e-9
old0G <- tt_gdistance(fs0G, ptsG)

xg <- values(newG)[, 1]; yg <- values(oldG)[, 1]; y0g <- values(old0G)[, 1]
okg <- is.finite(xg) & is.finite(yg) & is.finite(y0g)

d_raw_G   <- newG - oldG
d_resid_G <- newG - old0G                 # geodesic effect only
rg        <- values(d_resid_G)[, 1]

# Relative geodesic effect, on well-resolved cells only. Right at the origins
# travel time -> 0, so a per-cell ratio there is a meaningless 0/0; restrict to
# cells whose travel time is an appreciable fraction of the maximum.
tt_thr <- 0.05 * max(yg[okg])
sel    <- okg & yg > tt_thr
relf   <- 100 * abs(rg[sel]) / yg[sel]
med_rel <- median(relf); p95_rel <- quantile(relf, 0.95)

png(file.path(figdir, "fig2_geodesic_field.png"),
    width = 1650, height = 560, res = 135)
par(mfrow = c(1, 3), oma = c(0, 0, 2.2, 0))

plot_diff(d_raw_G, "(a) Raw difference: costDist - gdistance")
add_origins(ptsG)
plot_diff(d_resid_G, "(b) Residual after origin half-cell\n= geodesic effect only")
add_origins(ptsG)

# relative size of the geodesic effect on well-resolved cells
hist(relf, breaks = 40, col = "grey80", border = "grey40",
     xlab = "|geodesic residual| as % of travel time",
     main = sprintf("(c) Geodesic effect < %.1f%% of travel time\n(cells > %.0f min)",
                    ceiling(p95_rel * 10) / 10, tt_thr))
abline(v = c(med_rel, p95_rel), col = c("blue", "red"), lwd = 2, lty = c(1, 2))
legend("topright", bty = "n", cex = 0.85,
       legend = c(sprintf("median %.2f%%", med_rel),
                  sprintf("p95 %.2f%%", p95_rel)),
       col = c("blue", "red"), lwd = 2, lty = c(1, 2))

mtext(sprintf("Lon/lat at 55N: the only residual is a smooth geodesic field (max %.1f min, ~%.1f%% of travel time) - terra uses the true geodesic distance and is the more accurate",
              max(abs(rg), na.rm = TRUE), med_rel),
      outer = TRUE, cex = 0.9, font = 2)
dev.off()

cat(sprintf(
  "FIG2 55N: raw max|diff|=%.3f | geodesic residual max|diff|=%.3f min | rel median=%.3f%% p95=%.3f%%\n",
  max(abs(values(d_raw_G)), na.rm = TRUE),
  max(abs(rg), na.rm = TRUE), med_rel, p95_rel))

cat("\nSaved:\n  ", file.path(figdir, "fig1_projected_proof.png"),
    "\n  ", file.path(figdir, "fig2_geodesic_field.png"), "\n")
