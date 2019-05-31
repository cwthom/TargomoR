library(leaflet)

leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addTargomoPolygons(lat = 51.5, lng = -0.18,
                     options = targomoOptions(travelType = "transit"),
                     color = c("red", "orange", "green")) %>%
  addMarkers(lat = 51.5, lng = -0.18)



leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addTargomoRoutes(source_data = data.frame(lat = 51.5267, lng = -0.1925),
                   target_data = data.frame(lat = 51.48, lng = -0.13),
                   options = targomoOptions(travelType = c("transit"),
                                            maxEdgeWeight = 3600,
                                            transitTime = 8*60*60,
                                            transitMaxTransfers = 0),
                   drawOptions = routeDrawOptions(transitColour = "orange"))
