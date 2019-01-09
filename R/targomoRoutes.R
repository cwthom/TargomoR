routeDependency <- function() {
  htmltools::htmlDependency(name = "targomoPolygons", version = "0.1",
                            src = system.file("htmlwidgets", package = "TargomoR"),
                            script = "addTargomoRoutes.js")
}

#' Add Targomo Routes
#'
#' @export
addTargomoRoutes = function(map,
                            api_key = Sys.getenv("TARGOMO_API_KEY")) {

  map$dependencies <- c(map$dependencies,
                        list(targomoDependency()),
                        list(routeDependency()))

  leaflet::invokeMethod(map, leaflet::getMapData(map), 'addTargomoRoutes')

}
