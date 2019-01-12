#' Targomo Version
targomoVersion <- function() {
  return("0.5.3")
}


#' Function to create dependencies for each method
targomoDependency <- function( ...) {
  list(
    htmltools::htmlDependency(
      name = "Targomo",
      version = targomoVersion(),
      src = system.file(file.path("htmlwidgets", "build", "targomo"),
                        package = "TargomoR"),
      script = paste0("targomo", c("-prod.js", "-bindings.js")),
      all_files = TRUE,
      ...
    )
  )
}




