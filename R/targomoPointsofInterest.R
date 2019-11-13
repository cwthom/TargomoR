#' Add Targomo Points of Interest to a Leaflet Map
#'
#' Function for adding targomo points of interest to a leaflet map.
#'
#' @param map A leaflet map.
#' @param source_data The data object from which source ppoints are derived.
#' @param source_lng,source_lat Vectors/one-sided formulas of longitude and latitude.
#' @param options A list of \code{\link{targomoOptions}} to call the API.
#' @param group The leaflet map group to add the points to. A single group is used
#'   for all the points added by one API call.
#' @param api_key Your Targomo API key - defaults to the \code{TARGOMO_API_KEY}
#'   ennvironment variable
#' @param region Your Targomo region - defaults to the \code{TARGOMO_REGION}
#'   environment variable
#' @param config Config options to pass to \code{httr::POST} e.g. proxy settings
#' @param verbose Whether to print out information about the API call.
#' @param progress Whether to show a progress bar of the API call.
#'
#' @name points-of-interest
#'
NULL

#' @rdname points-of-interest
translatePOIs <- function(keyvalues) {

  keyvalues <- gsub("\\s", "", keyvalues)

  rgx <- "^(.*)=(.*)$"
  keys <- gsub(rgx, "\\1", keyvalues)
  vals <- gsub(rgx, "\\2", keyvalues)

  outlist <- mapply(function(k, v) {
    list("key" = k, "value" = v)
  }, keys, vals, SIMPLIFY = FALSE)

  unname(outlist)

}

#' @rdname points-of-interest
#' @export
getTargomoPOIs <- function(source_data = NULL, source_lat = NULL, source_lng = NULL,
                           options = targomoOptions(),
                           api_key = Sys.getenv("TARGOMO_API_KEY"),
                           region = Sys.getenv("TARGOMO_REGION"),
                           config = list(),
                           verbose = FALSE,
                           progress = FALSE) {

  s_points <- createPoints(source_data, source_lat, source_lng, NULL)

  options <- deriveOptions(options)
  sources <- deriveSources(s_points, options)
  body <- createRequestBody("poi", sources, NULL, options,
                            api_key = api_key, region = region)

  response <- callTargomoAPI(api_key = api_key, region = region,
                             service = "poi", body = body,
                             config = config,
                             verbose = verbose, progress = progress)

  output <- processResponse(response, service = "poi")

  return(output)

}
