# traveltime 1.0.0

* First CRAN release.
* `calculate_travel_time()` now uses `terra::costDist()` internally, removing
  the dependencies on the superseded `raster` and `gdistance` packages. Results
  are effectively the same; see the
  [validation article](https://idem-lab.github.io/traveltime/articles/costdist-validation.html)
  for details of the small differences.
* `calculate_travel_time()` now drops (with a warning) any `points` that fall
  outside `friction_surface`, and errors if none fall within it.
* `calculate_travel_time()` and `get_friction_surface()` now correctly return
  the existing file when `filename` already exists and `overwrite = FALSE`,
  as documented. Previously they warned and then errored.
* `get_friction_surface()` now fails gracefully, returning `NULL` with a
  warning, if the friction surface cannot be downloaded.
* Removed unused dependency on `lifecycle`.
