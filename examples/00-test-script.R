library(leaflet)

leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addTargomoPolygons(lat = 51.5, lng = -0.18,
                     options = targomoOptions(travelType = "transit")) %>%
  addMarkers(lat = 51.5, lng = -0.18)



leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addTargomoRoutes(source_data = data.frame(lat = 51.5267, lng = -0.1925),
                   target_data = data.frame(lat = 51.51, lng = -0.09),
                   options = targomoOptions(travelType = c("transit"),
                                            maxEdgeWeight = 3600,
                                            transitTime = 8*60*60,
                                            transitMaxTransfers = 1),
                   drawOptions = routeDrawOptions(transitColour = "red"))
