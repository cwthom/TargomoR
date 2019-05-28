#' Add Targomo Polygons
#'
#' This function and the associated options allow you to easily add isochrones from
#' the Targomo Polygon API to your leaflet map.
#'
#' @param map A leaflet map
#' @param api_key Your Targomo API key - defaults to the \code{TARGOMO_API_KEY} environment variable.
#' @param region Your Targomo region - defaults to the \code{TARGOMO_REGION} environment variable.
#'   See here for the different regions: \url{https://targomo.com/developers/availability/}
#' @param lat,lng Coordinates of the source of the polygons
#' @param options See \code{\link{targomoOptions}}.
#' @param layerId The leaflet map layerId for the resulting polygons.
#' @param group The leaflet map group for the polygons.
#' @param fitBounds Should the map rezoom to fit the bounds of the polygons?
#'
#' @name addTargomoPolygons

#' @export
addTargomoPolygons = function(map,
                              api_key = Sys.getenv("TARGOMO_API_KEY"),
                              region = Sys.getenv("TARGOMO_REGION"),
                              lat = 55.9, lng = -3.1,
                              options = targomoOptions(),
                              layerId = NULL,
                              group = NULL,
                              fitBounds = TRUE) {

  map$dependencies <- c(map$dependencies,
                        targomoDependency())

  leaflet::invokeMethod(map, leaflet::getMapData(map), 'addTargomoPolygons',
                        api_key, region, lat, lng, options, layerId, group,
                        fitBounds)

}

#' Set Targomo Options
#'
#' This function sets the options to be passed to the API service.
#'
#' @param travelTimes A vector of times, in seconds - each time corresponds to a
#'     different polygon. Your API key will determine how many you can add.
#' @param travelType What mode of transport to use - car, bike, walk or public transport.
#' @param strokeWidth The weight of stroke used to draw the polygons.
#' @param inverse Should the polygons be inverted?
#' @param intersectionMode Whether to calculate the union or intersection of multiple sources
#' @param ... Further arguments to pass to the API - see \url{https://docs.targomo.com/core/#/Polygon_Service/post_westcentraleurope_v1_polygon}
#'
#' @name targomoOptions
#'
#' @export
targomoOptions = function(travelTimes = c(600, 1200, 1800),
                          travelType = "bike",
                          strokeWidth = 20,
                          inverse = FALSE,
                          intersectionMode = "union",
                          ...) {

  leaflet::filterNULL(
    list(
      traveTimes = travelTimes,
      travelType = travelType,
      strokeWidth = strokeWidth,
      inverse = inverse,
      intersectionMode = intersectionMode,
      ...
    )
  )

}
