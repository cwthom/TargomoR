test_that("basemaps behave themselves", {

  # create map
  l <- leaflet::leaflet()

  # test map styles vector
  expect_equal(targomoMapStyles(),
               c("basic", "bright", "dark", "dark-nolabels", "darkblue", "darkblue-nolabels",
                 "gray", "gray-nolabels", "light", "light-nolabels", "lightblue", "toner"))

  # test Map URLs
  expect_equal(getTargomoMapURL(style = "basic"), "https://maps.targomo.com/styles/klokantech-basic-gl-style/rendered/{z}/{x}/{y}.png?key=")
  expect_error(getTargomoMapURL(style = "notreal"))

  # test adding to map
  expect_is(addTargomoTiles(l), c("leaflet", "htmlwidget"))


})
