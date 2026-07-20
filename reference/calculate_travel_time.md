# Calculate travel time

Calculate the travel time from a set of points over a friction surface.

## Usage

``` r
calculate_travel_time(
  friction_surface,
  points,
  filename = NULL,
  overwrite = FALSE
)
```

## Arguments

- friction_surface:

  A `SpatRaster` friction surface layer with in resistance units. See
  Details.

- points:

  A two-column `matrix`, `data.frame`, (including `tibble` types) with
  longitude (x) in the first column and latitude (y) in the second, or a
  `SpatVector`, in the same coordinate reference system as
  `friction_surface`. Points that fall outside `friction_surface` are
  dropped with a warning; if none fall within it, an error is raised.

- filename:

  `character`. Output file name with extension suitable for
  [`terra::writeRaster`](https://rspatial.github.io/terra/reference/writeRaster.html).
  If `NULL` (default), output will be returned in memory

- overwrite:

  `logical`. If `TRUE` `filename` is overwritten.

## Value

`SpatRaster`

## Details

Implements methods from Weiss et al. 2018, 2020 to calculate travel time
from given locations over a friction surface.

Over large areas this function can require significant RAM and will be
slow.

Pre-prepared walking or motorised friction surfaces can be obtained
with[`?get_friction_surface`](https://idem-lab.github.io/traveltime/reference/get_friction_surface.md).
User can also provide their own friction surface. This surface but must
be in resistance units (1/conductance), e.g. minutes/meter. See Van
Etten 2017.

Note on this implementation: as of package version 1. Earlier versions
of this package used the `raster` and `gdistance` packages. These
dependencies have been removed and now instead rely exclusively on
`terra` for spatial data handling. The two approaches use the same cost
model (eight-direction movement, edge cost `distance * mean(friction)`)
and produce effectively the same result.
[`terra::costDist()`](https://rspatial.github.io/terra/reference/costDist.html)
computes true geodesic inter-cell distances, so the new approach is
*more* accurate than the old `gdistance`'s distance approximation away
from the equator (the results are identical at the equator and for
projected coordinate systems). The remaining difference is a boundary
convention at the origins: `gdistance` includes half of the starting
cell's own friction when leaving a point, whereas
[`terra::costDist`](https://rspatial.github.io/terra/reference/costDist.html)
measures cost to the border of the origin cells and omits it. This
appears as a small, near-constant offset (about half a cell of friction)
close to the origin points. See
`data-raw/costdist_migration_comparison.md` in the package source for
the full comparison.

Citations:

D. J. Weiss, A. Nelson, C. A. Vargas-Ruiz, K. Gligoric, S., Bavadekar,
E. Gabrilovich, A. Bertozzi-Villa, J. Rozier, H. S. Gibson, T., Shekel,
C. Kamath, A. Lieber, K. Schulman, Y. Shao, V. Qarkaxhija, A. K. Nandi,
S. H. Keddie, S. Rumisha, P. Amratia, R. Arambepola, E. G. Chestnutt, J.
J. Millar, T. L. Symons, E. Cameron, K. E. Battle, S. Bhatt, and P. W.
Gething. Global maps of travel time to healthcare facilities. (2020)
Nature Medicine. <https://doi.org/10.1038/s41591-020-1059-1>

D. J. Weiss, A. Nelson, H.S. Gibson, W. Temperley, S. Peedell, A.
Lieber, M. Hancher, E. Poyart, S. Belchior, N. Fullman, B. Mappin, U.
Dalrymple, J. Rozier, T.C.D. Lucas, R.E. Howes, L.S. Tusting, S.Y. Kang,
E. Cameron, D. Bisanzio, K.E. Battle, S. Bhatt, and P.W. Gething. A
global map of travel time to cities to assess inequalities in
accessibility in 2015. (2018). Nature.
[https://doi:10.1038/nature25181](https://doi:10.1038/nature25181)

van Etten, J. (2017). R package gdistance: Distances and routes on
geographical grids. Journal of Statistical Software
<https://doi.org/10.18637/jss.v076.i13>

## Examples

``` r

ext <- matrix(
  data = c("111", "0", "112", 1),
  nrow = 2,
  ncol = 2,
  dimnames = list(
    c("x", "y"),
    c("min", "max")
   )
 )

 friction_surface <- get_friction_surface(
   surface = "motor2020",
   extent = ext
 )
#> Registered S3 methods overwritten by 'malariaAtlas':
#>   method              from     
#>   autoplot.SpatRaster tidyterra
#>   autoplot.default    ggplot2  
#> Checking if the following Surface-Year combinations are available to download:
#> 
#>     DATASET ID  YEAR 
#>   - Accessibility__202001_Global_Motorized_Friction_Surface:  DEFAULT 
#> 
#> Loading required package: sf
#> Linking to GEOS 3.12.1, GDAL 3.8.4, PROJ 9.4.0; sf_use_s2() is FALSE
#> No encoding supplied: defaulting to UTF-8.
#> <GMLEnvelope>
#> ....|-- lowerCorner: 0 111
#> ....|-- upperCorner: 1 112

 from_here <- data.frame(
   x = c(111.2, 111.9),
   y = c(0.2, 0.35)
 )

 calculate_travel_time(
  friction_surface = friction_surface,
  points = from_here
 )
#> class       : SpatRaster
#> size        : 120, 120, 1  (nrow, ncol, nlyr)
#> resolution  : 0.008333333, 0.008333333  (x, y)
#> extent      : 111, 112, 3.774758e-15, 1  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (EPSG:4326)
#> source(s)   : memory
#> varname     : Accessibility__202001_Global_Motorized_Friction_Surface_0,111,1,112
#> name        : travel_time
#> min value   :           0
#> max value   :  565.122007
```
