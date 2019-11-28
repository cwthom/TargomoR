#' Set Targomo Environment Variables
#'
#' This helper function allows you to set your API key in either a global or local
#' .Renviron file, for ease of use. All of the \code{TargomoR} functions which call
#' the Targomo API require an API key, and use the \code{TARGOMO_API_KEY} environment
#' variable by default. Similarly you can set your default region.
#'
#' For available regions, see here: \url{https://targomo.com/developers/resources/availability/}
#'
#' @param api_key Your Targomo API key
#' @param region Your preferred Targomo default region
#' @param overwrite Whether to overwrite an existing setting
#' @param global If TRUE, write to a global .Renviron in \code{Sys.getenv("HOME")}
#'
#' @return Invisibly, the API key - this function is called for its side effects
#'
#' @examples
#' \dontrun{
#' # write to a global file at Sys.getenv("HOME")
#' setTargomoVariables(api_key = "YOUR_SECRET_KEY", region = "asia", overwrite = TRUE, global = TRUE)
#' }
#'
#' @export
setTargomoVariables <- function(api_key = NULL, region = NULL, overwrite = FALSE,
                                global = FALSE) {

  if (is.null(api_key)) api_key <- Sys.getenv("TARGOMO_API_KEY")
  if (is.null(region))  region  <- Sys.getenv("TARGOMO_REGION")

  if (global) {
    renv <- file.path(Sys.getenv("HOME"), ".Renviron")
  } else {
    renv <- file.path(getwd(), ".Renviron")
  }

  renv_exists <- file.exists(renv)

  if (!renv_exists) {
    message("Creating .Renviron file at:\n",
            renv, "\n")
    file.create(renv)
  }

  vars <- readLines(renv)
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

  writeLines(vars, renv)
  message("Writing TARGOMO_API_KEY and TARGOMO_REGION to .Renviron file:\n",
          renv, "\n\n",
          "Restart R for these environment variables to take effect.")

  return(invisible(api_key))

}
