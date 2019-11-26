# Package Startup Message

.onAttach <- function(...) {

  if (!getOption("targomor.quiet", FALSE)) {

    msg <- c("Welcome to TargomoR!", "",
             "This package talks to the Targomo API. To use it you will need an API Key. Get yours at:", "",
             "* https://targomo.com/developers/pricing/", "",
             "Please also be aware of the Targomo terms and conditions:", "",
             "* https://account.targomo.com/legal/terms", "")

    packageStartupMessage(paste0(msg, collapse = "\n"))

  }

}
