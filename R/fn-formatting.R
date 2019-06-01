
#' Format Requests and Responses
#'
#' Functions to make the interface easier and more intuitive to use.
#'
#' @param edgeWeight A time or distance, in numeric or string form.
#' @param type Either 'time' or 'distance'.
#'
#' @name formatting
#'
NULL

#' @rdname formatting
formatEdgeWeight <- function(edgeWeight, type) {

  if (type == "time") {
    rgx <- "^ *([0-9]+h)? *([0-9]+m)? *([0-9]+s)? *$"
  } else if (type == "distance") {
    rgx <- "^ *([0-9]+km)? *([0-9]+m)? *([0-9]+ml)? *$"
  } else {
    stop("'type' must be 'time' or 'distance', not '", type, "'")
    return(invisible(NULL))
  }

  if (is.numeric(edgeWeight)) {
    secs <- edgeWeight
    return(secs)
  }

  if (is.character(edgeWeight)) {
    if (!grepl(rgx, edgeWeight)) {
      stop("Invalid ", type, " string specified: ", edgeWeight)
    }
    if (type == "time") {
      hr  <- gsub("(\\d+)h", "\\1", gsub(rgx, "\\1", edgeWeight))
      min <- gsub("(\\d+)m", "\\1", gsub(rgx, "\\2", edgeWeight))
      sec <- gsub("(\\d+)s", "\\1", gsub(rgx, "\\3", edgeWeight))
      secs <- 3600*as.numeric(replace(hr, hr == "", 0)) +
        60*as.numeric(replace(min, min == "", 0)) +
        as.numeric(replace(sec, sec == "", 0))
      return(secs)
    } else {
      km <- gsub("(\\d+)km$", "\\1", gsub(rgx, "\\1", edgeWeight))
      m  <- gsub("(\\d+)m$",  "\\1", gsub(rgx, "\\2", edgeWeight))
      ml <- gsub("(\\d+)ml$", "\\1", gsub(rgx, "\\3", edgeWeight))
      metres <- 1000*as.numeric(replace(km, km == "", 0)) +
        1609*as.numeric(replace(ml, ml == "", 0)) +
        as.numeric(replace(m, m == "", 0))
      return(metres)
    }

  }

}

