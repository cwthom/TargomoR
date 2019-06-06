library(leaflet)

# test polygon
l1 <- leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addTargomoPolygons(lat = 51.5, lng = -0.18,
                     options = targomoOptions(travelType = "transit")) %>%
  addMarkers(lat = 51.5, lng = -0.18)


# test routes
l2 <- leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addTargomoRoutes(source_data = data.frame(lat = 51.5267, lng = -0.1925),
                   target_data = data.frame(lat = 51.512, lng = -0.11),
                   options = targomoOptions(travelType = c("car", "transit", "bike"),
                                            maxEdgeWeight = "1h",
                                            transitMaxTransfers = 0),
                   verbose = FALSE, progress = FALSE)

# manual testing
options_list <- targomoOptions()
source_data <- data.frame(id = c("A", "B"),
                          lat = c(51.52, 51.53), lng = c(-0.20, -0.19))
target_data <- data.frame(id = c("X", "Y", "Z"),
                          lat = c(51.50, NA, 51.51), lng = c(-0.18, -0.185, -0.17))

options <- deriveOptions(options_list)
sources <- deriveSources(source_data, options = options, id = ~id)
targets <- deriveTargets(target_data, id = ~id)

t_body <- createRequestBody("time", sources, targets, options)

t_response <- callTargomoAPI(service = "time", body = t_body, verbose = TRUE)
t_payload <- httr::content(t_response)

processTime(t_payload)

getTargomoTimes(source_data = source_data, target_data = target_data,
                source_id = ~id, target_id = ~id)



