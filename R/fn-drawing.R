
#' Draw Routes
#'
#' Helper functions for drawing different routes.
#'
#' @param map A leaflet map.
#' @param route A route object to draw.
#' @param drawOptions Drawing options provided by \code{\link{routeDrawOptions}}.
#' @param type What route type to draw.
#' @param ... Further arguments to pass to leaflet functions.
#'
#' @name draw
#'
drawRoute <- function(map, route, drawOptions, type, ...) {

  drawOpts <- drawOptions[paste0(type, c("Colour", "Weight", "DashArray"))]
  names(drawOpts) <- c("colour", "weight", "dashArray")


  leaflet::addPolylines(map = map,
                        data = route,
                        color = drawOpts$colour, weight = drawOpts$weight,
                        dashArray = drawOpts$dashArray,
                        label = "Click for more information",
                        popup = createRoutePopup(route, transit = {type == "transit"}),
                        ...)

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
