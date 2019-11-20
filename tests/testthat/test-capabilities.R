test_that("capabilities requests work", {

  # get capabilities
  caps <- getTargomoCapabilities()

  expect_is(caps, "list")
  expect_length(caps, 3)
  expect_named(caps)
  expect_equal(names(caps), c("general", "transit", "speeds"))

})
