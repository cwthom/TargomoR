#' Targomo API base URL
#'
targomo_api <- function() {
  return("https://api.targomo.com/")
}

#' TODO: add function to create a source object, so that it can be mapped over
#' the rows of the output of leaflet::derivePoints.

#' Get Targomo Polygon GeoJSON data
#'
#' Function to call the Targomo API and return geojson.
#'
#' @param api_key
#' @param region
#' @param data
#' @param lat,lng
#' @param options
#' @param ...
#'
#' @export
getTargomoGeoJSON <- function(api_key = Sys.getenv("TARGOMO_API_KEY"),
                              region = Sys.getenv("TARGOMO_REGION"),
                              data = NULL, lat = NULL, lng = NULL,
                              options = targomoOptions(),
                              ...) {

  url <- paste0(targomo_api(), region, "/v1/polygon?key=", api_key)
  auth <- httr::add_headers(key = api_key)

  sources <- list("id" = seq_along(lat), "lat" = lat, "lng" = lng,
                  "tm" = list("bike" = c()))
  options$sources <- list(sources)
  body <- jsonlite::toJSON(options, auto_unbox = TRUE, pretty = TRUE)

  resp <- httr::POST(url = url, body = body, httr::verbose(), encode = "json",
                     httr::add_headers("Content-Type" = "application/json"))

  return(resp)

}



#' Set Targomo Options
#'
#' This function sets the options to be passed to the API service.
#'
#' @param travelTimes A vector of times, in seconds - each time corresponds to a
#'     different polygon. Your API key will determine how many you can add.
#' @param travelType What mode of transport to use - car, bike, walk or public transport.
#' @param intersectionMode Whether to calculate the union or intersection of multiple sources
#' @param ... Further arguments to pass to the API - see \url{https://docs.targomo.com/core/#/Polygon_Service/post_westcentraleurope_v1_polygon}
#'
#' @name targomoOptions
#'
#' @export
targomoOptions = function(travelTimes = c(600, 1200, 1800),
                          travelType = "bike",
                          intersectionMode = "union",
                          serializer = "geojson",
                          srid = 4326,
                          ...) {

  leaflet::filterNULL(
    list(
      edgeWeight = "time",
      polygon = list(
        values = travelTimes,
        intersectionMode = intersectionMode,
        serializer = serializer
      ),
      travelType = travelType,
      srid = srid,
      ...
    )
  )

}

