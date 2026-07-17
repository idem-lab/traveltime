# Migrating `calculate_travel_time()` from gdistance to `terra::costDist()`

**Date:** 2026-07-17

## Purpose

`calculate_travel_time()` originally converted the `terra` `SpatRaster` friction surface to a `raster` `RasterLayer` so that it could use the `gdistance` pipeline:

``` r
friction <- raster::raster(friction_surface)
tsn <- gdistance::transition(friction, function(x) 1/mean(x), 8)  # conductance
tgc <- gdistance::geoCorrection(tsn)                              # / geo distance
travel_time <- gdistance::accCost(tgc, xy.matrix)                 # accumulate
```

This forced dependencies on both `raster` (superseded by `terra`) and `gdistance`. This document records testing showing that `terra::costDist()` reproduces the same calculation, and characterises the (small) differences.

## The two approaches are the same cost model

`gdistance` builds a graph where the cost of moving between two neighbouring cells is `distance * mean(friction_i, friction_j)`:

- `transition(1/mean(x))` makes the edge **conductance** `1 / mean(friction)`.
- `geoCorrection()` divides conductance by the distance between cell centres.
- `accCost()` accumulates least-cost paths, where each edge weight is the reciprocal of the corrected conductance, i.e. `distance * mean(friction)`.

`terra::costDist()` uses exactly this model: cells are connected in 8 directions and *"distances are multiplied with the friction"*, using the mean of neighbouring friction values, with the least-cost path passing through cell centres. Crucially, for longitude/latitude data `costDist()` computes **geodesic** inter-cell distances internally — so the geographic correction that `gdistance::geoCorrection()` provided is done by `terra` and no longer needs a separate step.

Origins are supplied to `costDist()` by flagging the cells the points fall in (`terra::cellFromXY`) with a sentinel `target` value.

## What differs

There are two between the methods. Both were isolated by re-running the `gdistance` pipeline with the origin cells' friction set to \~0; once that is done the two methods agree to **machine precision** (except a sub-0.1% geodesic effect at high latitude, below).

1.  **Origin-cell convention.** `gdistance` performs the full line integral of friction from the origin *cell centre*, so leaving the origin costs `distance * mean(friction_origin, friction_neighbour)` — i.e. it includes half of the origin cell's own friction. `costDist()` measures cost to the *border* of the target cells, so it omits that within-origin half-cell. The result is a near-constant offset of about **half a cell of friction** (a few minutes for walking friction), concentrated around the origins.

2.  **Distance accuracy at high latitude.** `gdistance::geoCorrection()` uses an approximation of inter-cell distance; `terra` uses true geodesic distances. These agree exactly at the equator and for projected CRSs, and diverge by \<0.1% as meridians converge toward the poles. Here `terra` is the more accurate of the two.

## Synthetic tests

Script: `data-raw/compare_costdist_vs_gdistance.R`. Random friction surfaces, `calculate_travel_time()` (new) vs the `gdistance` pipeline (old), plus the old pipeline with origin friction neutralised.

| Scenario | cells | median tt | raw max\|diff\| | raw mean\|diff\| | origin-neutralised max\|diff\| |
|------------|------------|------------|------------|------------|------------|
| lon/lat, equator (data.frame points) | 14,400 | 376 min | 10.33 | 7.52 | 5.0e-4 |
| lon/lat, equator (SpatVector points) | 14,400 | 376 min | 10.33 | 7.52 | 5.0e-4 |
| lon/lat, 55°N | 14,400 | 409 min | 9.76 | 7.02 | 2.30 (0.08% of value) |
| projected UTM (planar) | 90,000 | 79 min | 0.98 | 0.80 | 7e-8 |

- Origin-neutralised residual is machine precision at the equator and in the projected CRS ⇒ the cost model and geographic correction are reproduced exactly.
- At 55°N a small residual (max 2.3 min, \~0.08%) remains, from geodesic vs approximate distance — `terra` is more accurate here.
- SpatVector and data.frame inputs give identical results.

## Singapore vignette (real data)

Script: `data-raw/singapore_compare.R`. The exact inputs from `vignettes/singapore.Rmd`: 563 MRT/LRT station exits (`stations`), the `walk2020` friction surface downloaded via `get_friction_surface()`, masked to the Singapore boundary from `geodata::gadm()`. Summary saved to `data-raw/singapore_costdist_comparison.rds`.

| Metric | Value |
|------------------------------------|------------------------------------|
| Finite cells compared | 958 |
| Travel time (gdistance): min / median / max | 0.00 / 22.11 / 173.33 min |
| costDist vs gdistance, raw: max\|diff\| / mean\|diff\| | 7.84 / 5.73 min |
| costDist vs gdistance, raw: median / p95 **relative** diff | 25.0% / 50.0% |
| costDist vs gdistance, origin neutralised: max\|diff\| | 0.0006 min |

Note on the relative figure: Singapore has a **dense** station network and therefore **short** travel times (median 22 min). The \~5.7 min origin-cell offset is small in absolute terms but a large fraction of these short times. Away from origins, and wherever travel times are longer, the relative difference shrinks toward zero. The geographic correction itself is reproduced to machine precision (0.0006 min).

## Conclusion

`terra::costDist()` reproduces the `raster` + `gdistance` cost-distance calculation, and performs the geographic correction internally and more accurately. The only systematic difference is a half-origin-cell convention that appears as a small, near-constant offset near the origin points. On this basis `raster` and `gdistance` were dropped from the package's dependencies and `calculate_travel_time()` was reimplemented on `terra::costDist()`.
