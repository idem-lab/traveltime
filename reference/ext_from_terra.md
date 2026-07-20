# Extent from `SpatRaster` or `SpatVector`

Formats spatial extent for use in `get_friction_surface`.

## Usage

``` r
ext_from_terra(r)
```

## Arguments

- r:

  [`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
  or
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)

## Value

2x2 `matrix`

## Examples

``` r

library(terra)
#> terra 1.9.34
r <- terra::rast(
    extent = terra::ext(c(111, 112, 0, 1))
  )

ext_from_terra(r)
#>   min max
#> x 111 112
#> y   0   1
```
