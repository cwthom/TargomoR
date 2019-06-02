#' Add Targomo Routes to a Leaflet Map
#'
#' This function takes source and target data, together with options for the API and
#' drawing options, and returns the map with the requested routes.
#'
#' @param map A leaflet map
#' @param source_data,target_data The source and target points for your routes -
#'   supported types are data.frame matrix and objects from the sf and sp packages.
#' @param source_lat,source_lng Columns identifying the latitude
#'   and longitude columns in your sourcedata, or numeric vectors of equal length.
#' @param target_lat,target_lng As for \code{source_lat,source_lng} but for target data.
#' @param options A list of \code{\link{targomoOptions}} to send to the API.
#' @param drawOptions A list of \code{\link{routeDrawOptions}} to determine how to show
#'   the resulting routes on the map.
#' @param group The leaflet map group to add the routes to. One group is used for all
#'   map elements being drawn per call to the API.
#' @param api_key Your Targomo API key - defaults to the \code{TARGOMO_API_KEY}
#'   ennvironment variable.
#' @param region Your Targomo region - defaults to the \code{TARGOMO_REGION}
#'   environment variable.
#' @param verbose Whether to print out information about the API call.
#' @param progress Whether to show a progress bar of the API call.
#'
#' @name routes
#'
NULL

#' @rdname routes
#' @export
getTargomoRoutes <- function(source_data = NULL, source_lat = NULL, source_lng = NULL,
                             target_data = NULL, target_lat = NULL, target_lng = NULL,
                             options = targomoOptions(),
                             api_key = Sys.getenv("TARGOMO_API_KEY"),
                             region = Sys.getenv("TARGOMO_REGION"),
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


#' @rdname routes
#' @export
addTargomoRoutes <- function(map,
                             source_data = NULL, source_lat = NULL, source_lng = NULL,
                             target_data = NULL, target_lat = NULL, target_lng = NULL,
                             options = targomoOptions(),
                             drawOptions = routeDrawOptions(),
                             group = NULL,
                             api_key = Sys.getenv("TARGOMO_API_KEY"),
                             region = Sys.getenv("TARGOMO_REGION"),
                             verbose = FALSE, progress = FALSE) {

  if (length(options$travelType) > 1) {
    message("Multiple (", length(options$travelType), ") travel types supplied - treating each in turn.\n",
            "This will make ", length(options$travelType), " calls to the API.")
    for (tm in options$travelType) {
      options$travelType <- tm
      map <- addTargomoRoutes(map, source_data, source_lat, source_lng, target_data,
                              target_lat, target_lng, options, drawOptions, group,
                              api_key, region, verbose, progress)
    }
    return(map)
  }

  routes <- getTargomoRoutes(api_key = api_key, region = region,
                             source_data = source_data, source_lat = source_lat,
                             source_lng = source_lng, target_data = target_data,
                             target_lat = target_lat, target_lng = target_lng,
                             options = options,
                             verbose = verbose, progress = progress)

  for (route in routes) {
    if (drawOptions$showMarkers) {

      map <- map %>% leaflet::addMarkers(data = route[["points"]], group = group)

    }
    if (options$travelType %in% c("car", "bike", "walk")) {

        map <- map %>%
          drawRoute(route = route[[options$travelType]], drawOptions = drawOptions,
                    type = options$travelType, group = group)

    } else if (options$travelType == "transit") {

      map <- map %>%
        drawWalk(route$walk, drawOptions, group = group) %>%
        drawTransit(route$transit, drawOptions, group = group)

      if (drawOptions$showTransfers) {
        map <- map %>%
          leaflet::addCircleMarkers(data = route$transfers,
                                    color = drawOptions$transferColour,
                                    radius = drawOptions$transferRadius,
                                    group = group)
      }
    }
  }

  return(map)

}

#' Options for Drawing Routes on the Map
#'
#' Function to return a list of the desired drawing options - you can set colours,
#' line weights and dash styles for each transport type, whether to show the source
#' and target markers, and whether to show transfers between different modes of transport.
#'
#' @param showMarkers Whether to show the source/target markers.
#' @param showTransfers whether to highlight transfers between different modes of transport.
#' @param walkColour,bikeColour,carColour,transitColour Set the line colours.
#' @param walkWeight,bikeWeight,carWeight,transitWeight Set the line weights.
#' @param walkDashArray,bikeDashArray,carDashArray,transitDashArray Set the dash styles.
#' @param transferColour Set the colour of transfer markers.
#' @param transferRadius Set the size of transfer markers.
#'
#' @export
routeDrawOptions <- function(showMarkers = TRUE,
                             showTransfers = TRUE,
                             walkColour = "green",
                             walkWeight = 5,
                             walkDashArray = "1,10",
                             carColour = "blue",
                             carWeight = 5,
                             carDashArray = NULL,
                             bikeColour = "orange",
                             bikeWeight = 5,
                             bikeDashArray = NULL,
                             transitColour = "red",
                             transitWeight = 5,
                             transitDashArray = NULL,
                             transferColour = "blue",
                             transferRadius = 10) {

  leaflet::filterNULL(
    list(showMarkers = showMarkers,
         showTransfers = showTransfers,
         walkColour = walkColour,
         walkWeight = walkWeight,
         walkDashArray = walkDashArray,
         carColour = carColour,
         carWeight = carWeight,
         carDashArray = carDashArray,
         bikeColour = bikeColour,
         bikeWeight = bikeWeight,
         bikeDashArray = bikeDashArray,
         transitColour = transitColour,
         transitWeight = transitWeight,
         transitDashArray = transitDashArray,
         transferColour = transferColour,
         transferRadius = transferRadius
    )
  )
}
