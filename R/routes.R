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
#' @param source_id,target_id Formulas or vectors of IDs to give to your source and target points.
#'   These will be used to match back to the input data if applicable.
#' @param options A list of \code{\link{targomoOptions}} to send to the API.
#' @param drawOptions A list of \code{\link{routeDrawOptions}} to determine how to show
#'   the resulting routes on the map.
#' @param group The leaflet map group to add the routes to. One group is used for all
#'   map elements being drawn per call to the API.
#' @param api_key Your Targomo API key - defaults to the \code{TARGOMO_API_KEY}
#'   ennvironment variable.
#' @param region Your Targomo region - defaults to the \code{TARGOMO_REGION}
#'   environment variable.
#' @param config Config options to pass to \code{httr::POST} e.g. proxy settings
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
                             source_id = NULL, target_id = NULL,
                             options = targomoOptions(),
                             api_key = Sys.getenv("TARGOMO_API_KEY"),
                             region = Sys.getenv("TARGOMO_REGION"),
                             config = list(),
                             verbose = FALSE,
                             progress = FALSE) {

  output <- list()
  tms <- options$travelType

  s_points <- createPoints(source_data, source_lat, source_lng, source_id)
  t_points <- createPoints(target_data, target_lat, target_lng, target_id)
  targets <- deriveTargets(t_points)

  messageMultipleTravelModes(tms)

  for (tm in tms) {

    options$travelType <- tm
    tm_opts <- deriveOptions(options)
    sources <- deriveSources(s_points, tm_opts)

    body <- createRequestBody("route", sources, targets, tm_opts)

    response <- callTargomoAPI(api_key = api_key, region = region,
                               service = "route", body = body,
                               config = config,
                               verbose = verbose, progress = progress)

    output[[tm]] <- processResponse(response, service = "route")
  }

  return(output)

}


#' @rdname routes
#' @export
addTargomoRoutes <- function(map,
                             source_data = NULL, source_lat = NULL, source_lng = NULL, source_id = NULL,
                             target_data = NULL, target_lat = NULL, target_lng = NULL, target_id = NULL,
                             options = targomoOptions(),
                             drawOptions = routeDrawOptions(),
                             group = NULL,
                             api_key = Sys.getenv("TARGOMO_API_KEY"),
                             region = Sys.getenv("TARGOMO_REGION"),
                             config = list(),
                             verbose = FALSE, progress = FALSE) {

  routes <- getTargomoRoutes(api_key = api_key, region = region,
                             source_data = source_data, source_lat = source_lat,
                             source_lng = source_lng, source_id = source_id,
                             target_data = target_data, target_lat = target_lat,
                             target_lng = target_lng, target_id = target_id,
                             options = options, config = config,
                             verbose = verbose, progress = progress)

  drawRoutes(map, routes, drawOptions, group)

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
