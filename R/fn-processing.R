
#' Process API responses
#'
#' Functions to turn a successful request into data - either polygons, routes or times.
#'
#' @param response A response object from \code{\link{callPolygonService}}.
#' @param service The Targomo API service being called - polygon, route or time.
#'
#' @name processResponse
NULL

#' @rdname processResponse
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

#' @rdname processResponse
processResponse <- function(response, service) {

  response <- catchBadResponse(response)
  payload <- httr::content(response)

  if (service == "polygon") {
    output <- processPolygons(payload)
  } else if (service == "route") {
    output <- processRoutes(payload)
  } else if (service == "time") {
    output <- processTime(payload)
  }

  return(output)

}

#' @rdname processResponse
processPolygons <- function(payload) {

  geojson <- jsonlite::toJSON(payload$data, auto_unbox = TRUE)
  polygons <- geojsonsf::geojson_sf(geojson)
  polygons <- polygons[order(-polygons$time), ]
  return(polygons)

}

#' @rdname processResponse
processRoutes <- function(payload) {

  errors <- payload$errors
  routes <- payload$data$routes
  lapply(routes, function(route) {
    geojson <- jsonlite::toJSON(route, auto_unbox = TRUE)
    features <- geojsonsf::geojson_sf(geojson)
    lines <- features[!is.na(features$length), ] %>% sf::st_zm(drop = TRUE)
    suppressWarnings(sf::st_crs(lines) <- sf::st_crs(3857))
    lines <- sf::st_transform(lines, crs = sf::st_crs(4326))
  })

}

#' @rdname processResponse
processTime <- function(payload) {

  sets <- payload$data
  lapply(sets, function(set) {
    as.data.frame(do.call(rbind, set$targets))
  })
}
