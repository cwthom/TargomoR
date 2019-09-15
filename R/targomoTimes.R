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
#' @param drawOptions A list of \code{\link{timeDrawOptions}} to determine how to show
#'   the resulting times on the map.
#' @param group The leaflet map group to add the times to. One group is used for all
#'   map elements being drawn per call to the API.
#' @param api_key Your Targomo API key - defaults to the \code{TARGOMO_API_KEY}
#'   ennvironment variable.
#' @param region Your Targomo region - defaults to the \code{TARGOMO_REGION}
#'   environment variable.
#' @param verbose Whether to print out information about the API call.
#' @param progress Whether to show a progress bar of the API call.
#'
#' @name times
#'
NULL

#' @rdname times
#' @export
getTargomoTimes <- function(source_data = NULL, source_lat = NULL, source_lng = NULL,
                            target_data = NULL, target_lat = NULL, target_lng = NULL,
                            source_id = NULL, target_id = NULL,
                            options = targomoOptions(),
                            api_key = Sys.getenv("TARGOMO_API_KEY"),
                            region = Sys.getenv("TARGOMO_REGION"),
                            verbose = FALSE,
                            progress = FALSE) {

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
                               verbose = verbose, progress = progress)

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


#' @rdname times
#' @export
addTargomoTimes <- function(map,
                            source_data = NULL, source_lat = NULL, source_lng = NULL,
                            target_data = NULL, target_lat = NULL, target_lng = NULL,
                            source_id = NULL, target_id = NULL,
                            options = targomoOptions(),
                            drawOptions = timeDrawOptions(),
                            group = NULL,
                            api_key = Sys.getenv("TARGOMO_API_KEY"),
                            region = Sys.getenv("TARGOMO_REGION"),
                            verbose = FALSE, progress = FALSE) {


  times <- getTargomoTimes(api_key = api_key, region = region,
                           source_data = source_data, source_lat = source_lat,
                           source_lng = source_lng, target_data = target_data,
                           target_lat = target_lat, target_lng = target_lng,
                           source_id = source_id, target_id = target_id,
                           options = options,
                           verbose = verbose, progress = progress)

  opts <- drawOptions

  palette <- createTimePalette(palette = opts$palette,
                               type = opts$type,
                               maxTime = opts$maxTime,
                               bins = opts$bins,
                               reverse = opts$reverse)

  map <- leaflet::addCircleMarkers(map, data = times, fillColor = ~palette(travelTime),
                                   stroke = opts$stroke, weight = opts$weight,
                                   color = opts$color, opacity = opts$opacity,
                                   fillOpacity = opts$fillOpacity, group = group)

  if (opts$legend) {

    lopts <- opts$legendOptions
    map <- leaflet::addLegend(map,  position = lopts$position, pal = palette,
                              values = times$travelTime, title = lopts$title,
                              layerId = lopts$layerId, group = group)

  }

  map

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
                            legend = FALSE,
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
