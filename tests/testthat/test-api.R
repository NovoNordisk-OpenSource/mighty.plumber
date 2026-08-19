test_that("multiplication works", {
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

  plumber2::api() |>
    api_component(path = "standards/v1") |>
    api_component(path = "standards/v2") |>
    plumber2::api_run()
})
