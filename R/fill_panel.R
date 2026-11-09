#' Add the rows that are absent so every unit has every time point
#'
#' When a unit was not observed at a time point, long data usually has no
#' row for it at all. `fill_panel()` adds those rows with `NA` in every
#' measured column, so that the missing observation can be seen and counted.
#'
#' @inheritParams check_panel
#' @param constant Optional names of columns whose value never changes within
#'   a unit, such as sex or country group. These are copied into the added
#'   rows instead of being left as `NA`.
#' @param flag If `TRUE`, a logical column called `.filled` is added, which
#'   is `TRUE` for the rows that `fill_panel()` created.
#'
#' @return A data frame with one row for every unit at every expected time
#'   point, sorted by unit and then by time. The columns of `data` keep their
#'   order and type.
#'
#' @examples
#' nrow(visits)
#'
#' filled <- fill_panel(visits, id = "patient", time = "visit",
#'                      constant = "sex", flag = TRUE)
#' nrow(filled)
#'
#' # patient P002 missed visit 3, which is now an explicit row
#' filled[filled$patient == "P002", ]
#'
#' @export
fill_panel <- function(data, id, time, times = NULL, constant = NULL,
                       flag = FALSE) {
  check_columns(data, id, time)
  require_clean_keys(data, id, time)
  if (!is.null(constant)) {
    check_vars(data, constant, arg = "constant")
  }
  if (!is.logical(flag) || length(flag) != 1 || is.na(flag)) {
    stop("`flag` must be TRUE or FALSE.", call. = FALSE)
  }

  all_times <- expected_times(data[[time]], times)
  ids <- sort(unique(data[[id]]))
  grid <- full_grid(ids, all_times, id, time)

  # indexing with NA returns a row of NAs while keeping each column's type,
  # which is what an added row should look like
  source_row <- match(make_key(grid[[id]], grid[[time]]),
                      make_key(data[[id]], data[[time]]))
  out <- data[source_row, , drop = FALSE]
  out[[id]] <- grid[[id]]
  out[[time]] <- grid[[time]]
  rownames(out) <- NULL

  for (column in constant) {
    known <- !is.na(data[[column]])
    values <- unique(data[known, c(id, column), drop = FALSE])
    if (anyDuplicated(values[[id]]) > 0) {
      stop("`", column, "` takes more than one value within a unit, so it ",
           "cannot be listed in `constant`.", call. = FALSE)
    }
    out[[column]] <- values[[column]][match(out[[id]], values[[id]])]
  }

  if (flag) {
    out$.filled <- is.na(source_row)
  }
  out
}
