#' Serve mighty components from a directory
#' @description
#' Adds a `GET` endpoint at `path` serving the components found in the
#' directory of the same name. Without an `id` query parameter the endpoint
#' lists the available component IDs. With one it returns that component's
#' template, or `404` if no such component exists.
#'
#' Call once per component directory to serve each from its own endpoint.
#'
#' @param api a `plumber2` api object to add the endpoint to.
#' @param path `character(1)` directory holding the components. Doubles as
#' the URL path the endpoint is served from.
#' @returns The `api` object, allowing for chaining with the pipe.
#' @seealso [mighty.component::list_components()],
#' [mighty.component::get_component()]
#' @export
api_component <- function(api, path) {
  plumber2::api_get(
    api = api,
    path = path,
    handler = \(query) {
      if (is.null(query$id)) {
        return(
          mighty.component::list_components(path = path)
        )
      }
      tryCatch(
        expr = mighty.component::get_component(
          component = query$id,
          repos = path
        )$template,
        error = \(e) {
          plumber2::abort_not_found(
            detail = paste0("Unknown component: ", query$id)
          )
        }
      )
    },
    doc = list(
      parameters = list(
        list(
          name = "id",
          "in" = "query",
          required = FALSE,
          schema = list(type = "string")
        )
      )
    )
  )
}
