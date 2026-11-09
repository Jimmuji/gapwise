#' Add a lagged variable matched on the value of the time variable
#'
#' Creates a column holding the value a variable took `n` time points
#' earlier for the same unit. The earlier row is found by looking for the
#' time value `time - n`, not by taking the row above.
#'
#' The usual shortcut of sorting the data and shifting a column down by one
#' row is only correct when no rows are absent. If a patient missed visit 3,
#' the row above visit 4 is visit 2, and a row-based lag quietly reports the
#' visit 2 value as the previous one. `add_lag()` returns `NA` there, because
#' the value at visit 3 is not known. It also never carries a value across
#' from one unit to the next.
#'
#' @inheritParams check_panel
#' @param var Names of one or more columns to lag, in quotes.
#' @param time Name of the column that identifies the time point, in quotes.
#'   The column must be numeric or a date, in steps that can be subtracted:
#'   visit numbers, years, or dates.
#' @param n How many units of time to look back. A single positive whole
#'   number. For a date column this is a number of days.
#' @param name Names for the new columns. By default each is the original
#'   name followed by `_lag` and `n`, for example `sbp_lag1`.
#'
#' @return `data` with one added column per variable in `var`. The rows keep
#'   their original order.
#'
#' @examples
#' lagged <- add_lag(visits, var = "sbp", id = "patient", time = "visit")
#'
#' # patient P002 has no row for visit 3, so the lag at visit 4 is NA
#' # rather than the value from visit 2
#' lagged[lagged$patient == "P002", c("patient", "visit", "sbp", "sbp_lag1")]
#'
#' # exposure to armed conflict in the previous year
#' conflict_lagged <- add_lag(conflict, var = "armedconflict", id = "iso",
#'                            time = "year")
#' head(conflict_lagged[, c("iso", "year", "armedconflict",
#'                          "armedconflict_lag1")])
#'
#' @export
add_lag <- function(data, var, id, time, n = 1, name = NULL) {
  check_columns(data, id, time)
  check_vars(data, var, arg = "var")

  time_values <- data[[time]]
  if (!is.numeric(time_values) && !inherits(time_values, "Date")) {
    stop("`", time, "` must be numeric or a date so that earlier time points ",
         "can be found by subtraction.", call. = FALSE)
  }
  require_clean_keys(data, id, time)
  if (!is.numeric(n) || length(n) != 1 || is.na(n) || n < 1 || n != round(n)) {
    stop("`n` must be a single positive whole number.", call. = FALSE)
  }
  if (is.null(name)) {
    name <- paste0(var, "_lag", n)
  }
  if (!is.character(name) || length(name) != length(var)) {
    stop("`name` must give one new column name for each variable in `var`.",
         call. = FALSE)
  }

  # for every row, the row holding the same unit at time minus n, or NA when
  # there is no such row
  earlier_row <- match(make_key(data[[id]], time_values - n),
                       make_key(data[[id]], time_values))

  for (i in seq_along(var)) {
    data[[name[i]]] <- data[[var[i]]][earlier_row]
  }
  data
}
