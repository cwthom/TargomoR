library(leaflet)

leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addTargomoPolygons()

