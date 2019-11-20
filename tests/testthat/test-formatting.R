test_that("formatting functions work", {

  # create helper functions
  ft <- function(t) formatEdgeWeight(t, "time")
  fd <- function(d) formatEdgeWeight(d, "distance")

  # test error
  expect_error(formatEdgeWeight(150, "speed"))
  expect_error(formatEdgeWeight("2m30s"))

  # test time formats
  expect_equal(ft(120), 120)
  expect_equal(ft("1h"), 3600)
  expect_equal(ft("20m"), 1200)
  expect_equal(ft("90s"), 90)
  expect_equal(ft("1h30m12s"), 5412)
  expect_equal(ft("10m30s"), 630)
  expect_equal(ft("2h60s"), 7260)
  expect_error(ft("60s5m"), "Invalid time string specified: 60s5m")

  # test distance formats
  expect_equal(fd(100), 100)
  expect_equal(fd("1km"), 1000)
  expect_equal(fd("1ml"), 1609)
  expect_equal(fd("500m"), 500)
  expect_error(fd("2.5km"))

})
