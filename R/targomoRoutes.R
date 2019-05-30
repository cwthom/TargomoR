#' Get Targomo Routes
#'
#' @rdname addTargomoRoutes
#' @export
getTargomoRoutes <- function(api_key = Sys.getenv("TARGOMO_API_KEY"),
                             region = Sys.getenv("TARGOMO_REGION"),
                             source_data = NULL, source_lat = NULL, source_lng = NULL,
                             target_data = NULL, target_lat = NULL, target_lng = NULL,
                             options = targomoOptions(),
                             verbose = FALSE,
                             progress = FALSE) {

  options <- deriveOptions(options)
  sources <- deriveSources(source_data, source_lat, source_lng, options)
  targets <- deriveTargets(target_data, target_lat, target_lng)

  response <- callTargomoAPI(api_key = api_key, region = region, service = "route",
                             sources = sources, targets = targets, options = options,
                             verbose = verbose, progress = progress)

  output <- processResponse(response, service = "route")

  return(output)

}
