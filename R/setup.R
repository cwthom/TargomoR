#' Set Targomo API Key
#'
#' This helper function allows you to set your API key in either a global or local
#' .Renviron file, for ease of use. All of the \code{TargomoR} functions which call
#' the Targomo API require an API key, and use the \code{TARGOMO_API_KEY} environment
#' variable by default.
#'
#' @param api_key Your Targomo API key
#' @param overwrite Whether to overwrite an existing setting
#'
#' @export
setTargomoAPIKey <- function(api_key, overwrite = FALSE) {

  proj <- any(grepl("\\.Rproj$", list.files(".")))
  if (!proj) {
    stop("Make sure this directory is an R project")
  }

  renv <- file.exists(".Renviron")

  if (!renv) {
    message("Creating .Renviron file in project directory:\n",
            normalizePath("."), "\n")
    file.create(".Renviron")
  }

  vars <- readLines(".Renviron")
  prior <- grepl("^TARGOMO_API_KEY=", vars)

  if (any(prior)) {
    if (overwrite) {
      vars <- vars[!prior]
    } else {
      message("Pre-existing TARGOMO_API_KEY in .Renviron. Set overwrite = TRUE to alter.")
      return(invisible(NULL))
    }
  }

  vars <- c(vars, paste0("TARGOMO_API_KEY=", api_key))

  writeLines(vars, ".Renviron")
  message("Writing TARGOMO_API_KEY to .Renviron file:\n", normalizePath(".Renviron"))

  return(invisible(api_key))

}
