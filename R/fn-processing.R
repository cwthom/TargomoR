
#' Process API responses
#'
#' Functions to turn a successful request into data - either polygons, routes or times.
#'
#' @param response A response object from \code{\link{callTargomoAPI}}.
#' @param service The Targomo API service being called - polygon, route or time.
#' @param payload The \code{httr::content} of the response.
#' @param route A single element of the returned routes list.
#' @param feature A route feature to extract (e.g. car sections, bike sections...)
#'
#' @name process
NULL

#' @rdname process
catchBadResponse <- function(response) {

  status <- response$status_code

  if (status %in% c(401, 403, 404)) {
    stop(httr::content(response))
    return(invisible(NULL))
  } else if (status == 400) {
    stop(status, " - Bad Request. Check your settings and try again.")
    return(invisible(NULL))
  } else if (grepl("^5", status)) {
    stop(status, " - Server-side error.")
    return(invisible(NULL))
  } else if (status != 200) {
    stop(status, " - unknown error.")
    return(invisible(NULL))
  } else {
    return(response)
  }

}

#' @rdname process
processResponse <- function(response, service) {

  response <- catchBadResponse(response)
  payload <- httr::content(response)

  if (service == "polygon") {
    output <- processPolygons(payload)
  } else if (service == "route") {
    output <- processRoutes(payload)
  } else if (service == "time") {
    output <- processTimes(payload)
  }

  return(output)

}

#' @rdname process
processPolygons <- function(payload) {

  geojson <- jsonlite::toJSON(payload$data, auto_unbox = TRUE)
  polygons <- geojsonsf::geojson_sf(geojson)
  polygons <- polygons[order(-polygons$time), ]
  return(polygons)

}

#' @rdname process
getRouteFeature <- function(route, feature) {

  geojson <- jsonlite::toJSON(route, auto_unbox = TRUE)
  features <- geojsonsf::geojson_sf(geojson)

  suppressWarnings(sf::st_crs(features) <- sf::st_crs(3857))
  features <- sf::st_transform(features, crs = sf::st_crs(4326)) %>%
    sf::st_zm(drop = TRUE)

  index <- if (feature == "POINT") {
    is.na(features$travelType)
  } else {
    features$travelType %in% feature
  }

  features[index, ]

}

#' @rdname process
processRoutes <- function(payload) {

  errors <- payload$errors
  routes <- payload$data$routes

  lapply(routes, function(route) {

    x <- list(points = getRouteFeature(route, "POINT"),
              transit = getRouteFeature(route, "TRANSIT"),
              walk = getRouteFeature(route, "WALK"),
              bike = getRouteFeature(route, "BIKE"),
              car  = getRouteFeature(route, "CAR"),
              transfers = suppressWarnings({
                getRouteFeature(route, "TRANSFER") %>%
                  sf::st_cast(to = "POINT") %>%
                  unique()
                })
    )
    Filter(function(x) nrow(x) > 0, x)
  })

}

#' @rdname process
processTimes <- function(payload) {

  sets <- lapply(payload$data, function(set) {
    set <- data.frame(set$id, matrix(unlist(set$targets),
                                     nrow=length(set$targets),
                                     byrow=T),
                      stringsAsFactors = FALSE)
    colnames(set) <- c("sourceId", "targetId", "travelTime")
    set$travelTime <- as.integer(set$travelTime)
    set
  })
  do.call(rbind, sets)

}
