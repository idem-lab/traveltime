# Extent vector to matrix

Extent vector to matrix

## Usage

``` r
ext_vect_to_matrix(x)
```

## Arguments

- x:

  `numeric` length 4, consisting of `c(xmin, xmax, ymin, ymax)`
  dimensions of extent

## Value

2x2 `matrix`

## Examples

``` r

ext_vect_to_matrix(c(111,112,0, 1))
#>   min max
#> x 111 112
#> y   0   1
```
