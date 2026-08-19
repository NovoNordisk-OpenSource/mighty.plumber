# Serve mighty components from a directory

Adds two `GET` endpoints serving the components found in the directory
`path`:

- `path` lists the available component IDs.

- `path/<id>` returns that component's template, or `404` if no such
  component exists.

Call once per component directory to serve each from its own endpoints.

## Usage

``` r
api_component(api, path)
```

## Arguments

- api:

  a `plumber2` api object to add the endpoint to.

- path:

  `character(1)` directory holding the components. Doubles as the URL
  path the endpoint is served from.

## Value

The `api` object, allowing for chaining with the pipe.

## See also

[`mighty.component::list_components()`](https://novonordisk-opensource.github.io/mighty.component/reference/list_components.html),
[`mighty.component::get_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.html)
