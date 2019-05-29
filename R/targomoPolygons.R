#' Targomo API base URL
#'
targomo_api <- function() {
  return("https://api.targomo.com/")
}

#' Create Request URL
#'
#' Function to create the request URL
#'
createRequestURL <- function(region, end_point) {
  paste0(targomo_api(), region, "/v1/", end_point)
}


#' Create Sources
#'
#' Function to create the sources needed to query the Targomo API.
#'
createSources <- function(data, lat, lng, travelType) {

  points <- leaflet::derivePoints(data, lng, lat)
  points$id <- seq_along(points$lat)
  sources <- vector(mode = "list", length = nrow(points))

  tm <- list(c())
  names(tm) <- travelType

  for (i in points$id) {
    pt <- points[i, ]
    sources[[i]] <- list("id" = pt$id, "lat" = pt$lat, "lng" = pt$lng,
                         "tm" = tm)
  }

  return(sources)

}

#' Create Request Body
#'
#' Function to create a request body using the sources and options given
createRequestBody <- function(sources, options) {

  options$sources <- sources
  options <- leaflet::filterNULL(options[c("sources", "edgeWeight", "polygon")])

  jsonlite::toJSON(options, auto_unbox = TRUE, pretty = TRUE)

}

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
getTargomoPolygons <- function(api_key = Sys.getenv("TARGOMO_API_KEY"),
                               region = Sys.getenv("TARGOMO_REGION"),
                               data = NULL, lat = NULL, lng = NULL,
                               options = targomoOptions(),
                               ...) {

  url <- createRequestURL(region, "polygon")

  sources <- createSources(data, lat, lng, options$travelType)

  body <- createRequestBody(sources, options)

  resp <- httr::POST(url = url, query = list(key = api_key),
                     body = body, encode = "json",
                     httr::verbose())

  payload <- httr::content(resp)

  # TODO: add error trapping here

  geojson <- jsonlite::toJSON(payload$data, auto_unbox = TRUE)

  polygons <- geojsonsf::geojson_sf(geojson)

  return(polygons)

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
                          simplify = 0,
                          ...) {

  leaflet::filterNULL(
    list(
      edgeWeight = "time",
      polygon = list(
        values = travelTimes,
        intersectionMode = intersectionMode,
        serializer = serializer,
        srid = srid
      ),
      travelType = travelType,
      ...
    )
  )

}

