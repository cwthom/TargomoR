#' Targomo Version
targomoCoreVersion <- function() {
  return("0.2.14")
}

targomoLeafletVersion <- function() {
  return("0.0.3")
}


#' Function to create dependencies for each method
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




