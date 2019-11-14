#' Add Targomo Basemaps to a Leaflet Map
#'
#' This function wraps round \code{leaflet::addTiles} to provide access to the Targomo basemaps.
#'
#' @param map A leaflet map
#' @param api_key Your Targomo API key - defaults to the \code{TARGOMO_API_KEY}
#'   ennvironment variable
#' @param style A valid Targomo Map Style - see \code{targomoMapStyles()}
#' @param layerId The layer id to pass to \code{leaflet::addTiles}
#' @param group The layer group to pass to \code{leaflet::addTiles}
#' @param ... Further options to pass to \code{leaflet::addTiles} e.g. options
#'
#' @name basemaps
NULL

#' @rdname basemaps
#' @export
targomoMapStyles <- function() {
  c("basic", "bright", "dark", "dark-nolabels", "darkblue", "darkblue-nolabels",
    "gray", "gray-nolabels", "light", "light-nolabels", "lightblue", "toner")
}

#' @rdname basemaps
#' @export
getTargomoMapURL <- function(style = "basic", api_key = NULL) {

  if (!(style %in% targomoMapStyles())) {
    stop("Invalid Map Style - check `targomoMapStyles()`")
  }

  core <- "https://maps.targomo.com/styles/"
  end <- "-gl-style/rendered/{z}/{x}/{y}.png?key="
  style <- switch(style,
                  "basic" = "klokantech-basic",
                  "bright" = "osm-bright",
                  "dark" = "dark-matter",
                  "dark-nolabels" = "dark-matter-nolabels",
                  "darkblue" = "fiord-color",
                  "darkblue-nolabels" = "fiord-color-nolables",
                  "gray" = "gray",
                  "gray-nolables" = "gray-nolabels",
                  "light" = "positron",
                  "light-nolabels" = "positron-nolabels",
                  "lightblue" = "blueberry",
                  "toner" = "toner")

  url <- paste0(core, style, end, api_key)

  return(url)
}

#' @rdname basemaps
#' @export
addTargomoTiles <- function(map, style = "basic",
                            api_key = Sys.getenv("TARGOMO_API_KEY"),
                            layerId = NULL,
                            group = NULL,
                            ...) {

  urlTemplate <- getTargomoMapURL(style, api_key)

  leaflet::addTiles(
    map = map,
    urlTemplate = urlTemplate,
    attribution = "<a href='https://www.openstreetmap.org/copyright' target='_blank'>&copy; OpenStreetMap contributors</a>
                   <a href='http://openmaptiles.org/' target='_blank'>&copy; OpenMapTiles</a>
                   <a href='https://targomo.com/developers/resources/attribution/' target='_blank'>&copy; Targomo</a>",
    layerId = layerId,
    group = group,
    ...
  )
}
