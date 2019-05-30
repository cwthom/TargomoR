library(leaflet)

leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addTargomoPolygons(lat = 51.5, lng = -0.18,
                     options = targomoOptions(travelType = "transit"),
                     color = c("red", "orange", "green")) %>%
  addMarkers(lat = 51.5, lng = -0.18)

