
#' Add Targomo Attributions
#'
#' Functions providing link to Targomo Attributions page, depending on plan.
#'
#' @param map A leaflet map
#' @param free_plan Logical - is the Targomo plan you're using free or paid?
#' @param ... Further arguments to pass to \code{leaflet::addControl} e.g. position
#'
#' @return A link or iframe to the attributions page.
#'
#' @name attribution
NULL

#' @rdname attribution
attributionFreeIframe <- function() {
  "<iframe src='https://targomo.com/developers/default_attribution/free' width='280' height='100'></iframe>"
}

#' @rdname attribution
attributionOtherIframe <- function() {
  "<iframe src='https://targomo.com/developers/default_attribution/other' width='280' height='40'></iframe>"
}

#' @rdname attribution
#' @export
attributionLink <- function() {
  "https://targomo.com/developers/resources/attribution/"
}

#' @rdname attribution
#' @export
addTargomoAttribution <- function(map, free_plan = TRUE, ...) {
  leaflet::addControl(
    map,
    html = ifelse(free_plan,
                  attributionFreeIframe(),
                  attributionOtherIframe()),
    ...
  )
}




