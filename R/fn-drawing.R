
#' Draw Routes
#'
#' Helper functions for drawing different routes.
#'
#' @param map A leaflet map.
#' @param routes A list of route segments provided by \code{\link{getTargomoRoutes}}.
#' @param segment A route segment object to draw.
#' @param drawOptions Drawing options provided by \code{\link{routeDrawOptions}}.
#' @param type What route type to draw.
#' @param group The leaflet map group to add the routes to.
#' @param ... Further arguments to pass to leaflet functions.
#'
#' @name draw
#'
NULL

#' @rdname draw
drawRouteSegment <- function(map, segment, drawOptions, type, group, ...) {

  drawOpts <- drawOptions[paste0(type, c("Colour", "Weight", "DashArray"))]
  names(drawOpts) <- c("colour", "weight", "dashArray")


  leaflet::addPolylines(map = map,
                        data = segment,
                        color = drawOpts$colour, weight = drawOpts$weight,
                        dashArray = drawOpts$dashArray,
                        label = "Click for more information",
                        popup = createRoutePopup(segment, transit = {type == "transit"}),
                        group = group,
                        ...)

}

#' @rdname draw
drawWalk <- function(map, segment, drawOptions, group, ...) {
  drawRouteSegment(map, segment, drawOptions, "walk", group, ...)
}

#' @rdname draw
drawBike <- function(map, segment, drawOptions, group, ...) {
  drawRouteSegment(map, segment, drawOptions, "bike", group, ...)
}

#' @rdname draw
drawCar <- function(map, segment, drawOptions, group, ...) {
  drawRouteSegment(map, segment, drawOptions, "car", group, ...)
}

#' @rdname draw
drawTransit <- function(map, segment, drawOptions, group, ...) {
  drawRouteSegment(map, segment, drawOptions, "transit", group, ...)
}

#' @rdname draw
#' @export
drawRoutes <- function(map, routes, drawOptions = routeDrawOptions(), group = NULL, ...) {

  travelModes <- names(routes)

  for (tm in travelModes) {
    for (route in routes[[tm]]) {

      if (drawOptions$showMarkers) {

        map <- map %>%
          leaflet::addMarkers(data = route[["points"]], group = group)

      }
      if (tm %in% c("car", "bike", "walk")) {

        map <- map %>%
          drawRouteSegment(segment = route[[tm]], drawOptions = drawOptions,
                           type = tm, group = group, ...)

      } else if (tm == "transit") {

        map <- map %>%
          drawWalk(route$walk, drawOptions, group = group, ...) %>%
          drawTransit(route$transit, drawOptions, group = group, ...)

        if (drawOptions$showTransfers) {
          map <- map %>%
            leaflet::addCircleMarkers(data = route$transfers,
                                      color = drawOptions$transferColour,
                                      radius = drawOptions$transferRadius,
                                      group = group)
        }
      }

    }
  }

  return(map)
}


#' Create Route Popups
#'
#' Function for constructing popups on routes.
#'
#' @param data The route data from which to create the popup.
#' @param transit Whether this is a transit route.
#' @param startEnd Whether to show information on the start and end points.
#'
#' @name route-popup
#'
createRoutePopup <- function(data, transit = FALSE, startEnd = transit) {

  if (transit) {
    header <- ifelse(data$routeType == 1, "UNDERGROUND",
                     ifelse(data$routeType == 2, "TRAIN",
                            ifelse(data$routeType == 3, "BUS",
                                   "PUBLIC TRANSPORT")))
  } else {
    header <- data$travelType
  }

  paste0("<b>", header, "</b></br>",
         if(startEnd) paste0("Start: ", data$startName, "</br>",
                             "End: ", data$endName, "</br>"),
         "Journey time: ", data$travelTime, "s")
}
