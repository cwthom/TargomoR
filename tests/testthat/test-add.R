test_that("adding functions behave themselves", {

  # create a map
  l <- leaflet::leaflet()

  # create source and target data
  source_data <- data.frame(id = "A", lat = 51.52, lng = -0.19)
  target_data <- data.frame(id = c("X", "Y", "Z"),
                            lat = c(51.50, 51.515, 51.51),
                            lng = c(-0.18, -0.185, -0.17))

  # create options
  o <- targomoOptions()

  # create drawing options
  rd <- routeDrawOptions()
  pd <- polygonDrawOptions()
  td <- timeDrawOptions()

  # test adding data to map
  expect_is(addTargomoPolygons(l, source_data = source_data,
                               options = o, drawOptions = pd),
            c("leaflet", "htmlwidget"))
  expect_is(addTargomoRoutes(l, source_data = source_data, target_data = target_data,
                             options = o, drawOptions = rd),
            c("leaflet", "htmlwidget"))
  expect_is(addTargomoTimes(l, source_data = source_data, target_data = target_data,
                            options = o, drawOptions = td),
            c("leaflet", "htmlwidget"))

})
