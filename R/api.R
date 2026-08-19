#' Serve mighty components from a directory
#' @description
#' Adds two `GET` endpoints serving the components found in the directory
#' `path`:
#'
#' * `path` lists the available component IDs.
#' * `path/<id>` returns that component's template, or `404` if no such
#'   component exists.
#'
#' Call once per component directory to serve each from its own endpoints.
#'
#' @param api a `plumber2` api object to add the endpoint to.
#' @param path `character(1)` URL path the endpoint is served from.
#' @param folder `character(1)` directory holding the components.
#' @returns The `api` object, allowing for chaining with the pipe.
#' @seealso [mighty.component::list_components()],
#' [mighty.component::get_component()]
#' @export
api_component <- function(api, path, folder) {
  api |>
    api_list_component(path = path, folder = folder) |>
    api_get_component(path = path, folder = folder)
}

#' @noRd
api_list_component <- function(api, path, folder) {
  plumber2::api_get(
    api = api,
    path = path,
    handler = \() {
      mighty.component::list_components(path = folder)
    }
  )
}

#' @noRd
api_get_component <- function(api, path, folder) {
  plumber2::api_get(
    api = api,
    path = paste0(path, "/<id:string>"),
    handler = \(id) {
      get_component_template(
        component = id,
        repos = folder
      )
    }
  )
}

#' @noRd
get_component_template <- function(component, repos) {
  component <- tryCatch(
    expr = mighty.component::get_component(
      component = component,
      repos = repos
    ),
    error = \(e) {
      plumber2::abort_not_found(
        detail = e$message
      )
    }
  )

  component$template
}
