test_that("get functions work", {

  # create source and target data
  source_data <- data.frame(id = "A", lat = 51.52, lng = -0.19)
  target_data <- data.frame(id = c("X", "Y", "Z"),
                            lat = c(51.50, 51.515, 51.51),
                            lng = c(-0.18, -0.185, -0.17))

  # test polygons
  p <- getTargomoPolygons(source_data)
  expect_is(p, c("sf", "data.frame"))
  expect_equal(dim(p), c(3, 3))
  expect_equal(p$time, c(1800, 1200, 600))
  expect_is(p$geometry, c("sfc_MULTIPOLYGON", "sfc"))
  expect_equal(sf::st_crs(p), sf::st_crs(4326))
  expect_equal(sf::st_dimension(p), c(2, 2, 2))

  # test routes
  r <- getTargomoRoutes(source_data = source_data, target_data = target_data)
  r1 <- r$bike[[1]]
  f <- r1$features
  expect_is(r, "list")
  expect_equal(length(r), 1)
  expect_equal(names(r), "bike")
  expect_equal(length(r$bike), 3)
  expect_is(r1, c("tbl_df", "tbl", "data.frame"))
  expect_equal(dim(r1), c(3, 3))
  expect_equal(r1$sourceId, c("1", "1", "1"))
  expect_equal(names(r1), c("sourceId", "targetId", "features"))
  expect_is(f, c("sf", "data.frame"))
  expect_equal(dim(f), c(3, 9))
  expect_is(f$geometry, c("sfc_GEOMETRY", "sfc"))
  expect_equal(sf::st_crs(f), sf::st_crs(4326))
  expect_equal(sf::st_dimension(f), c(1, 0, 0))

  # test route popup
  expect_match(createRoutePopup(f[1, ]), "^<b>BIKE</b></br>Journey time: \\d+s$")

  # test times
  t <- getTargomoTimes(source_data = source_data, target_data = target_data)
  expect_is(t, c("sf", "data.frame"))
  expect_equal(names(t), c("sourceId", "targetId", "travelType", "travelTime", "geometry"))
  expect_equal(dim(t), c(3, 5))
  expect_equal(sf::st_crs(t), sf::st_crs(4326))
  expect_is(t$geometry, c("sfc_POINT", "sfc"))
  expect_equal(sf::st_dimension(t), c(0, 0, 0))
  expect_equal(t$travelType, c("bike", "bike", "bike"))


})
