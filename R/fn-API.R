
# API Helpers -------------------------------------------------------------

#' Targomo API base URL
#'
targomo_api <- function() {
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
  paste0(targomo_api(), region, "/v1/", end_point)
}



