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
#' @param times A times dataset returned by \code{getTargomoTimes}
#' @param drawOptions A list of \code{\link{timeDrawOptions}} to determine how to show
#'   the resulting times on the map.
#' @param group The leaflet map group to add the times to. One group is used for all
#'   map elements being drawn per call to the API.
#' @param ... Further arguments to pass to \code{\link[leaflet]{addCircleMarkers}}
#' @param api_key Your Targomo API key - defaults to the \code{TARGOMO_API_KEY}
#'   ennvironment variable.
#' @param region Your Targomo region - defaults to the \code{TARGOMO_REGION}
#'   environment variable.
#' @param config Config options to pass to \code{httr::POST} e.g. proxy settings
#' @param verbose Whether to print out information about the API call.
#' @param progress Whether to show a progress bar of the API call.
#' @param timeout Timeout in seconds (leave NULL for no timeout/curl default).
#'
#' @name getTargomoTimes
#'
NULL

#' @rdname getTargomoTimes
#' @export
getTargomoTimes <- function(source_data = NULL, source_lat = NULL, source_lng = NULL,
                            target_data = NULL, target_lat = NULL, target_lng = NULL,
                            source_id = NULL, target_id = NULL,
                            options = targomoOptions(),
                            api_key = Sys.getenv("TARGOMO_API_KEY"),
                            region = Sys.getenv("TARGOMO_REGION"),
                            config = list(),
                            verbose = FALSE,
                            progress = FALSE,
                            timeout = NULL) {

  output <- list()
  tms <- options$travelType

  s_points <- createPoints(source_data, source_lat, source_lng, source_id)
  t_points <- createPoints(target_data, target_lat, target_lng, target_id)
  targets <- deriveTargets(t_points)

  messageMultipleTravelModes(tms)

  for (tm in tms) {

    options$travelType <- tm
    tm_opts <- deriveOptions(options)
    sources <- deriveSources(s_points, tm_opts)

    body <- createRequestBody("time", sources, targets, tm_opts)

    response <- callTargomoAPI(api_key = api_key, region = region,
                               service = "time", body = body,
                               config = config,
                               verbose = verbose, progress = progress,
                               timeout = timeout)

    tm_times <- processResponse(response, service = "time")
    tm_times$travelType <- tm

    output[[tm]] <- tm_times

  }

  output <- do.call(rbind, output) %>%
    merge(t_points, by.x = "targetId", by.y = "id") %>%
    tibble::as_tibble() %>%
    sf::st_as_sf(coords = c("lng", "lat"), crs = sf::st_crs(4326))

  output <- output[ , c("sourceId", "targetId", "travelType", "travelTime")]

  return(output)

}

#' @rdname getTargomoTimes
#' @export
drawTargomoTimes <- function(map, times,
                             drawOptions = timeDrawOptions(),
                             group = NULL,
                             ...) {

  opts <- drawOptions

  palette <- createTimePalette(palette = opts$palette,
                               type = opts$type,
                               maxTime = opts$maxTime,
                               bins = opts$bins,
                               reverse = opts$reverse)

  map <- leaflet::addCircleMarkers(map, data = times, fillColor = ~palette(travelTime),
                                   stroke = opts$stroke, weight = opts$weight,
                                   color = opts$color, opacity = opts$opacity,
                                   fillOpacity = opts$fillOpacity, group = group,
                                   ...)

  if (opts$legend) {
    map <- addTimeLegend(map, palette, times$travelTime,
                         opts$legendOptions, group)
  }

  map

}


#' @rdname getTargomoTimes
#' @export
addTargomoTimes <- function(map,
                            source_data = NULL, source_lat = NULL, source_lng = NULL,
                            target_data = NULL, target_lat = NULL, target_lng = NULL,
                            source_id = NULL, target_id = NULL,
                            options = targomoOptions(),
                            drawOptions = timeDrawOptions(),
                            group = NULL,
                            ...,
                            api_key = Sys.getenv("TARGOMO_API_KEY"),
                            region = Sys.getenv("TARGOMO_REGION"),
                            config = list(),
                            verbose = FALSE, progress = FALSE,
                            timeout = NULL) {


  times <- getTargomoTimes(api_key = api_key, region = region,
                           source_data = source_data, source_lat = source_lat,
                           source_lng = source_lng, target_data = target_data,
                           target_lat = target_lat, target_lng = target_lng,
                           source_id = source_id, target_id = target_id,
                           options = options, config = config,
                           verbose = verbose, progress = progress,
                           timeout = timeout)

  map <- drawTargomoTimes(
    map = map,
    times = times,
    drawOptions = drawOptions,
    group = group,
    ...
  )

  return(map)

}


#' Options for Drawing Times on the Map
#'
#' @param palette A colour palette name e.g. "viridis"
#' @param type Either "numeric" or "bin"
#' @param maxTime The max time to allow for
#' @param reverse Whether to reverse the colour palette.
#' @param bins A number of bins or a vector of cut points (only used for the bin palette)
#' @param legend Whether to automatically add a legend.
#' @param legendOptions A \code{timeLegendOptions} object.
#' @param radius The marker radius.
#' @param stroke Whether to draw the marker border.
#' @param weight Stroke width in pixels.
#' @param color Stroke colour.
#' @param opacity Stroke opacity.
#' @param fill Whether to fill the polygons in with colour.
#' @param fillOpacity The fill opacity.
#'
#' @export
timeDrawOptions <- function(palette = "viridis",
                            type = "numeric",
                            maxTime = 1800,
                            reverse = FALSE,
                            bins = c(600, 1200),
                            legend = TRUE,
                            legendOptions = timeLegendOptions(),
                            radius = 10,
                            stroke = TRUE,
                            weight = 3,
                            color = "black",
                            opacity = 0.5,
                            fill = TRUE,
                            fillOpacity = 0.5) {

  leaflet::filterNULL(
    list(palette = palette,
         type = type,
         maxTime = maxTime,
         reverse = reverse,
         bins = bins,
         legend = legend,
         legendOptions = legendOptions,
         radius = radius,
         stroke = stroke,
         weight = weight,
         color = color,
         opacity = opacity,
         fill = fill,
         fillOpacity = fillOpacity)
  )

}

#' Time Legend Options
#'
#' @param position One of c("topright", "topleft", "bottomright", "bottomleft").
#' @param title The legend title.
#' @param layerId The legend layer ID.
#'
#' @export
timeLegendOptions <- function(position = "topright",
                              title = "Travel Times",
                              layerId = NULL) {
  leaflet::filterNULL(
    list(
      position = position,
      title = title,
      layerId = layerId
    )
  )

}

#' Create a Colour Palette for Time Service Results
#'
#' @param palette A colour palette e.g. "viridis", "Blues"
#' @param type Either "numeric" or "bin"
#' @param maxTime The maximum time value to consider
#' @param bins Either a single number of bins, or a vector of cut points.
#' @param reverse Whether to reverse the colour palette.
#'
createTimePalette <- function(palette, type, maxTime, bins, reverse) {

  if (!(type %in% c("numeric", "bin"))) {
    stop("Invalid 'type': ", deparse(type))
  }

  if (type == "numeric") {
    leaflet::colorNumeric(palette = palette,
                          domain = c(0, maxTime),
                          na.color = NA,
                          reverse = reverse)
  } else if (type == "bin") {
    leaflet::colorBin(palette = palette,
                      domain = c(0, maxTime),
                      bins = bins,
                      na.color = NA,
                      reverse = reverse)

  }

}

#' Add Time Legend to Map
#'
#' @param map A leaflet map
#' @param palette A colour palette (from \code{\link{createTimePalette}})
#' @param values Values to use (travel times)
#' @param options A set of \code{\link{timeLegendOptions}}
#' @param group The layer group to add the legend to
#'
addTimeLegend <- function(map, palette, values, options, group) {

  leaflet::addLegend(map, position = options$position, pal = palette,
                     values = values, title = options$title,
                     layerId = options$layerId, group = group)

}
