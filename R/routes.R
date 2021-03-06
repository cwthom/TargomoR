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
#' @param routes A list of route segments provided by \code{\link{getTargomoRoutes}}.
#' @param ... Further arguments to pass to \code{\link[leaflet]{addPolylines}}
#' @param group The leaflet map group to add the routes to. One group is used for all
#'   map elements being drawn per call to the API.
#' @param api_key Your Targomo API key - defaults to the \code{TARGOMO_API_KEY}
#'   ennvironment variable.
#' @param region Your Targomo region - defaults to the \code{TARGOMO_REGION}
#'   environment variable.
#' @param config Config options to pass to \code{httr::POST} e.g. proxy settings
#' @param verbose Whether to print out information about the API call.
#' @param progress Whether to show a progress bar of the API call.
#' @param timeout Timeout in seconds (leave NULL for no timeout/curl default).
#'
#' @return For `get*`, a list of objects of class "sf" containing the routes For `draw*` and `add*`,
#'   the leaflet map returned with the routes drawn on.
#'
#' @examples
#' \donttest{
#' # load leaflet package
#' library(leaflet)
#' l <- leaflet()
#'
#' # get route from Big Ben to Tower Bridge
#' r <- getTargomoRoutes(source_lat = 51.5007, source_lng = -0.1246,
#'                       target_lat = 51.5055, target_lng = -0.0754,
#'                       options = targomoOptions(travelType = c("bike", "transit")))
#'
#' # draw the routes on the map
#' l %>% drawTargomoRoutes(routes = r)
#'
#' # note, could combine get.. and draw... into one with add...
#'
#' }
#'
#' @seealso \code{\link{draw-routes}}
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
                             progress = FALSE,
                             timeout = NULL) {

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
                               verbose = verbose, progress = progress,
                               timeout = timeout)

    output[[tm]] <- processResponse(response, service = "route")
  }

  return(output)

}

#' @rdname routes
#' @export
drawTargomoRoutes <- function(map, routes, drawOptions = routeDrawOptions(), group = NULL, ...) {

  travelModes <- names(routes)

  for (tm in travelModes) {
    for (route in routes[[tm]]) {

      features <- route$features
      segments <- features[sf::st_is(features$geometry, "LINESTRING"), ]

      if (drawOptions$showMarkers) {

        src <- features[!is.na(features$sourceId), ]
        trg <- features[!is.na(features$targetId), ]

        map <- map %>%
          leaflet::addMarkers(data = src, label = ~paste("Source:", sourceId), group = group) %>%
          leaflet::addMarkers(data = trg, label = ~paste("Target:", targetId), group = group)

      }

      if (tm == "car") {

        map <- drawCar(map, segments, drawOptions, group, ...)

      } else if (tm == "bike"){

        map <- drawBike(map, segments, drawOptions, group, ...)

      } else if (tm == "walk"){

        map <- drawWalk(map, segments, drawOptions, group, ...)

      } else if (tm %in% "transit") {

        walk     <- segments[segments$travelType == "WALK", ]
        transit  <- segments[segments$travelType == "TRANSIT", ]

        map <- map %>%
          drawWalk(segment = walk, drawOptions = drawOptions, group = group, ...) %>%
          drawTransit(segment = transit, drawOptions = drawOptions, group = group, ...)

      }

      if (tm == "transit" && drawOptions$showTransfers &&
          any(features$travelType == "TRANSFER", na.rm = TRUE)) {

        transfers <- suppressWarnings({
          features[features$travelType == "TRANSFER", ] %>%
            sf::st_cast(to = "POINT") %>%
            unique()
        })

        map <- map %>%
          leaflet::addCircleMarkers(data = transfers,
                                    color = drawOptions$transferColour,
                                    radius = drawOptions$transferRadius,
                                    group = group)
      }

    }
  }

  return(map)
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
                             verbose = FALSE, progress = FALSE,
                             timeout = NULL) {

  routes <- getTargomoRoutes(api_key = api_key, region = region,
                             source_data = source_data, source_lat = source_lat,
                             source_lng = source_lng, source_id = source_id,
                             target_data = target_data, target_lat = target_lat,
                             target_lng = target_lng, target_id = target_id,
                             options = options, config = config,
                             verbose = verbose, progress = progress,
                             timeout = timeout)

  map <- drawTargomoRoutes(
    map = map,
    routes = routes,
    drawOptions = drawOptions,
    group = group
  )

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
#' @return A list of options governing how the routes are drawn on the map.
#'
#' @examples
#' # show the list
#' routeDrawOptions()
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


#' Draw Routes
#'
#' Helper functions for drawing different routes.
#'
#' @param map A leaflet map.
#' @param segment A route segment object to draw.
#' @param drawOptions Drawing options provided by \code{\link{routeDrawOptions}}.
#' @param type What route type to draw.
#' @param group The leaflet map group to add the routes to.
#' @param ... Further arguments to pass to leaflet functions.
#'
#' @return The map with the route segment/markers drawn on
#'
#' @name draw-routes
#'
NULL

#' @rdname draw-routes
drawRouteSegment <- function(map, segment, drawOptions, type, group, ...) {

  drawOpts <- drawOptions[paste0(type, c("Colour", "Weight", "DashArray"))]
  names(drawOpts) <- c("colour", "weight", "dashArray")


  map <- leaflet::addPolylines(
    map = map,
    data = segment,
    color = drawOpts$colour,
    weight = drawOpts$weight,
    dashArray = drawOpts$dashArray,
    label = "Click for more information",
    popup = createRoutePopup(segment, transit = {type == "transit"}),
    group = group,
    ...
  )

  return(map)

}

#' @rdname draw-routes
drawWalk <- function(map, segment, drawOptions, group, ...) {
  map <- drawRouteSegment(map, segment, drawOptions, "walk", group, ...)
  map
}

#' @rdname draw-routes
drawBike <- function(map, segment, drawOptions, group, ...) {
  map <- drawRouteSegment(map, segment, drawOptions, "bike", group, ...)
  map
}

#' @rdname draw-routes
drawCar <- function(map, segment, drawOptions, group, ...) {
  drawRouteSegment(map, segment, drawOptions, "car", group, ...)
}

#' @rdname draw-routes
drawTransit <- function(map, segment, drawOptions, group, ...) {
  map <- drawRouteSegment(map, segment, drawOptions, "transit", group, ...)
  map
}


#' Create Route Popups
#'
#' Function for constructing popups on routes.
#'
#' @param data The route data from which to create the popup.
#' @param transit Whether this is a transit route.
#' @param startEnd Whether to show information on the start and end points.
#'
#' @return A HTML string for the route segment popup
#'
createRoutePopup <- function(data, transit = FALSE, startEnd = transit) {

  if (transit) {
    header <- ifelse(data$routeType == 1, "UNDERGROUND",
                     ifelse(data$routeType == 2, "TRAIN",
                            ifelse(data$routeType == 3, "BUS",
                                   "PUBLIC TRANSPORT")))
    header <- paste(header, "-", data$routeShortName)
  } else {
    header <- data$travelType
  }

  paste0("<b>", header, "</b></br>",
         if(startEnd) paste0("Start: ", data$startName, "</br>",
                             "End: ", data$endName, "</br>"),
         "Journey time: ", sapply(data$travelTime, prettyEdgeWeight, type = "time"))
}


