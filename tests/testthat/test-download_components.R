test_that("can download components", {
  dest <- withr::local_tempdir()

  download_components(
    repo = "NovoNordisk-OpenSource/mighty.standards/components",
    dest = dest
  ) |>
    expect_no_error()

  mighty.component::list_components(dest) |>
    expect_contains("dummy")
})

test_that("errors when dest is not empty and overwrite is FALSE", {
  dest <- withr::local_tempdir()
  file.create(file.path(dest, "existing.txt"))

  download_components(repo = "owner/repo", dest = dest) |>
    expect_error("already exists and is not empty")
})

test_that("test files are not downloaded", {
  dest <- withr::local_tempdir()

  download_components(
    repo = "NovoNordisk-OpenSource/mighty.standards/components",
    dest = dest
  )

  files <- list.files(dest)

  expect_contains(files, "dummy.mustache")
  expect_false("test-dummy.R" %in% files)
})

test_that("a ref can be given", {
  dest <- withr::local_tempdir()

  download_components(
    repo = "NovoNordisk-OpenSource/mighty.standards/components@main",
    dest = dest
  ) |>
    expect_no_error()

  list.files(dest) |>
    expect_contains("dummy.mustache")
})

test_that("dest is created when it does not exist", {
  dest <- file.path(withr::local_tempdir(), "new", "nested")

  download_components(
    repo = "NovoNordisk-OpenSource/mighty.standards/components",
    dest = dest
  )

  expect_true(dir.exists(dest))
})

test_that("overwrite replaces components but keeps other files", {
  dest <- withr::local_tempdir()
  file.create(file.path(dest, "stale.mustache"))
  file.create(file.path(dest, "unrelated.txt"))

  download_components(
    repo = "NovoNordisk-OpenSource/mighty.standards/components",
    dest = dest,
    overwrite = TRUE
  )

  files <- list.files(dest)

  expect_false("stale.mustache" %in% files)
  expect_contains(files, "unrelated.txt")
  expect_contains(files, "dummy.mustache")
})

test_that("errors on a subdir that does not exist", {
  dest <- withr::local_tempdir()

  download_components(
    repo = "NovoNordisk-OpenSource/mighty.standards/nope",
    dest = dest
  ) |>
    expect_error("not found in")
})

test_that("errors when a location holds no components", {
  dest <- withr::local_tempdir()

  download_components(
    repo = "NovoNordisk-OpenSource/mighty.standards/.github",
    dest = dest
  ) |>
    expect_error("No components found")
})
