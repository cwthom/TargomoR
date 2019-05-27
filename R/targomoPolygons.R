#' Add Targomo Polygons
#'
#' This function and the associated options allow you to easily add isochrones from
#' the Targomo Polygon API to your leaflet map.
#'
#' @param map A leaflet map
#' @param api_key Your Targomo API key - recommend to use the 'TARGOMO_API_KEY' environment variable
#' @param lat,lng Coordinates of the source of the polygons
#' @param options See targomoOptions
#' @param fitBounds Should the map rezoom to fit the bounds of the polygons?
#'
#' @name add-tgm-polygons

#' @export
addTargomoPolygons = function(map,
                              api_key = Sys.getenv("TARGOMO_API_KEY"),
                              lat = 55.9, lng = -3.1,
                              options = targomoPolygonOptions(),
                              fitBounds = TRUE) {

  map$dependencies <- c(map$dependencies,
                        targomoDependency())

  leaflet::invokeMethod(map, leaflet::getMapData(map), 'addTargomoPolygons',
                        api_key, lat, lng, options, fitBounds)

}

#' Set Targomo Options
#'
#' This function sets the options to be passed to the API service when
#' requesting polygons.
#'
#' @param travelTimes A vector of times, in seconds - each time corresponds to a
#'     different polygon. Your API key will determine how many you can add.
#' @param travelType What mode of transport to use - car, bike, walk or public transport.
#' @param strokeWidth The weight of stroke used to draw the polygons.
#' @param inverse Should the polygons be inverted?
#'
#' @name targomo-polygon-options
#'
#' @export
targomoPolygonOptions = function(travelTimes = c(600, 1200, 1800),
                                 travelType = "bike",
                                 strokeWidth = 20,
                                 inverse = FALSE) {

  opts <- leaflet::filterNULL(
    list(
      traveTimes = travelTimes,
      travelType = travelType,
      strokeWidth = strokeWidth,
      inverse = inverse
    )
  )

  return(opts)

}
