#' Set Targomo Environment Variables
#'
#' This helper function allows you to set your API key in either a global or local
#' .Renviron file, for ease of use. All of the \code{TargomoR} functions which call
#' the Targomo API require an API key, and use the \code{TARGOMO_API_KEY} environment
#' variable by default. Similarly you can set your default region.
#'
#' For available regions, see here: \url{https://targomo.com/developers/availability/}
#'
#' @param api_key Your Targomo API key
#' @param region Your preferred Targomo default region
#' @param overwrite Whether to overwrite an existing setting
#'
#' @name set-env-vars
#' @export
setTargomoVariables <- function(api_key = NULL, region = NULL, overwrite = FALSE) {

  if (is.null(api_key)) api_key <- Sys.getenv("TARGOMO_API_KEY")
  if (is.null(region))  region  <- Sys.getenv("TARGOMO_REGION")

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
  prior <- grepl("^TARGOMO_(API_KEY|REGION)=", vars)

  if (any(prior)) {
    if (overwrite) {
      vars <- vars[!prior]
    } else {
      message("Pre-existing TargomoR variables in .Renviron.\n",
              "Set overwrite = TRUE to alter them.")
      return(invisible(NULL))
    }
  }

  vars <- c(vars,
            paste0("TARGOMO_API_KEY=", api_key),
            paste0("TARGOMO_REGION=",  region))

  writeLines(vars, ".Renviron")
  message("Writing TARGOMO_API_KEY and TARGOMO_REGION to .Renviron file:\n",
          normalizePath(".Renviron"), "\n\n",
          "Restart R for these environment variables to take effect.")

  return(invisible(api_key))

}

#' Check API
