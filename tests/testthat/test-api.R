test_that("api_component lists and retrieves components", {
  tmpwd <- withr::local_tempdir()
  withr::local_dir(new = tmpwd)

  download_components(
    repo = "NovoNordisk-OpenSource/mighty.standards/components",
    dest = "standards/v1"
  )

  api <- plumber2::api() |>
    api_component(path = "standards/v1")

  ids <- mighty.component::list_components(path = "standards/v1")
  expect_gt(length(ids), 0)

  # The base path lists the components in the directory
  res <- api$test_request(
    fiery::fake_request("http://example.com/standards/v1")
  )
  expect_equal(res$status, 200L)

  # A subpath returns that component's template
  res <- api$test_request(
    fiery::fake_request(
      paste0("http://example.com/standards/v1/", ids[[1]])
    )
  )
  expect_equal(res$status, 200L)

  # An unknown component is a 404, not a 500
  res <- api$test_request(
    fiery::fake_request("http://example.com/standards/v1/no_such_component")
  )
  expect_equal(res$status, 404L)
})

test_that("api_component keeps paths separate", {
  tmpwd <- withr::local_tempdir()
  withr::local_dir(new = tmpwd)

  download_components(
    repo = "NovoNordisk-OpenSource/mighty.standards/components",
    dest = "standards/v1"
  )

  download_components(
    repo = "NovoNordisk-OpenSource/mighty.standards/components@dev/internal-components",
    dest = "standards/v2"
  )

  api <- plumber2::api() |>
    api_component(path = "standards/v1") |>
    api_component(path = "standards/v2")

  res <- api$test_request(
    fiery::fake_request("http://example.com/standards/v1")
  )
  expect_equal(res$status, 200L)

  res <- api$test_request(
    fiery::fake_request("http://example.com/standards/v2")
  )
  expect_equal(res$status, 200L)
})
