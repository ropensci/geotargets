
<!-- README.md is generated from README.Rmd. Please edit that file -->

# geotargets <a href="https://docs.ropensci.org/geotargets/"><img src="man/figures/logo.png" alt="geotargets website" align="right" height="139"/></a>

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R
Targetopia](https://img.shields.io/badge/R_Targetopia-member-blue?style=flat&labelColor=gray)](https://wlandau.github.io/targetopia/)
[![R-CMD-check](https://github.com/ropensci/geotargets/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ropensci/geotargets/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/ropensci/geotargets/branch/master/graph/badge.svg)](https://app.codecov.io/gh/ropensci/geotargets?branch=master)
[![pkgcheck](https://github.com/ropensci/geotargets/workflows/pkgcheck/badge.svg)](https://github.com/ropensci/geotargets/actions?query=workflow%3Apkgcheck)
[![Status at rOpenSci Software Peer
Review](https://badges.ropensci.org/675_status.svg)](https://github.com/ropensci/software-review/issues/675)
[![R-multiverse
status](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fcommunity.r-multiverse.org%2Fapi%2Fpackages%2Fgeotargets&query=%24.Version&label=r-multiverse)](https://community.r-multiverse.org/geotargets)
[![CRAN
status](https://www.r-pkg.org/badges/version/geotargets)](https://CRAN.R-project.org/package=geotargets)
<!-- badges: end -->

`geotargets` extends [`targets`](https://github.com/ropensci/targets) to
work with geospatial data formats, such as rasters and vectors (e.g.,
shapefiles). Currently we support raster and vector formats for the
[`terra`](https://github.com/rspatial/terra) package.

If you are unfamiliar with targets, we recommend watching [“targets in 4
minutes”](https://docs.ropensci.org/targets/#get-started-in-4-minutes).

## How to cite geotargets

One example citation of geotargets could be as follows: “R packages used
in this analysis included (list R packages used), targets, and
geotargets (Tierney, N., Scott, E., & Brown, A, 2024). Here is the full
bibliographic reference for your references:

> Tierney N, Scott E, Brown A (2024). “geotargets: ‘Targets’ Extensions
> for Geospatial Formats.” <https://docs.ropensci.org/geotargets/>.

## Installation

You can install the development version of geotargets like so:

``` r
install.packages("geotargets", repos = c("https://ropensci.r-universe.dev", "https://cran.r-project.org"))
```

## Why `geotargets`

If you want to use geospatial data formats (such as `terra`) with the
[`targets`](https://github.com/ropensci/targets) package to build
analytic reproducible pipelines, it involves writing a lot of custom
targets wrappers. We wrote `geotargets` so you can use geospatial data
formats with `targets`.

To provide more detail on this, a common problem when using popular
libraries like `terra` with `targets` is running into errors with read
and write. Due to the limitations that come with the underlying C++
implementation in the `terra` library, there are specific ways to write
and read these objects. See `?terra` for details. `geotargets` helps
handle these write and read steps, so you don’t have to worry about them
and can use targets as you are used to.

In essence, if you’ve ever come across the error:

    Error in .External(list(name = "CppMethod__invoke_notvoid", address = <pointer: 0x0>,  : 
      NULL value passed as symbol address

or

    Error: external pointer is not valid

When trying to read in a geospatial raster or vector in targets, then
`geotargets` for you :)

# Examples

We currently provide support for the `terra` package with `targets`.
Below we show three examples of target factories:

- `tar_terra_rast()`
- `tar_terra_vect()`
- `tar_terra_sprc()`
- `tar_terra_sds()`
- `tar_terra_tiles()`
- `tar_stars()`

You would use these in place of `tar_target()` in your targets pipeline,
e.g., when you are doing work with `terra` raster, vector, or raster
collection data.

If you would like to see and download working examples for yourself, see
the repos:

- [demo-geotargets](https://github.com/njtierney/demo-geotargets)
- [icebreaker](https://github.com/njtierney/icebreaker)

## `tar_terra_rast()`: targets with terra rasters

``` r
library(targets)

tar_dir({
  # tar_dir() runs code from a temporary directory.
  tar_script({
    library(geotargets)

    get_elev <- function() {
      terra::rast(system.file("ex", "elev.tif", package = "terra"))
    }

    list(
      tar_terra_rast(
        terra_rast_example,
        get_elev()
      )
    )
  })

  tar_make()
  x <- tar_read(terra_rast_example)
  x
})
#> + terra_rast_example dispatched
#> ✔ terra_rast_example completed [65ms, 8.52 kB]
#> ✔ ended pipeline [383ms, 1 completed, 0 skipped]
#> class       : SpatRaster 
#> size        : 90, 95, 1  (nrow, ncol, nlyr)
#> resolution  : 0.008333333, 0.008333333  (x, y)
#> extent      : 5.741667, 6.533333, 49.44167, 50.19167  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (EPSG:4326) 
#> source      : terra_rast_example 
#> name        : elevation 
#> min value   :       141 
#> max value   :       547
```

## `tar_terra_vect()`: targets with terra vectors

``` r
tar_dir({
  # tar_dir() runs code from a temporary directory.
  tar_script({
    library(geotargets)

    lux_area <- function(projection = "EPSG:4326") {
      terra::project(
        terra::vect(system.file("ex", "lux.shp", package = "terra")),
        projection
      )
    }

    list(
      tar_terra_vect(
        terra_vect_example,
        lux_area()
      )
    )
  })

  tar_make()
  x <- tar_read(terra_vect_example)
  x
})
#> + terra_vect_example dispatched
#> ✔ terra_vect_example completed [72ms, 172.03 kB]
#> ✔ ended pipeline [264ms, 1 completed, 0 skipped]
#>  class       : SpatVector 
#>  geometry    : polygons 
#>  dimensions  : 12, 6  (geometries, attributes)
#>  extent      : 5.74414, 6.528252, 49.44781, 50.18162  (xmin, xmax, ymin, ymax)
#>  source      : terra_vect_example
#>  coord. ref. : lon/lat WGS 84 (EPSG:4326) 
#>  names       :  ID_1   NAME_1  ID_2   NAME_2  AREA       POP
#>  type        : <num>    <chr> <num>    <chr> <num>     <num>
#>  values      :     1 Diekirch     1 Clervaux   312 1.808e+04
#>                    1 Diekirch     2 Diekirch   218 3.254e+04
#>                    1 Diekirch     3  Redange   259 1.866e+04
```

## `tar_terra_sprc()`: targets with terra raster collections

``` r
tar_dir({
  # tar_dir() runs code from a temporary directory.
  tar_script({
    library(geotargets)

    elev_scale <- function(z = 1, projection = "EPSG:4326") {
      terra::project(
        terra::rast(system.file("ex", "elev.tif", package = "terra")) * z,
        projection
      )
    }

    list(
      tar_terra_sprc(
        raster_elevs,
        # two rasters, one unaltered, one scaled by factor of 2 and
        # reprojected to interrupted goode homolosine
        command = terra::sprc(list(
          elev_scale(1),
          elev_scale(2, "+proj=igh")
        ))
      )
    )
  })

  tar_make()
  x <- tar_read(raster_elevs)
  x
})
#> + raster_elevs dispatched
#> ✔ raster_elevs completed [191ms, 37.90 kB]
#> ✔ ended pipeline [470ms, 1 completed, 0 skipped]
#> class       : SpatRasterCollection 
#> length      : 2 
#> nrow        : 90, 115 
#> ncol        : 95, 114 
#> nlyr        :  1,   1 
#> extent      : 5.741667, 1558890, 49.44167, 5556741  (xmin, xmax, ymin, ymax)
#> crs (first) : lon/lat WGS 84 (EPSG:4326) 
#> names       : raster_elevs, raster_elevs
```

## `tar_stars()`: targets with stars objects

``` r
tar_dir({
  # tar_dir() runs code from a temporary directory.
  tar_script({
    library(geotargets)

    list(
      tar_stars(
        test_stars,
        stars::read_stars(system.file(
          "tif",
          "olinda_dem_utm25s.tif",
          package = "stars"
        ))
      )
    )
  })

  tar_make()
  x <- tar_read(test_stars)
  x
})
#> + test_stars dispatched
#> ✔ test_stars completed [63ms, 49.90 kB]
#> ✔ ended pipeline [275ms, 1 completed, 0 skipped]
#> stars object with 2 dimensions and 1 attribute
#> attribute(s):
#>             Min. 1st Qu. Median     Mean 3rd Qu. Max.
#> test_stars    -1       6     12 21.66521      35   88
#> dimension(s):
#>   from  to  offset  delta                       refsys point x/y
#> x    1 111  288776  89.99 UTM Zone 25, Southern Hem... FALSE [x]
#> y    1 111 9120761 -89.99 UTM Zone 25, Southern Hem... FALSE [y]
```

## Code of Conduct

Please note that the geotargets project is released with a [Contributor
Code of Conduct](https://ropensci.org/code-of-conduct/). By contributing
to this project, you agree to abide by its terms.

## Acknowledgements

Logo design by Hubert Hałun at Appsilon.
