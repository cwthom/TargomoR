
#' Get Account Capabilities
#'
#' Function to return a list of the capabilities of the API Key. Comes with a print method
#' to print out the main results nicely in the console.
#'
#' @param api_key Your Targomo API key - defaults to the \code{TARGOMO_API_KEY}
#'   ennvironment variable
#' @param region Your Targomo region - defaults to the \code{TARGOMO_REGION}
#'   environment variable
#' @param config Config options to pass to \code{httr::GET} e.g. proxy settings
#' @param verbose Whether to print out information about the API call.
#' @param progress Whether to show a progress bar of the API call.
#'
#' @return A list of the capabilities of the given API key, in the given region
#'
#' @name capabilities
#'
#' @examples
#' \donttest{
#' caps <- getTargomoCapabilities()
#'
#' # print default
#' print.default(caps)
#'
#' # print using bespoke method
#' print(caps)
#' }
#'
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

#' Process Capabilities
#'
#' This function takes the raw JSON list of capabilities and converts then into a formatted list.
#'
#' @param response The API response object
#'
#' @return The formatted list, of class 'tgm_capabilitites'
#'
processCapabilities <- function(response) {

  response <- catchBadResponse(response)
  payload <- httr::content(response)

  payload$general <- tidyGeneral(payload$general)
  payload$transit <- tidyTransit(payload$transit)
  payload$speeds <- tidySpeeds(payload$speeds)

  class(payload) <- c("tgm_capabilities", "list")

  payload
}


#' Helper functions for tidying up capabilities response
#'
#' These functions tidy up the raw capabilities lists.
#'
#' @param general,transit,speeds The parts of the list
#'
#' @return Lists of capabilities (data.frames or vectors)
#'
#' @name tidy-capabilities
NULL

#' @rdname tidy-capabilities
tidyGeneral <- function(general) {

  # unlist where possible
  general <- lapply(general, unlist)

  general
}

#' @rdname tidy-capabilities
tidyTransit <- function(transit) {

  # tidy up transit properties
  transit <- as.data.frame(do.call(rbind, transit))
  transit$property <- rownames(transit)
  rownames(transit) <- NULL
  colnames(transit) <- c("value", "property")
  transit <- transit[, c("property", "value")]

  transit
}

#' @rdname tidy-capabilities
tidySpeeds <- function(speeds) {

  # tidy up osm classes
  osm <- speeds$`osm-classes`
  osm <- as.data.frame(do.call(rbind, osm))
  osm$class <- rownames(osm)
  rownames(osm) <- NULL
  osm <- osm[, c("class", "factor", "speed")]

  # tidy up defaults
  defaults <- speeds[grepl("^default", names(speeds))]
  defaults <- as.data.frame(do.call(rbind, defaults))
  defaults$property <- rownames(defaults)
  colnames(defaults) <- c("value", "property")
  defaults <- defaults[order(defaults$property), c("property", "value")]
  rownames(defaults) <- NULL

  speeds <- list(defaults = defaults, `osm-classes` = osm)

  speeds
}

#' Print Method for Capabilities
#'
#' @param x A list, output of \code{\link{getTargomoCapabilities}}
#' @param ... Further arguments to \code{\link[base]{print}}
#'
#' @rdname capabilities
#'
#' @export
print.tgm_capabilities <- function(x, ...) {

  # print out version
  vn <- x$general$version
  cat(paste0("Targomo Config Version: ", vn, "\n"))

  # print out transit and default speeds
  cat("\nTransit capabilities:\n=========================================\n")
  print(x$transit, ...)
  cat("=========================================\n")

  cat("\nDefault speeds:\n=========================================\n")
  print(x$speeds$defaults, ...)
  cat("=========================================\n")

  invisible(x)
}
