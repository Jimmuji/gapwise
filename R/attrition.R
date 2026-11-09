#' Count how many units are still observed at each time point
#'
#' Shows how the number of observed units changes over time, and at which
#' time points units were seen for the last time.
#'
#' @inheritParams check_panel
#' @param var Optional name of a column, in quotes. If given, a unit counts
#'   as observed at a time point only when this column is not `NA` there.
#'   By default a unit counts as observed whenever it has a row.
#'
#' @return A data frame with one row per time point, and these columns:
#' \describe{
#'   \item{time column}{The time point, under the original column name.}
#'   \item{n_units}{Number of units in the data.}
#'   \item{n_observed}{Units observed at this time point.}
#'   \item{pct_observed}{`n_observed` as a percentage of `n_units`.}
#'   \item{n_dropped_after}{Units observed at this time point and at no later
#'     one. It is zero at the final time point, where nothing later exists.}
#' }
#'
#' @examples
#' # by whether the patient attended
#' attrition(visits, id = "patient", time = "visit")
#'
#' # by whether blood pressure was actually recorded
#' attrition(visits, id = "patient", time = "visit", var = "sbp")
#'
#' @export
attrition <- function(data, id, time, var = NULL, times = NULL) {
  check_columns(data, id, time)
  require_clean_keys(data, id, time)
  if (!is.null(var)) {
    check_vars(data, var, arg = "var")
    if (length(var) != 1) {
      stop("`var` must name a single column.", call. = FALSE)
    }
  }

  all_times <- expected_times(data[[time]], times)
  n_units <- length(unique(data[[id]]))

  observed <- if (is.null(var)) data else data[!is.na(data[[var]]), ]
  position <- match(observed[[time]], all_times)
  last_position <- tapply(position, as.character(observed[[id]]), max)

  out <- data.frame(n_units = rep(n_units, length(all_times)))
  out[[time]] <- all_times
  out <- out[, c(time, "n_units")]
  out$n_observed <- tabulate(position, nbins = length(all_times))
  out$pct_observed <- round(100 * out$n_observed / n_units, 1)
  out$n_dropped_after <- tabulate(last_position, nbins = length(all_times))
  out$n_dropped_after[length(all_times)] <- 0L
  out
}
