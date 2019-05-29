
#' Set Targomo Options
#'
#' This function sets the options to be passed to the API service.
#' For full details of available options see:
#' \url{https://docs.targomo.com/core/#/Polygon_Service/post_westcentraleurope_v1_polygon}
#'
#' @param travelTimes A vector of times, in seconds - each time corresponds to a
#'     different polygon. Your API key will determine how many you can add.
#' @param travelType What mode of transport to use - car, bike, walk or public transport.
#' @param intersectionMode Whether to calculate the union or intersection of multiple sources.
#' @param carRushHour Account for rush hour while driving.
#' @param walkSpeed,walkUpHillAdjustment,walkDownHillAdjustment Settings for walking travel type.
#' @param bikeSpeed,bikeUpHillAdjustment,bikeDownHillAdjustment Settings for cycling travel type.
#' @param transitDate The date for public transport calculations (YYYYMMDD).
#' @param transitTime The time in seconds since midnight to begin transit.
#' @param transitDuration The duration of the transit timeframe (s).
#' @param transitMaxWalkingTimeFromSource,transitMaxWalkingTimeToTarget Settings
#'   for transit travel type.
#' @param transitMaxTransfers,transitEarliestArrival Further transit settings.
#' @param edgeWeight Should calculations be in "time" or "distance"?
#' @param elevation Account for elevation?
#' @param serializer Should be "geojson" or "json". See API for details.
#' @param srid The spatial reference of the returned data.
#' @param minPolygonHoleSize Minimum area of holes in returned polygons.
#' @param simplify,buffer Parameters for manipulating the returned polygons.
#' @param quadrantSegments,decimalPrecision Parameters for fine-tuning the returned polygons.
#'
#' @name targomoOptions
#'
#' @export
targomoOptions = function(travelType = "bike",
                          travelTimes = c(600, 1200, 1800),
                          intersectionMode = "union",
                          carRushHour = FALSE,
                          walkSpeed = 5,
                          walkUpHillAdjustment = 10,
                          walkDownHillAdjustment = 0,
                          bikeSpeed = 15,
                          bikeUpHillAdjustment = 20,
                          bikeDownHillAdjustment = -10,
                          transitDate = NULL,
                          transitTime = NULL,
                          transitDuration = NULL,
                          transitMaxWalkingTimeFromSource = NULL,
                          transitMaxWalkingTimeToTarget = NULL,
                          transitEarliestArrival = FALSE,
                          transitMaxTransfers = NULL,
                          edgeWeight = "time",
                          elevation = FALSE,
                          serializer = "geojson",
                          srid = 4326,
                          minPolygonHoleSize = NULL,
                          buffer = NULL,
                          simplify = NULL,
                          quadrantSegments = NULL,
                          decimalPrecision = NULL) {

  leaflet::filterNULL(
    list(
      travelType = travelType,
      travelTimes = travelTimes,
      intersectionMode = intersectionMode,
      carRushHour = carRushHour,
      walkSpeed = walkSpeed,
      walkUpHillAdjustment = walkUpHillAdjustment,
      walkDownHillAdjustment = walkDownHillAdjustment,
      bikeSpeed = bikeSpeed,
      bikeUpHillAdjustment = bikeUpHillAdjustment,
      bikeDownHillAdjustment = bikeDownHillAdjustment,
      transitDate = transitDate,
      transitTime = transitTime,
      transitDuration = transitDuration,
      transitMaxWalkingTimeFromSource = transitMaxWalkingTimeFromSource,
      transitMaxWalkingTimeToTarget = transitMaxWalkingTimeToTarget,
      transitEarliestArrival = transitEarliestArrival,
      transitMaxTransfers = transitMaxTransfers,
      edgeWeight = edgeWeight,
      elevation = elevation,
      serializer = serializer,
      srid = srid,
      minPolygonHoleSize = minPolygonHoleSize,
      buffer = buffer,
      simplify = simplify,
      quadrantSegments = quadrantSegments,
      decimalPrecision = decimalPrecision
    )
  )

}

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

  options <- createPolygonOptions(options)
  sources <- createPolygonSources(data, lat, lng, options)

  response <- callPolygonService(api_key, region, sources, options,
                                 verbose, progress)

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
                               color = "#03F", opacity = 0.5,
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
