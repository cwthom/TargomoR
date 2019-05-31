#' Get Targomo Routes
#'
#' @rdname addTargomoRoutes
#' @export
getTargomoRoutes <- function(api_key = Sys.getenv("TARGOMO_API_KEY"),
                             region = Sys.getenv("TARGOMO_REGION"),
                             source_data = NULL, source_lat = NULL, source_lng = NULL,
                             target_data = NULL, target_lat = NULL, target_lng = NULL,
                             options = targomoOptions(),
                             verbose = FALSE,
                             progress = FALSE) {

  options <- deriveOptions(options)
  sources <- deriveSources(source_data, source_lat, source_lng, options)
  targets <- deriveTargets(target_data, target_lat, target_lng)

  response <- callTargomoAPI(api_key = api_key, region = region, service = "route",
                             sources = sources, targets = targets, options = options,
                             verbose = verbose, progress = progress)

  output <- processResponse(response, service = "route")
  if (options$tm$tm != "transit") {
    output <- lapply(output, function(route) route[c("points", options$tm$tm)])
  }

  return(output)

}


addTargomoRoutes <- function(map,
                             api_key = Sys.getenv("TARGOMO_API_KEY"),
                             region = Sys.getenv("TARGOMO_REGION"),
                             source_data = NULL, source_lat = NULL, source_lng = NULL,
                             target_data = NULL, target_lat = NULL, target_lng = NULL,
                             options = targomoOptions(),
                             verbose = FALSE, progress = FALSE,
                            ...) {

  routes <- getTargomoRoutes(api_key = api_key, region = region,
                             source_data = source_data, source_lat = source_lat,
                             source_lng = source_lng, target_data = target_data,
                             target_lat = target_lat, target_lng = target_lng,
                             options = options,
                             verbose = verbose, progress = progress)

  for (route in routes) {
    if (options$travelType %in% c("car", "bike", "walk")) {
      map <- map %>% leaflet::addMarkers(data = route$points) %>%
        leaflet::addPolylines(data = route[[options$travelType]])
    } else{
      map <- map %>% leaflet::addMarkers(data = route$points) %>%
        leaflet::addPolylines(data = route$walk, color = "green", dashArray = "3") %>%
        leaflet::addPolylines(data = route$transit, color = "red") %>%
        leaflet::addCircleMarkers(data = route$transfers, color = "blue")
    }
  }

  return(map)

}
