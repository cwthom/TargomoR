context("test-api-request-creation")

test_that("API request creation works", {

  # create source and target data
  source_data <- data.frame(id = "A", lat = 51.52, lng = -0.19)
  target_data <- data.frame(id = c("X", "Y", "Z"),
                            lat = c(51.50, 51.515, 51.51),
                            lng = c(-0.18, -0.185, -0.17))
  s_points <- createPoints(source_data, ~lat, ~lng, ~id)
  t_points <- createPoints(target_data, ~lat, ~lng, ~id)

  # create options
  options <- targomoOptions()
  opts <- deriveOptions(options)

  # derive sources and targets
  sources <- deriveSources(s_points, opts)
  targets <- deriveTargets(t_points)

  # derive request bodies
  p_body <- createRequestBody("polygon", sources, NULL, opts)
  r_body <- createRequestBody("route", sources, targets, opts)
  t_body <- createRequestBody("time", sources, targets, opts)

  # call API
  p_response <- callTargomoAPI(service = "polygon", body = p_body)
  r_response <- callTargomoAPI(service = "route",   body = r_body)
  t_response <- callTargomoAPI(service = "time",    body = t_body)

  # process Response
  p_output <- processPolygons(httr::content(p_response))
  r_output <- processRoutes(httr::content(r_response))
  t_output <- processTimes(httr::content(t_response))

  # test API request URL creation
  expect_equal(targomoAPI(), "https://api.targomo.com/")
  expect_equal(createRequestURL("britishisles", "route"),
               "https://api.targomo.com/britishisles/v1/route")

  # test otpions structure
  expect_is(options, "list")
  expect_is(opts, "list")
  expect_length(opts, 6)
  expect_is(opts$tm, "list")

  # test ID creation
  expect_equal(createIds(target_data), c(1, 2, 3))
  expect_equal(createIds(target_data, ~id), c("X", "Y", "Z"))

  # test source point creation
  expect_is(s_points, "data.frame")
  expect_equal(s_points$id, "A")
  expect_is(t_points, "data.frame")

  # test derived lists
  expect_is(sources, "list")
  expect_is(targets, "list")
  expect_equal(names(sources[[1]]), c("id", "lat", "lng", "tm"))
  expect_equal(names(targets[[1]]), c("id", "lat", "lng"))

  # test request bodies
  expect_is(p_body, "json")
  expect_is(r_body, "json")
  expect_is(t_body, "json")

  # test error behaviour
  expect_error(createRequestBody(service = NULL, options = NULL),
               "No Targomo service specified")
  expect_error(createRequestBody("polygon", NULL, NULL, opts),
               "No source data provided")

  # test calling API
  expect_equal(p_response$status_code, 200)
  expect_equal(r_response$status_code, 200)
  expect_equal(t_response$status_code, 200)

  # test processing API response
  expect_is(p_output, "sf")
  expect_equal(dim(p_output), c(3, 3))
  expect_is(r_output, "list")
  expect_is(r_output[[1]]$features, "sf")
  expect_equal(length(r_output), 3)
  expect_is(t_output, "data.frame")
  expect_equal(dim(t_output), c(3, 3))
  expect_equal(names(t_output), c("sourceId", "targetId", "travelTime"))


})
