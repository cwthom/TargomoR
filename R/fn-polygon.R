
# Polygon Service Helpers -------------------------------------------------

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
