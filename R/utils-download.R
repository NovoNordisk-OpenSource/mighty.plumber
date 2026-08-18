#' Download a repo tarball from GitHub
#'
#' @param spec `list` as returned by [remotes::parse_repo_spec()].
#' @param tarfile `character(1)` path to write the tarball to.
#' @returns `tarfile`.
#' @noRd
download_tar <- function(spec, tarfile) {
  endpoint <- "GET /repos/{owner}/{repo}/tarball"
  args <- list(owner = spec$username, repo = spec$repo, .destfile = tarfile)

  if (nzchar(spec$ref)) {
    endpoint <- paste0(endpoint, "/{ref}")
    args$ref <- spec$ref
  }

  do.call(gh::gh, c(list(endpoint = endpoint), args))

  tarfile
}

#' Extract a repo tarball and return its top-level directory
#'
#' GitHub tarballs contain a single generated top-level directory embedding a
#' commit SHA, so it is discovered rather than constructed.
#'
#' @param tarfile `character(1)` path to a tarball.
#' @param exdir `character(1)` directory to extract into.
#' @returns `character(1)` path to the extracted top-level directory.
#' @noRd
extract_tar <- function(tarfile, exdir) {
  utils::untar(tarfile, exdir = exdir)

  list.dirs(exdir, recursive = FALSE)[[1]]
}
