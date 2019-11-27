# TargomoR 0.2.0 

This is the first release of TargomoR, which wraps the Targomo REST API for R users. It provides an interface familiar to users of leaflet.

## Major Features

* Support for three core services: isochrone polygons, routes, times
* `getTargomo*()` to retrieve data from the API, and return as an `sf` object (or list of such objects, in the case of routes)
* `targomoOptions()` provides support for all main API settings, including variable travel times, rush hour modelling, modes of transport, up/downhill speed penalties and public transport time frames
* `config` argument to `getTargomo*()` allows for setting of proxy server and other configuration changes necessary for using package httr
* `timeout` argument to `getTargomo*()` allows for extending request timeout
* `verbose` and `progress` arguments for debugging
* `drawTargomo*()` to add the data to a leaflet map, using customisable drawing methods
* `*DrawOptions()` function allow for easy customisation of visuals, including changing colors, weights, opacities
* `addTargomo*()` to combine the API call and drawing, for use with `%>%` onto leaflet maps
* Pick up API key and region from environment variables TARGOMO_API_KEY and TARGOMO_REGION by default
* `setTargomoVariables()` to write these environment variables, either locally or globally, to an .Renviron file
* `addTargomoTiles()` to add Targomo basemaps to a leaflet map
* `getTargomoCapabilities()` returns list of default and min/max settings for API key and region (with custom print method for nicer viewing)
* `addTargomoAttribution()` adds an iframe to a leaflet map, adding an attribution (required by [Targomo terms of use](https://targomo.com/developers/resources/attribution/))

## Unsupported Features

* The Multigraph and Points of Interest services are not currently supported. Nor are the advanced services like fleet planning.
* There is currently no facility to set custom speeds for each OSM edge class - the REST API does support this
* All location and route data is must be supplied in CRS 4326, and is returned in the same. There is no intrinsic support for changing CRS, although you may do so after the fact of course.
* There is no way to query the requests remaining in a monthly period from the API key - this is not currently provided by Targomo.

## More Information

* Much more information can be found on the [TargomoR pkgdown site](https://cwthom.github.io/TargomoR).
