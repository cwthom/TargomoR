#' Add Targomo Polygons to a Leaflet Map
#'
#' Function for adding targomo polygons to a leaflet map - uses \link[leaflet]{addPolygons}
#' as a workhorse function, and adds the polygons as an sf object.
#'
#' @param map A leaflet map.
#' @param source_data The data object from which source ppoints are derived.
#' @param source_lng,source_lat Vectors/one-sided formulas of longitude and latitude.
#' @param options A list of \code{\link{targomoOptions}} to call the API.
#' @param drawOptions A list of \code{\link{polygonDrawOptions}} to determine how to show
#'   the resulting polygons on the map.
#' @param highlightOptions A list of \code{\link[leaflet]{highlightOptions}}.
#' @param group The leaflet map group to add the polygons to. A single group is used
#'   for all the polygons added by one API call.
#' @param api_key Your Targomo API key - defaults to the \code{TARGOMO_API_KEY}
#'   ennvironment variable
#' @param region Your Targomo region - defaults to the \code{TARGOMO_REGION}
#'   environment variable
#' @param config Config options to pass to \code{httr::POST} e.g. proxy settings
#' @param verbose Whether to print out information about the API call.
#' @param progress Whether to show a progress bar of the API call.
#'
#' @name polygon
#'
NULL

#' @rdname polygon
#' @export
getTargomoPolygons <- function(source_data = NULL, source_lat = NULL, source_lng = NULL,
                               options = targomoOptions(),
                               api_key = Sys.getenv("TARGOMO_API_KEY"),
                               region = Sys.getenv("TARGOMO_REGION"),
                               config = list(),
                               verbose = FALSE,
                               progress = FALSE) {

  s_points <- createPoints(source_data, source_lat, source_lng, NULL)

  options <- deriveOptions(options)
  sources <- deriveSources(s_points, options)
  body <- createRequestBody("polygon", sources, NULL, options)

  response <- callTargomoAPI(api_key = api_key, region = region,
                             service = "polygon", body = body,
                             config = config,
                             verbose = verbose, progress = progress)

  output <- processResponse(response, service = "polygon")

  return(output)

}

#' @rdname polygon
#' @export
addTargomoPolygons <- function(map,
                               source_data = NULL, source_lng = NULL, source_lat = NULL,
                               options = targomoOptions(),
                               drawOptions = polygonDrawOptions(),
                               highlightOptions = NULL,
                               group = NULL,
                               api_key = Sys.getenv("TARGOMO_API_KEY"),
                               region = Sys.getenv("TARGOMO_REGION"),
                               config = list(),
                               verbose = FALSE,
                               progress = FALSE) {

  opts <- drawOptions

  polygons <- getTargomoPolygons(api_key = api_key, region = region,
                                 source_data = source_data,
                                 source_lat = source_lat, source_lng = source_lng,
                                 options = options, config = config,
                                 verbose = verbose, progress = progress)

  leaflet::addPolygons(map, data = polygons, group = group,
                       stroke = opts$stroke, weight = opts$weight,
                       color = opts$color, opacity = opts$opacity,
                       fill = opts$fill, fillColor = opts$fillColor,
                       fillOpacity = opts$fillOpacity, dashArray = opts$dashArray,
                       smoothFactor = opts$smoothFactor, noClip = opts$noClip)

}

#' Options for Drawing Polygons on the Map
#'
#' Function to return a list of the desired drawing options - you can set all the usual
#' parameters of a call to \code{\link[leaflet]{addPolygons}}.
#'
#' @param stroke Whether to draw the polygon borders.
#' @param weight Stroke width in pixels.
#' @param color Stroke colour.
#' @param opacity Stroke opacity.
#' @param fill Whether to fill the polygons in with colour.
#' @param fillColor The fill colour.
#' @param fillOpacity The fill opacity.
#' @param dashArray A string to define the stroke dash pattern.
#' @param smoothFactor How much to simplify polylines on each zoom level.
#' @param noClip Whether to disable polyline clipping.
#'
#' @export
polygonDrawOptions <- function(stroke = TRUE,
                               weight = 5,
                               color = c("red", "orange", "green"),
                               opacity = 0.5,
                               fill = TRUE,
                               fillColor = color,
                               fillOpacity = 0.2,
                               dashArray = NULL,
                               smoothFactor = 1,
                               noClip = FALSE) {

  leaflet::filterNULL(
    list(
      stroke = stroke,
      weight = weight,
      color = color,
      opacity = opacity,
      fill = fill,
      fillColor = fillColor,
      fillOpacity = fillOpacity,
      dashArray = dashArray,
      smoothFactor = smoothFactor,
      noClip = noClip
    )
  )
}