% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/polygons.R
\name{getTargomoPolygons}
\alias{getTargomoPolygons}
\alias{drawTargomoPolygons}
\alias{addTargomoPolygons}
\title{Add Targomo Polygons to a Leaflet Map}
\usage{
getTargomoPolygons(
  source_data = NULL,
  source_lat = NULL,
  source_lng = NULL,
  options = targomoOptions(),
  api_key = Sys.getenv("TARGOMO_API_KEY"),
  region = Sys.getenv("TARGOMO_REGION"),
  config = list(),
  verbose = FALSE,
  progress = FALSE,
  timeout = NULL
)

drawTargomoPolygons(
  map,
  polygons,
  drawOptions = polygonDrawOptions(),
  group = NULL,
  ...
)

addTargomoPolygons(
  map,
  source_data = NULL,
  source_lng = NULL,
  source_lat = NULL,
  options = targomoOptions(),
  drawOptions = polygonDrawOptions(),
  group = NULL,
  ...,
  api_key = Sys.getenv("TARGOMO_API_KEY"),
  region = Sys.getenv("TARGOMO_REGION"),
  config = list(),
  verbose = FALSE,
  progress = FALSE,
  timeout = NULL
)
}
\arguments{
\item{source_data}{The data object from which source ppoints are derived.}

\item{source_lng, source_lat}{Vectors/one-sided formulas of longitude and latitude.}

\item{options}{A list of \code{\link{targomoOptions}} to call the API.}

\item{api_key}{Your Targomo API key - defaults to the \code{TARGOMO_API_KEY}
ennvironment variable}

\item{region}{Your Targomo region - defaults to the \code{TARGOMO_REGION}
environment variable}

\item{config}{Config options to pass to \code{httr::POST} e.g. proxy settings}

\item{verbose}{Whether to print out information about the API call.}

\item{progress}{Whether to show a progress bar of the API call.}

\item{timeout}{Timeout in seconds (leave NULL for no timeout/curl default).}

\item{map}{A leaflet map.}

\item{polygons}{A polygons dataset returned by \code{getTargomoPolygons}, for drawing}

\item{drawOptions}{A list of \code{\link{polygonDrawOptions}} to determine how to show
the resulting polygons on the map.}

\item{group}{The leaflet map group to add the polygons to. A single group is used
for all the polygons added by one API call.}

\item{...}{Further arguments to pass to \code{\link[leaflet]{addPolygons}}}
}
\value{
For `get*`, an object of class "sf" containing the polygons. For `draw*` and `add*`,
  the leaflet map returned with the polygons drawn on.
}
\description{
Functions for retrieving isochrone polygons from the Targomo API and adding
drawing them on a \code{leaflet} map.
}
\examples{
\donttest{
# load leaflet package
library(leaflet)
l <- leaflet()

# get the polygons
p <- getTargomoPolygons(source_lat = 51.5007, source_lng = -0.1246,
                        options = targomoOptions(travelType = "bike"))

# draw them on the map
l \%>\% drawTargomoPolygons(polygons = p, group = "BigBenBike")

# note could combine get... and draw... into one with add...

}

}
