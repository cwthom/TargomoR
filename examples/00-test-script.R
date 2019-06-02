library(leaflet)

leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addTargomoPolygons(lat = 51.5, lng = -0.18,
                     options = targomoOptions(travelType = "transit")) %>%
  addMarkers(lat = 51.5, lng = -0.18)



leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addTargomoRoutes(source_data = data.frame(lat = 51.5267, lng = -0.1925),
                   target_data = data.frame(lat = 51.512, lng = -0.11),
                   options = targomoOptions(travelType = c("car", "transit", "bike"),
                                            maxEdgeWeight = "1h",
                                            transitMaxTransfers = 0),
                   verbose = FALSE, progress = FALSE)
