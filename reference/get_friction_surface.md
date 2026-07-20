# Get friction surface

Wrapper function to download friction surfaces via
[`malariaAtlas::getRaster()`](https://rdrr.io/pkg/malariaAtlas/man/getRaster.html).

## Usage

``` r
get_friction_surface(
  surface = c("motor2020", "walk2020"),
  filename = NULL,
  overwrite = FALSE,
  extent = NULL
)
```

## Arguments

- surface:

  `"motor2020"` or `"walk2020`.

- filename:

  `character`. File name for output layer.

- overwrite:

  Overwrite `filename` if exists

- extent:

  Spatial extent as one of:

  - a numeric vector specifying `c(xmin, xmax, ymin, ymax)`,

  - a `terra` `SpatExtent`, `SpatVector`, or `SpatRaster` from which the
    extent will be taken, or

  - or 2x2 `matrix`

  See details

## Value

`SpatRaster`

## Details

Convenience wrapper to
[`malariaAtlas::getRaster()`](https://rdrr.io/pkg/malariaAtlas/man/getRaster.html)
to access motorised and walking travel friction layers per Weiss et al.
2020, that adds safety to check existing files before download. Surfaces
can be downloaded directly from:
<https://malariaatlas.org/project-resources/accessibility-to-healthcare/>.

Here —

- `surface = "motor2020"` will download
  `"Explorer__2020_motorized_friction_surface"`, and

- `surface = "walk2020"` will download
  `"Explorer__2020_walking_only_friction_surface"`.

D. J. Weiss, A. Nelson, C. A. Vargas-Ruiz, K. Gligoric, S., Bavadekar,
E. Gabrilovich, A. Bertozzi-Villa, J. Rozier, H. S. Gibson, T., Shekel,
C. Kamath, A. Lieber, K. Schulman, Y. Shao, V. Qarkaxhija, A. K. Nandi,
S. H. Keddie, S. Rumisha, P. Amratia, R. Arambepola, E. G. Chestnutt, J.
J. Millar, T. L. Symons, E. Cameron, K. E. Battle, S. Bhatt, and P. W.
Gething. Global maps of travel time to healthcare facilities. (2020)
Nature Medicine. <https://doi.org/10.1038/s41591-020-1059-1>

`extent` is formatted and then passed through to
[`malariaAtlas::getRaster()`](https://rdrr.io/pkg/malariaAtlas/man/getRaster.html)
as a 2x2 matrix. It is converted into a matrix using `ext_matrix`. The
`matrix` format used is as returned by
[`sf::st_bbox()`](https://r-spatial.github.io/sf/reference/st_bbox.html)
— the first column has the minimum, the second the maximum values; rows
1 & 2 represent the x & y dimensions respectively:
`matrix(c("xmin", "ymin", "xmax", "ymax"), nrow = 2, ncol = 2, dimnames = list(c("x", "y"), c("min", "max")))`.
`NULL` extent downloads (large) global layer.

Troubleshooting: if you get a warning
`Failed to connect to MAP geoserver`, this is an issue with fetching the
friction surface using
[`malariaAtlas::getRaster`](https://rdrr.io/pkg/malariaAtlas/man/getRaster.html),
and not an issue with `traveltime` itself. The server may be down or
there may be an issue with that package.

## Examples

``` r

# for more examples of passing exten types see ?ext_matrix

ext <- c(111, 112, 0, 1)

 get_friction_surface(
   surface = "motor2020",
   extent = ext
 )
#> Checking if the following Surface-Year combinations are available to download:
#> 
#>     DATASET ID  YEAR 
#>   - Accessibility__202001_Global_Motorized_Friction_Surface:  DEFAULT 
#> 
#> No encoding supplied: defaulting to UTF-8.
#> <GMLEnvelope>
#> ....|-- lowerCorner: 0 111
#> ....|-- upperCorner: 1 112
#> No encoding supplied: defaulting to UTF-8.
#> class       : SpatRaster
#> size        : 120, 120, 1  (nrow, ncol, nlyr)
#> resolution  : 0.008333333, 0.008333333  (x, y)
#> extent      : 111, 112, 3.774758e-15, 1  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (EPSG:4326)
#> source      : Accessibility__202001_Global_Motorized_Friction_Surface_0,111,1,112.tif
#> name        : friction_surface
```
