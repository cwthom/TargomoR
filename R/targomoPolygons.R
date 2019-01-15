#' Add Targomo Polygons
#'
#' @export
addTargomoPolygons = function(map,
                              api_key = Sys.getenv("TARGOMO_API_KEY"),
                              lng = 0,
                              lat = 51,
                              options = targomoOptions()) {

  map$dependencies <- c(map$dependencies,
                        targomoDependency())

  leaflet::invokeMethod(map, leaflet::getMapData(map), 'addTargomoPolygons',
                        api_key, lng, lat, options)

}

#' Set Targomo Options
#'
#' @export
targomoOptions = function(times = c(600, 1200, 1800),
                          transport = "car",
                          stroke = 10,
                          invert = FALSE) {

  opts <- leaflet::filterNULL(
    list(
      times = times,
      transport = transport,
      stroke = stroke,
      invert = invert
    )
  )

  return(opts)

}
