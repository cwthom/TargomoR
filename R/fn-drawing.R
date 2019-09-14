
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

      features <- route$features

      if (drawOptions$showMarkers) {

        src <- features[!is.na(features$sourceId), ]
        trg <- features[!is.na(features$targetId), ]

        map <- map %>%
          leaflet::addMarkers(data = src, label = ~paste("Source:", sourceId),
                              group = group) %>%
          leaflet::addMarkers(data = trg, label = ~paste("Target:", targetId),
                              group = group)

      }

      if (tm %in% c("car", "bike", "walk")) {

        segment <- features[sf::st_is(features$geometry, "LINESTRING"), ]

        map <- map %>%
          drawRouteSegment(segment = segment, drawOptions = drawOptions,
                           type = tm, group = group, ...)

      } else if (tm %in% "transit") {

        segments <- features[sf::st_is(features$geometry, "LINESTRING"), ]
        walk <- segments[is.na(features$isTransit), ]
        transit <- segments[!is.na(features$isTransit), ]

        map <- map %>%
          drawWalk(segment = walk, drawOptions = drawOptions, group = group, ...) %>%
          drawTransit(segment = transit, drawOptions = drawOptions, group = group, ...)

      }

      if (tm == "transit" && drawOptions$showTransfers) {

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

#' Create a Colour Palette for Time Service Results
#'
#' @param palette A colour palette e.g. "viridis", "Blues"
#' @param type Either "numeric" or "bin"
#' @param maxTime The maximum time value to consider
#' @param bins Either a single number of bins, or a vector of cut points.
#' @param reverse Whether to reverse the colour palette.
#'
createTimePalette <- function(palette, type, maxTime, bins, reverse) {

  if (!(type %in% c("numeric", "bin"))) {
    stop("Invalid 'type': ", deparse(type))
  }

  if (type == "numeric") {
    leaflet::colorNumeric(palette = palette,
                          domain = c(0, maxTime),
                          na.color = NA,
                          reverse = reverse)
  } else if (type == "bin") {
    leaflet::colorBin(palette = palette,
                      domain = c(0, maxTime),
                      bins = bins,
                      na.color = NA,
                      reverse = reverse)

  }

}
