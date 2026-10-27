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
mighty.component::list_components(dest)
#> [1] "dummy"
```
