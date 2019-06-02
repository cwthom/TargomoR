
# API Helpers -------------------------------------------------------------

#' Targomo API base URL
#'
targomoAPI <- function() {
  return("https://api.targomo.com/")
}

#' Create Request URL
#'
#' Function to create the request URL.
#'
#' @param region The Targomo region.
#' @param end_point The API end_point.
#'
createRequestURL <- function(region, end_point) {
  paste0(targomoAPI(), region, "/v1/", end_point)
}


#' Derive Options
#'
#' Function to create options in a nested list structure suitable to be turned into JSON.
#'
#' @param options The output of \code{\link{targomoOptions}}.
#'
deriveOptions <- function(options) {

  opts <- list()

  opts$edgeWeight <- options$edgeWeight
  opts$maxEdgeWeight <- options$maxEdgeWeight
  opts$elevation <- options$elevation
  opts$pathSerializer <- options$serializer

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

  opts <- leaflet::filterNULL(opts)

  return(opts)

}


#' Derive Sources/Targets
#'
#' Function to create the sources needed to query the Targomo API.
#'
#' @param data The data object
#' @param lat,lng The lat/lng vectors or formulae to resolve
#' @param options A processed options object (for sources).
#'
#' @name deriveSources
NULL

#' @rdname deriveSources
deriveSources <- function(data, lat= NULL, lng = NULL, options) {

  points <- leaflet::derivePoints(data, lng, lat, is.null(lng), is.null(lat))
  points$id <- seq_along(points$lat)
  sources <- vector(mode = "list", length = nrow(points))

  for (i in points$id) {
    pt <- points[i, ]
    sources[[i]] <- list("id" = pt$id, "lat" = pt$lat, "lng" = pt$lng,
                         "tm" = options$tm[options$tm$tm])
  }

  return(sources)

}

#' @rdname deriveSources
deriveTargets <- function(data, lat = NULL, lng = NULL) {

  points <- leaflet::derivePoints(data, lng, lat, is.null(lng), is.null(lat))
  points$id <- seq_along(points$lat)
  targets <- vector(mode = "list", length = nrow(points))

  for (i in points$id) {
    pt <- points[i, ]
    targets[[i]] <- list("id" = pt$id, "lat" = pt$lat, "lng" = pt$lng)
  }

  return(targets)

}

#' Create Request Body
#'
#' Function to create a request body using the sources and options given.
#'
#' @param service The Targomo Service to create a body for - 'polygon', 'time', 'route'.
#' @param sources A processed sources object to pass to the API.
#' @param targets A processed targets object (optional).
#' @param options A processed options list.
#'
createRequestBody <- function(service, sources = NULL, targets = NULL, options) {

  if (is.null(service)) {
    stop("No Targomo service specified")
  }

  if (is.null(sources)) {
    stop("No source data provided")
  }

  core_opts <- c("edgeWeight", "maxEdgeWeight", "elevation", "sources", "targets")
  if (service == "polygon") {
    service_opts <- "polygon"
  } else if (service == "route") {
    service_opts <- "pathSerializer"
  } else {
    service_opts <- NULL
  }

  options$sources <- sources
  options$targets <- targets
  options <- leaflet::filterNULL(options[c(core_opts, service_opts)])

  body <- jsonlite::toJSON(options, auto_unbox = TRUE, pretty = TRUE)

  return(body)

}

#' Call the Targomo API
#'
#' @param api_key The Targomo API key.
#' @param region The Targomo region.
#' @param service The Targomo service - 'polygon', 'route', or 'time'.
#' @param sources A processed sources object to pass to the API.
#' @param targets A processed targets object (optional).
#' @param options A processed options list.
#' @param verbose Display info on the API call?
#' @param progress Display a progress bar?
#'
callTargomoAPI <- function(api_key = Sys.getenv("TARGOMO_API_KEY"),
                           region = Sys.getenv("TARGOMO_REGION"),
                           service,
                           sources, targets = NULL, options,
                           verbose = FALSE, progress = FALSE) {

  url <- createRequestURL(region, service)
  body <- createRequestBody(service, sources, targets, options)

  response <- httr::POST(url = url, query = list(key = api_key),
                         body = body, encode = "json",
                         if (verbose) httr::verbose(),
                         if (progress) httr::progress())

  return(response)

}


