
#' Get Account Capabilities
#'
#' Function to return a list of the capabilities of the API Key. Currently this
#' doesn't do any nice formatting of the output, but just returns a nested list.
#'
#' @param api_key Your Targomo API key - defaults to the \code{TARGOMO_API_KEY}
#'   ennvironment variable
#' @param region Your Targomo region - defaults to the \code{TARGOMO_REGION}
#'   environment variable
#' @param config Config options to pass to \code{httr::GET} e.g. proxy settings
#' @param response The API response object
#' @param verbose Whether to print out information about the API call.
#' @param progress Whether to show a progress bar of the API call.
#'
#' @name capabilities
#'
NULL

#' @rdname capabilities
#' @export
getTargomoCapabilities <- function(api_key = Sys.getenv("TARGOMO_API_KEY"),
                                   region = Sys.getenv("TARGOMO_REGION"),
                                   config = list(),
                                   verbose = FALSE,
                                   progress = FALSE) {

  url <- createRequestURL(region, "metadata/network")

  response <- httr::GET(url = url, config = config,
                        query = list(key = api_key),
                        if (verbose) httr::verbose(),
                        if (progress) httr::progress())

  output <- processCapabilities(response)

  output

}

#' @rdname capabilities
processCapabilities <- function(response) {

  response <- catchBadResponse(response)
  payload <- httr::content(response)

  payload
}
