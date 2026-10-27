# Download all mighty components from a repo location

Download every mighty component (`.R` and `.mustache` files) found in a
GitHub repo location and write them to a local directory.

The resulting directory can be passed to
[`mighty.component::list_components()`](https://novonordisk-opensource.github.io/mighty.component/reference/list_components.html).

## Usage

``` r
download_components(repo, dest, overwrite = FALSE)
```

## Arguments

- repo:

  `character(1)` location spec: `owner/repo`, `owner/repo/subdir`, or
  `owner/repo@ref`. When a subdir is given, only that folder is
  searched.

- dest:

  `character(1)` directory to write component files into. Created if it
  does not exist. Any existing `.R` and `.mustache` files are removed
  first, so components deleted upstream do not linger. Other files are
  left untouched.

- overwrite:

  `logical(1)` allow writing to a non-empty `dest`. Errors if `FALSE`
  and `dest` is not empty.

## Value

`dest`, invisibly.

## Details

Components are searched for recursively below the given location, so
both a flat folder and the one-directory-per-component layout are
supported:

    components/dummy/dummy.mustache

Files named `test-*` are treated as component tests and are not
downloaded. Matching files are written flat into `dest`, discarding
their directory structure.

## Examples

``` r
dest <- withr::local_tempdir()
download_components(
  repo = "NovoNordisk-OpenSource/mighty.standards/components",
  dest = dest
)
#> Error in (function (endpoint, ..., per_page = NULL, .per_page = NULL,     .token = NULL, .destfile = NULL, .overwrite = FALSE, .api_url = NULL,     .method = "GET", .limit = NULL, .accept = "application/vnd.github.v3+json",     .send_headers = NULL, .progress = TRUE, .params = list(),     .max_wait = 600, .max_rate = NULL) {    params <- .parse_params(..., .params = .params)    check_exclusive(per_page, .per_page, .require = FALSE)    per_page <- per_page %||% .per_page    if (is.null(per_page) && !is.null(.limit)) {        per_page <- max(min(.limit, 100), 1)    }    if (!is.null(per_page)) {        params <- c(params, list(per_page = per_page))    }    req <- gh_build_request(endpoint = endpoint, params = params,         token = .token, destfile = .destfile, overwrite = .overwrite,         accept = .accept, send_headers = .send_headers, max_wait = .max_wait,         max_rate = .max_rate, api_url = .api_url, method = .method)    if (req$method == "GET") {        check_named_nas(params)    }    if (is.null(.limit)) {        raw <- gh_make_request(req)        return(gh_process_response(raw, req))    }    res <- gh_paginate(req, .limit, per_page, .progress)    len <- attr(res, "gh_pagination_length")    attr(res, "gh_pagination_length") <- NULL    if (len > .limit && !"total_count" %in% names(res) && length(res) ==         len) {        res_attr <- attributes(res)        res <- res[seq_len(.limit)]        attributes(res) <- res_attr    }    res})(endpoint = "GET /repos/{owner}/{repo}/tarball", owner = "NovoNordisk-OpenSource",     repo = "mighty.standards", .destfile = "/tmp/Rtmpn4xbjt/file1bb44ecb75c7.tar.gz"): GitHub API error (403): API rate limit exceeded for 52.165.58.39. (But
#> here's the good news: Authenticated requests get a higher rate limit. Check out
#> the documentation for more details.)
#> ℹ Read more at
#>   <https://docs.github.com/rest/overview/resources-in-the-rest-api#rate-limiting>
mighty.component::list_components(dest)
#> Error: <mighty.component::mighty_repo_local> object is invalid:
#> - Directory /tmp/Rtmpn4xbjt/file1bb47a852320 does not exist
```
