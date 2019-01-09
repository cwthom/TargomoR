#' Use TargomoR
#' @export
useTargomoR <- function() {
  shiny::tagList(
    shiny::singleton(
      shiny::tags$head(
        shiny::tags$script(src = "http://releases-origin.route360.net/r360-js/latest.js")
      )
    )
  )
}
