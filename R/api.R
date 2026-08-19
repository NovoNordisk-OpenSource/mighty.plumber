#' Get component template
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
      mighty.component::get_component(
        component = query$id,
        repos = path
      )$template
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
