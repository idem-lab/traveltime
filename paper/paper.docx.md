---
title: "`traveltime`: an R package to calculate travel time across a landscape from user-specified locations"
format:
  # md: default
  # wordcount-html:
  # html:
  #   keep-md: true
  #   fig-height: 4
  #   fig-align: center
  #   fig-format: png
  #   dpi: 300
  #pdf:
  docx:
    keep-md: true
    fig-height: 4
    fig-align: center
    dpi: 300
    fig-format: png
# header-includes:
#   \usepackage{lineno} \linenumbers
#   \usepackage{hanging}
tags: 
  - R
  - geographic information systems
  - spatial analysis
author:
  - name: Gerard E. Ryan
    orcid: 0000-0003-0183-7630
    corresponding: true
    affiliation: "1, 2"
  - name: Nicholas Tierney
    orcid: 0000-0003-1460-8722
    affiliation: "1, 3"
  - name: Nick Golding
    orcid: 0000-0001-8916-5570
    affiliation: "1, 4"
  - name: Daniel J. Weiss
    orcid: 0000-0002-6175-5648
    affiliation: "1, 3"
affiliations:
 - name: The Kids Research Institute Australia, Nedlands 6009 WA, Australia
   index: 1
 - name: Melbourne School of Population and Global Health, University of Melbourne, 3010, VIC, Australia
   index: 2
 - name: Curtin University, Bentley, WA, Australia
   index: 3
 - name: University of Western Australia, WA, Australia
   index: 4
date: 2025-05-02
bibliography: paper.bib
---







# Abstract

Understanding and mapping the time to travel among locations is useful for many activities from urban planning to public health and myriad others. Here we present a software package --- `traveltime` --- written in and for the language R. `traveltime` enables a user to create a raster map of the travel time over an area of interest from a user-specified set of locations defined by geographic coordinates. The result is a raster of the area of interest where the value in each cell is the lowest travel time in minutes to the nearest of the supplied locations. We envisage this software having diverse applications including: estimating sampling bias, allocating defibrillators, setting health districts, or mapping access to vehicle chargers and agricultural facilities. The work-flow requires two key steps: preparing a friction surface for the area of interest, and then calculating travel time over that surface for the points of interest. `traveltime` is available from [R-Universe](https://idem-lab.r-universe.dev/traveltime) and [GitHub](https://github.com/idem-lab/traveltime), and documented at <https://idem-lab.github.io/traveltime/>.


# Introduction

Understanding and mapping the time to travel among locations is useful for many activities from urban planning [@zahavi1974traveltime] to public health [@hulland2019travel; @weiss2020global] and myriad others [@nelson2019suite]. Global maps of travel time to cities [@weiss2018global; @nelson2019suite] and health care [@hulland2019travel; @weiss2020global] have generated much interest and use[^1], and the city data set of @nelson2019suite is available to R users through the widely-used `geodata` package [@geodata]. Here we extend that work to enable travel time calculations from any arbitrary set of locations and friction surface.


We present a software package --- `traveltime` --- written in and for the language R [@Rref]. `traveltime` enables a user to create a raster map of the travel time over an area of interest from a user-specified set of locations defined by geographic coordinates. The result is a raster of the area of interest where the value in each cell is the lowest travel time in minutes to the nearest of the supplied locations. We envisage this software having diverse applications including: estimating sampling bias [@dennis2000bias], allocating defibrillators [@tierney2018novel], setting health districts [@padgham2019introduction], or mapping access to vehicle chargers [@falchetta2021electric] and agricultural facilities [@zhao2023replanting].


A gaggle of R packages provide superficially similar though fundamentally different functionality via the [TravelTime.com](https://www.TravelTime.com) API [@traveltimeapi; @traveltimeR; @rtraveltime; @traveltime_gh]. Their 'Isochron' polygons --- areas reachable within a given time from a given location --- are most comparable to what `traveltime::calculate_travel_time()` calculates. However, each isochron is a single polygon calculated is for a single point location and specified maximum travel time, rather than a raster of temporal gradation across a landscape, jointly for an arbitrary number of points, as in `traveltime`. TravelTime.com cannot provide a single result surface for time to the nearest of a group of points, and continuous time scale without extensive repeated iteration for all combinations of time and points, plus additional calculation of the minimum value for each cell from all points. Furthermore, TravelTime.com requires access keys, a paid subscription beyond a short free period, and caps queries, which add considerable friction to the use of this resource.


With `traveltime`, we provide free and open source software to estimate travel time from any number of user-supplied locations, across a complete area of interest, and with convenient access to motorised transport or walking friction surfaces with global coverage.

[^1]: Collectively >1600 citations per Google Scholar at the 28th of January 2025.


# Methods


## Implementation

`traveltime` is an R [@Rref] package and requires installation of R version 4.1 or a more recent version `traveltime` provides a spatial interface using object classes from the `terra` package [@terra]. Travel time is calculated as movement over a resistance 'friction surface' [@gdistance2017]. To provide easy access to the existing friction surfaces generated by @weiss2020global, `traveltime` internally uses the R package `malariaAtlas` [@pfeffer2018malariaatlas] to download surfaces for the area of interest; though users can also supply any other friction surface raster.


## Operation

The work-flow requires two key steps:

-   preparing a friction surface for the area of interest, and then
-   calculating travel time over that surface for the points of interest.


### Installation

`traveltime` is available from [R-Universe](https://idem-lab.r-universe.dev/traveltime) and [GitHub](https://github.com/idem-lab/traveltime), and documented at <https://idem-lab.github.io/traveltime/>. It can be installed in R as follows:

``` r
install.packages("traveltime", repos = c("https://idem-lab.r-universe.dev"))
```

### Example: walking from public transport in Singapore

Here we provide an example to calculate and map the walking travel time from rail transport stations across Singapore. [Complete code for this example is available as a vignettte in package documentation](https://idem-lab.github.io/traveltime/articles/singapore.html).

#### Prepare data and friction surface

We need two items of data:

-   our area of interest --- Singapore, and
-   our points to calculate travel time from --- Singapore's Mass Rapid Transit (MRT) and Light Rail Transit (LRT) stations.

We download `singapore_shapefile`, a polygon boundary of Singapore from the GADM [@gadm] database using the `geodata` package [@geodata] as our area of interest:



::: {.cell}

```{.r .cell-code}
library(terra)
library(geodata)

singapore_shapefile <- gadm(
  country = "Singapore",
  level = 0,
  path = tempdir(),
  resolution = 2
)

singapore_shapefile
```

::: {.cell-output .cell-output-stdout}

```
 class       : SpatVector 
 geometry    : polygons 
 dimensions  : 1, 2  (geometries, attributes)
 extent      : 103.6091, 104.0858, 1.1664, 1.4714  (xmin, xmax, ymin, ymax)
 coord. ref. : lon/lat WGS 84 (EPSG:4326) 
 names       : GID_0   COUNTRY
 type        : <chr>     <chr>
 values      :   SGP Singapore
```


:::
:::




Next we use the function `traveltime::get_friction_surface` to retrieve a walking friction surface for our area of interest. Alternatively, we could use `surface = "motor2020"` for motorised travel. We're also only interested in walking *on land* so we `mask` out areas outside of the land boundary in `singapore_shapefile`. Users supplying their own friction surfaces do not need to download one in this fashion, only ensure that it is in `SpatRaster` format.



::: {.cell}

```{.r .cell-code}
friction_singapore <- traveltime::get_friction_surface(
    surface = "walk2020",
    extent = singapore_shapefile
  )|> 
  terra::mask(singapore_shapefile)
```

::: {.cell-output .cell-output-stdout}

```
<GMLEnvelope>
....|-- lowerCorner: 1.1664 103.6091
....|-- upperCorner: 1.4714 104.0858Start tag expected, '<' not found
```


:::

```{.r .cell-code}
friction_singapore
```

::: {.cell-output .cell-output-stdout}

```
class       : SpatRaster 
dimensions  : 37, 57, 1  (nrow, ncol, nlyr)
resolution  : 0.008333333, 0.008333333  (x, y)
extent      : 103.6083, 104.0833, 1.166667, 1.475  (xmin, xmax, ymin, ymax)
coord. ref. : lon/lat WGS 84 (EPSG:4326) 
source(s)   : memory
varname     : Accessibility__202001_Global_Walking_Only_Friction_Surface_1.1664,103.6091,1.4714,104.0858 
name        : friction_surface 
min value   :       0.01200000 
max value   :       0.06192715 
```


:::
:::



Our points are the `traveltime::stations` data, containing coordinates of all LRT and MRT station exits in Singapore [@singdata]:



::: {.cell}

```{.r .cell-code}
library(traveltime)
head(stations)
```

::: {.cell-output .cell-output-stdout}

```
            x        y
[1,] 103.9091 1.334922
[2,] 103.9335 1.336555
[3,] 103.8493 1.297699
[4,] 103.8508 1.299195
[5,] 103.9094 1.335311
[6,] 103.9389 1.344999
```


:::
:::



We plot these data below. `traveltime` takes resistance values of friction [@gdistance2017], so higher values of friction indicate more time travelling across a given cell.



::: {.cell}
::: {.cell-output-display}
![Friction surface raster of Singapore, showing Singapore boundary in grey, and station locations as grey points.](paper_files/figure-docx/fig-data-1.png){#fig-data}
:::
:::



#### Calculate and plot the travel time

With all the data collected, the function `calculate_travel_time()` takes the friction surface `friction_singapore` and the points of interest in `stations`, and returns a `SpatRaster` of walking time in minutes to each cell from the nearest station:



::: {.cell}

```{.r .cell-code}
trave_time_singapore <- calculate_travel_time(
  friction_surface = friction_singapore,
  points = stations
)

trave_time_singapore
```

::: {.cell-output .cell-output-stdout}

```
class       : SpatRaster 
dimensions  : 37, 57, 1  (nrow, ncol, nlyr)
resolution  : 0.008333333, 0.008333333  (x, y)
extent      : 103.6083, 104.0833, 1.166667, 1.475  (xmin, xmax, ymin, ymax)
coord. ref. :  
source(s)   : memory
name        : travel_time 
min value   :           0 
max value   :         Inf 
```


:::
:::



We present the resulting calculated travel times in Figure @fig-result where, as expected, the travel times are lowest near station exits (per Figure @fig-data) and progressively higher further away. Note that the results in `trave_time_singapore` include infinite values (`Inf` above). In Figure @fig-data, the islands to the south and north-east are shown as filled cells, but unconnected with the mainland. The raster cells for these islands appear absent in Figure \ref{fig-result}. Because they are not connected to any cells with a station, the calculated travel time is infinite, and so these cells do not appear in Figure \ref{fig-result}.



::: {.cell}
::: {.cell-output-display}
![Map of walking travel time in Singapore, in minutes from nearest MRT or LRT station.](paper_files/figure-docx/fig-result-1.png){#fig-result}
:::
:::





# Discussion 

*ADD MORE OF A GENERAL DISCUSSION HERE*

The `traveltime` package is immediately suitable to a range of application. Nonetheless, we see opportunities to build the package utility through:

  - capability to better distribute a wider range friction surfaces, and
  - additional methods to efficiently compute results over large spatial extents.

Firstly, `traveltime` currently facilitates access to walking and motorised friction surfaces for 2020, both at 30 arc-second resolution[^2]. Although the user can presently supply their own friction surface, we expect most applications will use these existing surfaces given the extensive work needed in creating new ones [@weiss2018global; @weiss2020global]. As landscapes are dynamic, it may be useful to incorporate updated versions of these friction surfaces if and when they are available. Furthermore, although the resolution of these data is likely to be suitable for larger landscape foci, higher resolution data may be helpful for more locally focussed analyses. For instance, although the example here was chosen for it's simplicity and low computational demands, a ~1 km^2^ cell size is a relatively large area to walk across, and thus actual waking times may vary significantly within each cell. We underline however that a user can provide their own higher resolution friction surface at present if desired.

Although this article is intended to be the key reference for the `traveltime` package, we suggest citations of the package are accompanied by citing the underlying methodological work as well [@weiss2018global; @weiss2020global].


[^2]: Approximately 0.008333 decimal degrees, or just below 1 km$^2$ at the equator

# Acknowledgements

This work was supported, in whole or in part, by the Bill & Melinda Gates Foundation [INV-021972]. The conclusions and opinions expressed in this work are those of the authors alone and shall not be attributed to the Foundation. Under the grant conditions of the Foundation, a Creative Commons Attribution 4.0 License has already been assigned to the Author Accepted Manuscript version that might arise from this submission. Please note works submitted as a preprint have not undergone a peer review process.

The package associated with this paper contains information from the dataset "LTA MRT Station Exit (GEOJSON)" accessed on the 10th of December 2024 from  data.gov.sg, which is made available under the terms of the Singapore Open Data Licence version 1.0 https://data.gov.sg/open-data-licence.

# References
