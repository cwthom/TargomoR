test_that("drawing functions behave themselves", {

  # create a map
  l <- leaflet::leaflet()

  # create source and target data
  source_data <- data.frame(id = "A", lat = 51.52, lng = -0.19)
  target_data <- data.frame(id = c("X", "Y", "Z"),
                            lat = c(51.50, 51.515, 51.51),
                            lng = c(-0.18, -0.185, -0.17))

  # create drawing options
  rd <- routeDrawOptions()
  pd <- polygonDrawOptions()
  td <- timeDrawOptions()
  lg <- timeLegendOptions()

  # get polygons, routes and times
  p <- getTargomoPolygons(source_data = source_data)
  r <- getTargomoRoutes(source_data = source_data, target_data = target_data)
  t <- getTargomoTimes(source_data = source_data, target_data = target_data)


  # test draw options lists
  expect_is(rd, "list")
  expect_is(pd, "list")
  expect_is(td, "list")
  expect_is(lg, "list")

  # test defaults
  expect_true(rd$showMarkers)
  expect_true(rd$showTransfers)
  expect_true(pd$stroke)
  expect_true(pd$fill)
  expect_false(td$reverse)
  expect_true(td$legend)
  expect_true(td$fill)
  expect_true(td$stroke)

  # test adding data to map
  expect_is(drawTargomoPolygons(l, p, pd), c("leaflet", "htmlwidget"))
  expect_is(drawTargomoRoutes(l, r, rd), c("leaflet", "htmlwidget"))
  expect_is(drawTargomoTimes(l, t, td), c("leaflet", "htmlwidget"))



})
