test_that("GDAL version checked checked", {
  local_mocked_bindings(
    gdal_version = function(...) numeric_version("3.0.0")
  )
  expect_snapshot(
    error = TRUE,
    check_gdal_sozip()
  )
})
