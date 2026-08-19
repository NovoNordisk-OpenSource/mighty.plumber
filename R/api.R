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
#' @param path `character(1)` directory holding the components. Doubles as
#' the URL path the endpoint is served from.
#' @returns The `api` object, allowing for chaining with the pipe.
#' @seealso [mighty.component::list_components()],
#' [mighty.component::get_component()]
#' @export
api_component <- function(api, path) {
  api |>
    plumber2::api_get(
      path = path,
      handler = \() mighty.component::list_components(path = path)
    ) |>
    plumber2::api_get(
      path = paste0(path, "/<id:string>"),
      handler = \(id) {
        tryCatch(
          expr = mighty.component::get_component(
            component = id,
            repos = path
          )$template,
          error = \(e) {
            plumber2::abort_not_found(
              detail = paste0("Unknown component: ", id)
            )
          }
        )
      }
    )
}
