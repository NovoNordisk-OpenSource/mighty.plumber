test_that("can download components", {
  dest <- withr::local_tempdir()

  download_components(
    repos = "NovoNordisk-OpenSource/mighty.standards/components",
    dest = dest
  ) |>
    expect_no_condition()

  mighty.component::list_components(dest) |>
    expect_contains("dummy")
})
