#' Add Targomo Polygons
#'
#' @export
addTargomoPolygons = function(map,
                              api_key = Sys.getenv("TARGOMO_API_KEY"),
                              lat = 56, lng = -3,
                              options = targomoOptions(),
                              fitBounds = TRUE) {

  map$dependencies <- c(map$dependencies,
                        targomoDependency())

  leaflet::invokeMethod(map, leaflet::getMapData(map), 'addTargomoPolygons',
                        api_key, lat, lng, options, fitBounds)

}

#' Set Targomo Options
#'
#' @export
targomoOptions = function(travelTimes = c(600, 1200, 1800),
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
