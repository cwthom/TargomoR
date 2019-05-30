#' Set Targomo Options
#'
#' This function sets the options to be passed to the API service.
#' For full details of available options see:
#' \url{https://docs.targomo.com/core/#/Polygon_Service/post_westcentraleurope_v1_polygon}
#'
#' @param travelTimes A list of times, in seconds - each time corresponds to a
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
                          travelTimes = list(600, 1200, 1800),
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
