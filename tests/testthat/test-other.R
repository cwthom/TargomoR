context("Miscellaneous")
library(TargomoR)

test_that("Capabilities service works", {

  # skip on CRAN
  skip_on_cran()

  # get capabilities
  caps <- getTargomoCapabilities()

  # expectations
  expect_is(caps, "list")
  expect_length(caps, 3)
  expect_named(caps)
  expect_equal(names(caps), c("general", "transit", "speeds"))

})

test_that("Formatting works for edgeweights", {

  expect_time <- function(string, time) {
    expect_equal(formatEdgeWeight(string, "time"), time)
  }

  expect_distance <- function(string, distance) {
    expect_equal(formatEdgeWeight(string, "distance"), distance)
  }

  # errors
  expect_error(formatEdgeWeight(500, type = "blah"),
               "'type' must be 'time' or 'distance', not 'blah'")
  expect_error(formatEdgeWeight("1a", "time"),
               "Invalid time string specified: 1a")
  expect_error(formatEdgeWeight("2b", "distance"),
               "Invalid distance string specified: 2b")

  # times
  expect_time("1h", 3600)
  expect_time("1h20m", 4800)
  expect_time("30m15s", 1815)
  expect_time("2h1s", 7201)
  expect_time(1, 1)

  # distances
  expect_distance("1ml", 1609)
  expect_distance("2km", 2000)
  expect_distance("450m", 450)
  expect_distance("1km100m", 1100)

})
