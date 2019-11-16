
#' Process API responses
#'
#' Functions to turn a successful request into data - either polygons, routes or times.
#'
#' @param response A response object from \code{\link{callTargomoAPI}}.
#' @param service The Targomo API service being called - polygon, route or time.
#' @param payload The \code{httr::content} of the response.
#' @param route A single element of the returned routes list.
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
  polygons <- sf::st_sf(polygons, crs = sf::st_crs(4326)) # not sure why this is 100% necessary, but seems to be...
  return(polygons)

}

#' @rdname process
getRouteFeatures <- function(route) {

  geojson <- jsonlite::toJSON(route, auto_unbox = TRUE)
  features <- geojsonsf::geojson_sf(geojson)

  suppressWarnings(sf::st_crs(features) <- sf::st_crs(3857))
  features <- sf::st_transform(features, crs = sf::st_crs(4326)) %>%
    sf::st_zm(drop = TRUE)

  features

}

#' @rdname process
processRoutes <- function(payload) {

  errors <- payload$errors
  routes <- payload$data$routes

  lapply(routes, function(route) {

    tibble::tibble(sourceId = route$sourceId,
                   targetId = route$targetId,
                   features = getRouteFeatures(route))

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
