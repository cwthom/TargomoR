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
                                            transitMaxTransfers = 1),
                   verbose = FALSE, progress = FALSE)

# test times
l3 <- leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addTargomoTimes(source_data = data.frame(lat = 51.52, lng = -0.19),
                  target_data = data.frame(lat = runif(100, 51.47, 51.57),
                                           lng = runif(100, -0.3, -0.1)),
                  options = targomoOptions(travelType = "car",
                                           maxEdgeWeight = "1h"),
                  drawOptions = timeDrawOptions(palette = "inferno",
                                                maxTime = 1800,
                                                fillOpacity = 0.8,
                                                reverse = TRUE,
                                                radius = 5,
                                                weight = 1))



# manual testing
source_data <- data.frame(id = "A", lat = 51.52, lng = -0.19)
target_data <- data.frame(id = c("X", "Y", "Z"),
                          lat = c(51.50, 51.515, 51.51),
                          lng = c(-0.18, -0.185, -0.17))

getTargomoTimes(source_data = source_data, target_data = target_data,
                source_lat = ~lat, source_lng = ~lng,
                target_lat = ~lat, target_lng = ~lng,
                source_id = ~id, target_id = ~id,
                options = targomoOptions(travelType = "bike"))


