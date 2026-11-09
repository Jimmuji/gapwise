#' Count missing values at each time point
#'
#' For each variable and each time point, counts how many units have no
#' usable value. The count separates the two reasons a value can be missing:
#' the unit has no row at that time point (`n_absent`), or the row is there
#' but the value is `NA` (`n_na`).
#'
#' @inheritParams check_panel
#' @param vars Names of the columns to summarise, in quotes. By default every
#'   column other than `id` and `time`.
#'
#' @return A data frame with one row per variable and time point, and these
#'   columns:
#' \describe{
#'   \item{variable}{Name of the variable.}
#'   \item{time column}{The time point, under the original column name.}
#'   \item{n_units}{Number of units in the data.}
#'   \item{n_absent}{Units with no row at this time point.}
#'   \item{n_na}{Units with a row at this time point but an `NA` value.}
#'   \item{n_missing}{`n_absent` plus `n_na`.}
#'   \item{pct_missing}{`n_missing` as a percentage of `n_units`.}
#' }
#'
#' @examples
#' miss_by_time(visits, id = "patient", time = "visit",
#'              vars = c("sbp", "weight"))
#'
#' # maternal mortality is missing for every country in 2018 and 2019
#' mm <- miss_by_time(conflict, id = "iso", time = "year", vars = "matmor")
#' tail(mm, 4)
#'
#' @export
miss_by_time <- function(data, id, time, vars = NULL, times = NULL) {
  check_columns(data, id, time)
  if (is.null(vars)) {
    vars <- setdiff(names(data), c(id, time))
  }
  check_vars(data, vars)

  filled <- fill_panel(data, id, time, times = times, flag = TRUE)
  all_times <- expected_times(data[[time]], times)
  n_units <- length(unique(data[[id]]))
  time_position <- match(filled[[time]], all_times)

  one_variable <- function(variable) {
    absent <- filled$.filled
    na_value <- !absent & is.na(filled[[variable]])
    out <- data.frame(variable = variable, stringsAsFactors = FALSE)[
      rep(1, length(all_times)), , drop = FALSE]
    out[[time]] <- all_times
    out$n_units <- n_units
    out$n_absent <- as.integer(tapply(absent, time_position, sum))
    out$n_na <- as.integer(tapply(na_value, time_position, sum))
    out$n_missing <- out$n_absent + out$n_na
    out$pct_missing <- round(100 * out$n_missing / n_units, 1)
    out
  }

  result <- do.call(rbind, lapply(vars, one_variable))
  rownames(result) <- NULL
  result
}
