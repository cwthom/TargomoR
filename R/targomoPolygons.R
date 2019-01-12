#' Add Targomo Polygons
#'
#' @export
addTargomoPolygons = function(map,
                              api_key = Sys.getenv("TARGOMO_API_KEY"),
                              lng = 0,
                              lat = 51,
                              times = c(600, 1200, 1800),
                              transport = "walk",
                              stroke = 10) {

  map$dependencies <- c(map$dependencies,
                        targomoDependency())

  leaflet::invokeMethod(map, leaflet::getMapData(map), 'addTargomoPolygons',
                        api_key, lng, lat, times, transport, stroke)

}
