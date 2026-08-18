#' Download all mighty components from a repo location
#'
#' @description
#' Download every mighty component (`.R` and `.mustache` files) found in a
#' GitHub repo location and write them to a local directory.
#'
#' The resulting directory can be passed to
#' [mighty.component::list_components()].
#'
#' @details
#' Components are searched for recursively below the given location, so both
#' a flat folder and the one-directory-per-component layout are supported:
#'
#' ```
#' components/dummy/dummy.mustache
#' ```
#'
#' Files named `test-*` are treated as component tests and are not
#' downloaded. Matching files are written flat into `dest`, discarding their
#' directory structure.
#'
#' @param repo `character(1)` location spec: `owner/repo`,
#'   `owner/repo/subdir`, or `owner/repo@ref`. When a subdir is given, only
#'   that folder is searched.
#' @param dest `character(1)` directory to write component files into.
#'   Created if it does not exist. Any existing `.R` and `.mustache` files are
#'   removed first, so components deleted upstream do not linger. Other files
#'   are left untouched.
#' @param overwrite `logical(1)` allow writing to a non-empty `dest`.
#'   Errors if `FALSE` and `dest` is not empty.
#' @returns `dest`, invisibly.
#' @examples
#' dest <- withr::local_tempdir()
#' download_components(
#'   repo = "NovoNordisk-OpenSource/mighty.standards/components",
#'   dest = dest
#' )
#' mighty.component::list_components(dest)
#'
#' @export
download_components <- function(repo, dest, overwrite = FALSE) {
  rlang::check_string(repo)
  rlang::check_string(dest)
  rlang::check_bool(overwrite)

  not_empty <- dir.exists(dest) &&
    length(list.files(dest, all.files = TRUE, no.. = TRUE)) > 0

  if (!overwrite && not_empty) {
    cli::cli_abort("Directory {.file {dest}} already exists and is not empty")
  }

  spec <- remotes::parse_repo_spec(repo)

  tarfile <- withr::local_tempfile(fileext = ".tar.gz")
  exdir <- withr::local_tempdir()

  root <- download_tar(spec, tarfile) |>
    extract_tar(exdir)

  if (nzchar(spec$subdir)) {
    root <- file.path(root, spec$subdir)

    if (!dir.exists(root)) {
      cli::cli_abort("Path {.file {spec$subdir}} not found in {.val {repo}}.")
    }
  }

  files <- list.files(
    path = root,
    pattern = "\\.(R|mustache)$",
    full.names = TRUE,
    recursive = TRUE
  )

  files <- files[!grepl("^test-", basename(files))]

  if (length(files) == 0) {
    cli::cli_abort("No components found in {.val {repo}}.")
  }

  if (dir.exists(dest)) {
    list.files(path = dest, pattern = "\\.(R|mustache)$", full.names = TRUE) |>
      unlink(recursive = TRUE)
  } else {
    dir.create(path = dest, recursive = TRUE)
  }

  file.copy(from = files, to = dest)

  invisible(dest)
}
