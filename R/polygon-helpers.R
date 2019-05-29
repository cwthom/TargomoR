
# Polygon Service Helpers -------------------------------------------------

#' Create options
#'
#' Function to create options in a nested list structure suitable to be turned into JSON.
#'
#' @param options The output of \code{targomoOptions}.
#'
createPolygonOptions <- function(options) {

  opts <- list()

  opts$edgeWeight <- options$edgeWeight
  opts$elevation <- options$elevation

  opts$polygon <- leaflet::filterNULL(
    list(
      values = options$travelTimes,
      intersectionMode = options$intersectionMode,
      serializer = options$serializer,
      srid = options$srid,
      minPolygonHoleSize = options$minPolygonHoleSize,
      buffer = options$buffer,
      simplify = options$simplify,
      quadrantSegments = options$quadrantSegments,
      decimalPrecision = options$decimalPrecision
    )
  )

  opts$tm <- leaflet::filterNULL(
    list(
      tm = options$travelType,
      car = leaflet::filterNULL(
        list(rushHour = options$carRushHour)
      ),
      walk = leaflet::filterNULL(
        list(speed = options$walkSpeed,
             uphill = options$walkUpHillAdjustment,
             downhill = options$walkDownHillAdjustment)
      ),
      bike = leaflet::filterNULL(
        list(speed = options$bikeSpeed,
             uphill = options$bikeUpHillAdjustment,
             downhill = options$bikeDownHillAdjustment)
      ),
      transit = leaflet::filterNULL(
        list(
          frame = leaflet::filterNULL(
            list(date = options$transitDate,
                 time = options$transitTime,
                 duration = options$transitDuration,
                 maxWalkingTimeFromSource = options$transitMaxWalkingTimeFromSource,
                 maxWalkingTimeToTarget = options$transitMaxWalkingTimeToTarget,
                 earliestArrival = options$transitEarliestArrival)
          ),
          maxTransfers = options$transitMaxTransfers
        )
      )
    )
  )

  return(opts)

}

#' Create Sources
#'
#' Function to create the sources needed to query the Targomo API.
#'
#' @param data The data object
#' @param lat,lng The lat/lng vectors or formulae to resolve
#' @param options A processed options object.
#'
createPolygonSources <- function(data, lat, lng, options) {

  points <- leaflet::derivePoints(data, lng, lat)
  points$id <- seq_along(points$lat)
  sources <- vector(mode = "list", length = nrow(points))

  for (i in points$id) {
    pt <- points[i, ]
    sources[[i]] <- list("id" = pt$id, "lat" = pt$lat, "lng" = pt$lng,
                         "tm" = options$tm[options$tm$tm])
  }

  return(sources)

}

#' Create Request Body
#'
#' Function to create a request body using the sources and options given.
#'
#' @param sources A processed sources object to pass to the API.
#' @param options A processed options list.
#'
createPolygonRequestBody <- function(sources, options) {

  options$sources <- sources
  options <- leaflet::filterNULL(options[c("sources", "polygon",
                                           "edgeWeight", "elevation")])

  body <- jsonlite::toJSON(options, auto_unbox = TRUE, pretty = TRUE)

  return(body)

}

#' Call the Targomo Polygon Service
#'
#' @param api_key The Targomo API key.
#' @param region The Targomo region.
#' @param sources A processed sources object to pass to the API.
#' @param options A processed options list.
#' @param verbose Display info on the API call?
#' @param progress Display a progress bar?
#'
callPolygonService <- function(api_key, region, sources, options,
                               verbose = FALSE, progress = FALSE) {

  url <- createRequestURL(region, "polygon")

  body <- createPolygonRequestBody(sources, options)

  response <- httr::POST(url = url, query = list(key = api_key),
                         body = body, encode = "json",
                         if (verbose) httr::verbose(),
                         if (progress) httr::progress())

  return(response)

}

#' Create Targomo Polygons
#'
#' Function to turn a successful request into polygons.
#'
#' @param response A response object from \code{\link{callPolygonService}}.
#' @param output Either 'sf' or 'geojson'.
#'
processPolygonResponse <- function(response, output = "sf") {

  if (!output %in% c("sf", "geojson")) {
    stop("Invalid output parameter")
  }

  payload <- httr::content(response)

  if (response$status_code == 403) {

    stop(payload)

  } else if (response$status_code == 200) {

    geojson <- jsonlite::toJSON(payload$data, auto_unbox = TRUE)

    if (output == "sf") {
      polygons <- geojsonsf::geojson_sf(geojson)
      polygons <- polygons[order(-polygons$time), ]
      return(polygons)
    } else {
      return(geojson)
    }

  } else {

    stop("Invalid request - check your options and try again.")

  }

}
