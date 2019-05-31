library(leaflet)

leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addTargomoPolygons(lat = 51.5, lng = -0.18,
                     options = targomoOptions(travelType = "transit"),
                     color = c("red", "orange", "green")) %>%
  addMarkers(lat = 51.5, lng = -0.18)



leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addTargomoRoutes(source_data = data.frame(lat = 51.52, lng = -0.187),
                   target_data = data.frame(lat = runif(2, 51.47, 51.57),
                                            lng = runif(2, -0.21, -0.17)),
                   options = targomoOptions(travelType = "transit"))
