
<!-- README.md is generated from README.Rmd. Please edit that file -->
TargomoR <a href='https://cwthom.github.io/TargomoR'><img src='man/figures/logo.png' align="right" height="139" /></a>
======================================================================================================================

<!-- badges: start -->
[![CRAN status](https://r-pkg.org/badges/version/TargomoR)](https://CRAN.R-project.org/package=TargomoR) [![Travis-CI Build Status](https://travis-ci.org/cwthom/TargomoR.svg?branch=master)](https://travis-ci.org/cwthom/TargomoR) [![codecov](https://codecov.io/gh/cwthom/TargomoR/branch/master/graph/badge.svg)](https://codecov.io/gh/cwthom/TargomoR) <!-- badges: end -->

Overview
--------

The `TargomoR` package provides an R interface to the [Targomo REST API](https://targomo.com/developers/). Use `TargomoR` to get real travel-time information:

**Isochrone Polygons**: visualise what 'half an hour away' really looks like, using public transport, driving, cycling or walking.

**Travel Routes**: visualise up-to-date routing data quickly and simply, with pre-written methods for adding complex data to leaflet maps.

**Point-to-Point Times**: get travel-time data for a large array of source and target points, in a tidy format ready to feed into further analysis.

Note
----

**This package is being developed with the permission of Targomo, but is not an official product. For more information about Targomo, please see their [website](https://www.targomo.com/developers/), and be aware of their [terms and conditions](https://account.targomo.com/legal/terms).**

See below for information on [installing](#installation) the package, setting up your [environment](#set-up-environment) correctly, and [using](#get-travel-time-data) the package.

Installation
------------

TargomoR is not yet on CRAN. To install this development version from GitHub please use:

``` r
remotes::install_github("cwthom/TargomoR")
library(TargomoR)
```

Set Up Environment
------------------

The functions in TargomoR all rely on having a Targomo API Key. To get yours, please [sign up with Targomo](https://targomo.com/developers/pricing/).

You'll also need to know what region of the world to use. For example if you're looking for travel-time information in Germany, your region is "westcentraleurope". [Find your region](https://targomo.com/developers/resources/availability/). In the examples on this page the region is "britishisles".

You can pass these variables to each function manually if you like, but to avoid this, the functions will default to use the `TARGOMO_API_KEY` and `TARGOMO_REGION` environment variables respectively.

To take advantage of this, you can set these variables in an .Renviron file. Use the following snippet to write the variables to the file.

``` r
setTargomoVariables(api_key = "<YOUR KEY>", region = "<YOUR REGION>",
                    global = FALSE)

# global = TRUE  will write to .Renviron at Sys.getenv("HOME")
# global = FALSE will write to .Renviron at getwd()
```

Restart R for these variables to take effect.

Get Travel Time Data
--------------------

You're now ready to use Targomo to get travel-time and routing data. There are three services currently supported:

-   [Isochrone Polygons](https://targomo.com/developers/intro/services/polygon/)
-   [Routing](https://targomo.com/developers/intro/services/routing/)
-   [Time](https://targomo.com/developers/intro/services/reachability/)

For each service there are 3 core functions:

-   `getTargomo{service}` - returns an `sf` object containing the requested data.
-   `drawTargomo{service}` - draws the resultant object on a `leaflet` map.
-   `addTargomo{service}` - combines `get`-ting and `draw`-ing into a single call.

The `draw*` and `add*` functions are provided as a convenience - feel free to create your own drawing functions to put the data onto a map!

There is also support for adding basemaps through `addTargomoTiles()`. See the vignette on [basemaps](https://cwthom.github.io/TargomoR/articles/Basemaps.html) for more information.

You can also check the capabilities of your Targomo account with `getTargomoCapabilities()`.

Attribution
-----------

It's a condition of use of the Targomo services that you attribute the travel time data to them. Full details can be found on their [attributions page](https://targomo.com/developers/resources/attribution/). To help with this there are two functions in `TargomoR`:

-   `attributionLink` - just returns the URL of the attributions page
-   `addTargomoAttribution` - adds the attribution iframe to a leaflet control, for use with leaflet maps.

It is your responsibility to make sure you comply with the attribution requirements appropriate to your plan.

Contributing
------------

Please note that the 'TargomoR' project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

------------------------------------------------------------------------

### Logo

-   made using [hexsticker](https://github.com/GuangchuangYu/hexSticker) by GuangchuangYu.
-   icon: made by [Freepik](https://www.flaticon.com/authors/freepik) from [www.flaticon.com](https://www.flaticon.com/).
-   font: [Caveat](https://fonts.google.com/specimen/Caveat) from Google Fonts.
