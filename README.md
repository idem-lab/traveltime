
<!-- README.md is generated from README.Rmd. Please edit that file -->

# traveltime

![GitHub
License](https://img.shields.io/github/license/geryan/traveltime)
[![Lifecycle:](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
![GitHub commit
activity](https://img.shields.io/github/commit-activity/w/geryan/traveltime)
![GitHub Downloads (all assets, all
releases)](https://img.shields.io/github/downloads/geryan/traveltime/total)
![GitHub last
commit](https://img.shields.io/github/last-commit/geryan/traveltime)
![GitHub commits since latest
release](https://img.shields.io/github/commits-since/geryan/traveltime/latest)

Implements methods from Weiss et al. 2018, 2020 to calculate travel time
from given locations over a friction surface.

Citations: D. J. Weiss, A. Nelson, C. A. Vargas-Ruiz, K. Gligoric, S.,
Bavadekar, E. Gabrilovich, A. Bertozzi-Villa, J. Rozier, H. S. Gibson,
T., Shekel, C. Kamath, A. Lieber, K. Schulman, Y. Shao, V. Qarkaxhija,
A. K. Nandi, S. H. Keddie, S. Rumisha, P. Amratia, R. Arambepola, E. G.
Chestnutt, J. J. Millar, T. L. Symons, E. Cameron, K. E. Battle, S.
Bhatt, and P. W. Gething. Global maps of travel time to healthcare
facilities. (2020) Nature Medicine.
<https://doi.org/10.1038/s41591-020-1059-1>

D. J. Weiss, A. Nelson, H.S. Gibson, W. Temperley, S. Peedell, A.
Lieber, M. Hancher, E. Poyart, S. Belchior, N. Fullman, B. Mappin, U.
Dalrymple, J. Rozier, T.C.D. Lucas, R.E. Howes, L.S. Tusting, S.Y. Kang,
E. Cameron, D. Bisanzio, K.E. Battle, S. Bhatt, and P.W. Gething. A
global map of travel time to cities to assess inequalities in
accessibility in 2015. (2018). Nature. <doi:10.1038/nature25181>.

## Installation

You can install the development version of traveltime from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("geryan/traveltime")
```

## Example

``` r
library(traveltime)
library(terra)
#> terra 1.7.71

friction_surface <- get_friction_surface(
    surface = "motor2020",
    extent = matrix(
      data = c("111", "0", "112", 1),
      nrow = 2,
      ncol = 2,
      dimnames = list(
        c("x", "y"),
        c("min", "max")
      )
    )
  )
#> Checking if the following Surface-Year combinations are available to download:
#> 
#>     DATASET ID  YEAR
#>   - Explorer__2020_motorized_friction_surface:  DEFAULT
#> 
#> Loading required package: sf
#> Linking to GEOS 3.11.0, GDAL 3.5.3, PROJ 9.1.0; sf_use_s2() is FALSE
#> <GMLEnvelope>
#> ....|-- lowerCorner: 0 111
#> ....|-- upperCorner: 1 112
friction_surface
#> class       : SpatRaster 
#> dimensions  : 120, 120, 1  (nrow, ncol, nlyr)
#> resolution  : 0.008333333, 0.008333333  (x, y)
#> extent      : 111, 112, 0, 1  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (EPSG:4326) 
#> source      : Explorer__2020_motorized_friction_surface_0,111,1,112.tif 
#> name        : friction_surface
```

``` r
plot(friction_surface)
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

``` r
from_here <- tibble::tibble(
  x = c(111.2, 111.9),
  y = c(0.2, 0.35)
)
from_here
#> # A tibble: 2 × 2
#>       x     y
#>   <dbl> <dbl>
#> 1  111.  0.2 
#> 2  112.  0.35
```

``` r
travel_time <- calculate_travel_time(
  friction_surface = friction_surface,
  points = from_here
)
travel_time
#> class       : SpatRaster 
#> dimensions  : 120, 120, 1  (nrow, ncol, nlyr)
#> resolution  : 0.008333333, 0.008333333  (x, y)
#> extent      : 111, 112, 0, 1  (xmin, xmax, ymin, ymax)
#> coord. ref. :  
#> source(s)   : memory
#> name        : travel_time 
#> min value   :      0.0000 
#> max value   :    582.1882
```

``` r
plot(travel_time)
points(from_here, pch = 19, add = TRUE)
#> Warning in plot.xy(xy.coords(x, y), type = type, ...): "add" is not a graphical
#> parameter
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />
