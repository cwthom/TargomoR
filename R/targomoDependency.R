targomoDependency <- function() {
  htmltools::htmlDependency(name = "Targomo", version = "1.0",
                            src = c(href = "http://releases-origin.route360.net/r360-js/"),
                            script = "latest.js")
}
