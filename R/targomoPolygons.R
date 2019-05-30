
#' Get Targomo Polygons
#'
#' @rdname addTargomoPolygons
#' @export
getTargomoPolygons <- function(api_key = Sys.getenv("TARGOMO_API_KEY"),
                               region = Sys.getenv("TARGOMO_REGION"),
                               data = NULL, lat = NULL, lng = NULL,
                               options = targomoOptions(),
                               sf = TRUE,
                               verbose = FALSE,
                               progress = FALSE) {

  options <- deriveOptions(options)
  sources <- deriveSources(data, lat, lng, options)

  response <- callTargomoAPI(api_key = api_key, region = region, service = "polygon",
                             sources = sources, options = options,
                             verbose = verbose, progress = progress)

  output <- processPolygonResponse(response, output = if (sf) "sf" else "geojson")

  return(output)

}

#' Add Targomo Polygons to Leaflet Map
#'
#' Function for adding targomo polygons to a leaflet map - uses \link[leaflet]{addPolygons}
#' as a workhorse function, and adds the polygons as an sf object.
#'
#' @param map A leaflet map.
#' @param api_key Your Targomo API key - defaults to the \code{TARGOMO_API_KEY} env var.
#' @param region Your Targomo region - defaults to the \code{TARGOMO_REGION} env var.
#' @param data The data object from which arguments are derived.
#' @param lng,lat Vectors/one-sided formulas of longitude and latitude.
#' @param options A list of \code{\link{targomoOptions}} to call the API.
#' @param sf Logical - return an sf object?
#' @param verbose Logical - show the API call?
#' @param progress Logical - show a progress bar for the API call?
#' @param layerId The layer ID.
#' @param group The layer group.
#' @param stroke Should the borders be drawn?
#' @param weight Stroke width in pixels.
#' @param color Stroke color.
#' @param opacity Stroke opacity.
#' @param fill Should the polygons be filled with colour?
#' @param fillColor The fill colour.
#' @param fillOpacity The fill opacity.
#' @param dashArray A string to define the stroke dash pattern.
#' @param smoothFactor How much to simplify polylines on each zoom level.
#' @param noClip Whether to disable polyline clipping.
#' @param popup HTML content for the popup.
#' @param popupOptions A list of \code{\link[leaflet]{popupOptions}}.
#' @param label A character vector of labels.
#' @param labelOptions A list of \code{\link[leaflet]{labelOptions}}.
#' @param pathOptions Options for the path.
#' @param highlightOptions A list of \code{\link[leaflet]{highlightOptions}}.
#' @param ... Further options to pass to \code{\link{getTargomoPolygons}} e.g. verbose.
#'
#' @export
addTargomoPolygons <- function(map,
                               api_key = Sys.getenv("TARGOMO_API_KEY"),
                               region = Sys.getenv("TARGOMO_REGION"),
                               lng = NULL, lat = NULL,
                               options = targomoOptions(),
                               layerId = NULL, group = NULL,
                               stroke = TRUE, weight = 5,
                               color = c("red", "orange", "green"), opacity = 0.5,
                               fill = TRUE, fillColor = color, fillOpacity = 0.2,
                               dashArray = NULL, smoothFactor = 1, noClip = FALSE,
                               popup = NULL, popupOptions = NULL,
                               label = NULL, labelOptions = NULL,
                               pathOptions = leaflet::pathOptions(),
                               highlightOptions = NULL,
                               data = leaflet::getMapData(map),
                               ...) {

  polygons <- getTargomoPolygons(api_key = api_key, region = region,
                                 data = data, lat = lat, lng = lng,
                                 options = options, sf = TRUE, ...)

  leaflet::addPolygons(map, data = polygons, layerId = layerId, group = group,
                       stroke = stroke, weight = weight, color = color,
                       opacity = opacity, fill = fill, fillColor = fillColor,
                       fillOpacity = fillOpacity, dashArray = dashArray,
                       smoothFactor = smoothFactor, noClip = noClip,
                       popup = popup, popupOptions = popupOptions,
                       label = label, labelOptions = labelOptions,
                       options = pathOptions, highlightOptions = highlightOptions)

}
