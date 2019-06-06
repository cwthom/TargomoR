#' Add Targomo Times to a Leaflet Map
#'
#' This function takes source and target data, together with options for the API and
#' drawing options, and returns the map with the requested travel time data.
#'
#' @param map A leaflet map
#' @param source_data,target_data The source and target points for your travel times -
#'   supported types are data.frame matrix and objects from the sf and sp packages.
#' @param source_lat,source_lng One-sided formulas identifying the latitude
#'   and longitude columns in your source data, or numeric vectors of equal length.
#' @param target_lat,target_lng As for \code{source_lat,source_lng} but for target data.
#' @param source_id,target_id Formulas or vectors of IDs to give to your source and target points.
#'   These will be used to match back to the input data if applicable.
#' @param options A list of \code{\link{targomoOptions}} to send to the API.
#' @param drawOptions A list of \code{\link{timeDrawOptions}} to determine how to show
#'   the resulting times on the map.
#' @param group The leaflet map group to add the times to. One group is used for all
#'   map elements being drawn per call to the API.
#' @param api_key Your Targomo API key - defaults to the \code{TARGOMO_API_KEY}
#'   ennvironment variable.
#' @param region Your Targomo region - defaults to the \code{TARGOMO_REGION}
#'   environment variable.
#' @param verbose Whether to print out information about the API call.
#' @param progress Whether to show a progress bar of the API call.
#'
#' @name times
#'
NULL

#' @rdname times
#' @export
getTargomoTimes <- function(source_data = NULL, source_lat = NULL, source_lng = NULL,
                            target_data = NULL, target_lat = NULL, target_lng = NULL,
                            source_id = NULL, target_id = NULL,
                            options = targomoOptions(),
                            api_key = Sys.getenv("TARGOMO_API_KEY"),
                            region = Sys.getenv("TARGOMO_REGION"),
                            verbose = FALSE,
                            progress = FALSE) {

  if (length(options$travelType) > 1) {
    output <- list()
    message("Multiple (", length(options$travelType), ") travel types supplied - treating each in turn.\n",
            "This will make ", length(options$travelType), " calls to the API.")
    for (tm in options$travelType) {
      options$travelType <- tm
      output[[tm]] <- getTargomoTimes(source_data, source_lat, source_lng,
                                      target_data, target_lat, target_lng,
                                      source_id, target_id,
                                      options,  api_key, region,
                                      verbose, progress)
    }
    output <- do.call(rbind, output)
    return(output)
  }

  options <- deriveOptions(options)
  sources <- deriveSources(source_data, source_lat, source_lng, source_id, options)
  targets <- deriveTargets(target_data, target_lat, target_lng, target_id)
  body <- createRequestBody("time", sources, targets, options)

  response <- callTargomoAPI(api_key = api_key, region = region,
                             service = "time", body = body,
                             verbose = verbose, progress = progress)

  output <- processResponse(response, service = "time")
  output$travelType <- options$tm$tm

  output <- tibble::as_tibble(output)

  return(output)

}


#' @rdname times
#' @export
addTargomoTimes <- function(map,
                            source_data = NULL, source_lat = NULL, source_lng = NULL,
                            target_data = NULL, target_lat = NULL, target_lng = NULL,
                            source_id = NULL, target_id = NULL,
                            options = targomoOptions(),
                            drawOptions = timeDrawOptions(),
                            group = NULL,
                            api_key = Sys.getenv("TARGOMO_API_KEY"),
                            region = Sys.getenv("TARGOMO_REGION"),
                            verbose = FALSE, progress = FALSE) {


  times <- getTargomoTimes(api_key = api_key, region = region,
                           source_data = source_data, source_lat = source_lat,
                           source_lng = source_lng, target_data = target_data,
                           target_lat = target_lat, target_lng = target_lng,
                           source_id = source_id, target_id = target_id,
                           options = options,
                           verbose = verbose, progress = progress)


}

#' Options for Drawing Times on the Map
#'
#' Function to return a list of the desired drawing options.
#'
#'
#' @export
timeDrawOptions <- function() {

  leaflet::filterNULL(
    list()
  )

}
