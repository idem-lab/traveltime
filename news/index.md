# Changelog

## traveltime 1.0.0

- First CRAN release.
- [`calculate_travel_time()`](https://idem-lab.github.io/traveltime/reference/calculate_travel_time.md)
  now uses
  [`terra::costDist()`](https://rspatial.github.io/terra/reference/costDist.html)
  internally, removing the dependencies on the superseded `raster` and
  `gdistance` packages. Results are effectively the same; see the
  [validation
  article](https://idem-lab.github.io/traveltime/articles/costdist-validation.html)
  for details of the small differences.
- Cells that cannot be reached from any of `points` (e.g. because they
  are cut off by `NA` cells) are now `NA` in the output of
  [`calculate_travel_time()`](https://idem-lab.github.io/traveltime/reference/calculate_travel_time.md).
  Previously they were `Inf`.
- [`calculate_travel_time()`](https://idem-lab.github.io/traveltime/reference/calculate_travel_time.md)
  now drops (with a warning) any `points` that fall outside
  `friction_surface`, and errors if none fall within it.
- [`calculate_travel_time()`](https://idem-lab.github.io/traveltime/reference/calculate_travel_time.md)
  now works with a single point supplied as a one-row `matrix` or a
  one-point `SpatVector`. Previously these errored.
- [`ext_matrix()`](https://idem-lab.github.io/traveltime/reference/ext_matrix.md),
  and so
  [`get_friction_surface()`](https://idem-lab.github.io/traveltime/reference/get_friction_surface.md),
  now accept integer as well as double vectors for `extent`.
- [`calculate_travel_time()`](https://idem-lab.github.io/traveltime/reference/calculate_travel_time.md)
  and
  [`get_friction_surface()`](https://idem-lab.github.io/traveltime/reference/get_friction_surface.md)
  now correctly return the existing file when `filename` already exists
  and `overwrite = FALSE`, as documented. Previously they warned and
  then errored.
- [`get_friction_surface()`](https://idem-lab.github.io/traveltime/reference/get_friction_surface.md)
  now fails gracefully, returning `NULL` with a warning, if the friction
  surface cannot be downloaded.
- Removed unused dependency on `lifecycle`.
