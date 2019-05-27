#' Targomo Version
#'
#' These functions return the versions of the Targomo API which are bundled with
#' the package
#' @name api-versions
NULL

#' @rdname api-versions
#' @export
targomoCoreVersion <- function() {
  return("0.2.14")
}

#' @rdname api-versions
#' @export
targomoLeafletVersion <- function() {
  return("0.0.3")
}


#' Dependencies
#'
#' This function exposes the bundled API prod files and bindings as dependencies.
#'
#' @param ... Further args to pass to \code{htmltools::htmlDependency}
#'
#' @name dependencies
targomoDependency <- function( ...) {
  list(
    htmltools::htmlDependency(
      name = "targomo-core",
      version = targomoCoreVersion(),
      src = system.file(file.path("htmlwidgets", "build", "targomo-core"),
                        package = "TargomoR"),
      script = "targomo-core-prod.js",
      all_files = TRUE,
      ...
    ),
    htmltools::htmlDependency(
      name = "targomo-leaflet",
      version = targomoLeafletVersion(),
      src = system.file(file.path("htmlwidgets", "build", "targomo-leaflet"),
                        package = "TargomoR"),
      script = paste0("targomo-leaflet", c("-prod.js", "-bindings.js")),
      all_files = TRUE,
      ...
    )
  )
}




