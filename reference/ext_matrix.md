# Convert extent to matrix

This function allows
[`get_friction_surface()`](https://idem-lab.github.io/traveltime/reference/get_friction_surface.md)
to accept the argument `extent` as a `vector`, 2x2 `matrix`,
`SpatVector`, or `SpatRaster` and extracts and converts into the
annoyingly specific format necessary to download the friction surface.
See details in
[`?get_friction_surface`](https://idem-lab.github.io/traveltime/reference/get_friction_surface.md)

## Usage

``` r
ext_matrix(extent)
```

## Arguments

- extent:

  `vector` of length 4, 2x2 `matrix`, `SpatExtent`, `SpatVector`, or
  `SpatRaster`

## Value

2x2 `matrix` with column names "x" and "y" and row names "min" and "max"

## Examples

``` r
# vector/double
x <- c(111, 112, 0, 1)
ext_matrix(x)
#>   min max
#> x 111 112
#> y   0   1

# SpatExtent
y <-  terra::ext(x)
ext_matrix(y)
#>   min max
#> x 111 112
#> y   0   1

# SpatRaster
r <- terra::rast(extent = y)
ext_matrix(r)
#>   min max
#> x 111 112
#> y   0   1

# SpatVector
v <- terra::vect(y)
ext_matrix(v)
#>   min max
#> x 111 112
#> y   0   1
```
