#' Run Demos
#'
#' These functions provide an easy way of running demos for the TargomoR package.
#'
#' @name targomo-demos
NULL

#' @rdname targomo-demos
#' @export
polygon_demo <- function() {
  shiny::runApp(system.file(file.path("examples", "01-shiny-polygons"),
                            package = "TargomoR"))
}
