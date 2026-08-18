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
#'   Created if it does not exist. If it does exist, its contents are deleted
#'   before the components are written.
#' @param overwrite `logical(1)` allow writing to a non-empty `dest`.
#'   Errors if `FALSE` and `dest` is not empty.
#' @returns `dest`, invisibly.
#' @examples
#' dest <- withr::local_tempdir()
#' download_components("NovoNordisk-OpenSource/mighty.standards/components", dest)
#' mighty.component::list_components(dest)
#'
#' @export
download_components <- function(repo, dest, overwrite = FALSE) {
  rlang::check_string(repo)
  rlang::check_string(dest)
  rlang::check_bool(overwrite)

  if (!overwrite && dir.exists(dest) && length(list.files(dest)) > 0) {
    cli::cli_abort("Directory {.file {dest}} already exists and is not empty")
  }

  spec <- remotes::parse_repo_spec(repo)

  tarfile <- withr::local_tempfile(fileext = ".tar.gz")

  endpoint <- "GET /repos/{owner}/{repo}/tarball"
  args <- list(owner = spec$username, repo = spec$repo, .destfile = tarfile)

  if (nzchar(spec$ref)) {
    endpoint <- paste0(endpoint, "/{ref}")
    args$ref <- spec$ref
  }

  do.call(gh::gh, c(list(endpoint = endpoint), args))

  exdir <- withr::local_tempdir()
  utils::untar(tarfile, exdir = exdir)

  root <- list.dirs(exdir, recursive = FALSE)[[1]]

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
    list.files(path = dest, full.names = TRUE) |>
      file.remove()
  } else {
    dir.create(path = dest, recursive = TRUE)
  }

  file.copy(from = files, to = dest)

  invisible(dest)
}
