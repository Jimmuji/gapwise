#' Check whether every unit has one row at every time point
#'
#' Repeated measures data should have exactly one row for each unit at each
#' time point. `check_panel()` reports the three ways this can fail: a unit
#' and time point that appear on more than one row, a unit and time point
#' with no row at all, and rows where the unit or the time point is itself
#' missing.
#'
#' A row that is absent is classified by where it falls for that unit:
#' `"before first"` (the unit had not yet been observed), `"gap"` (the unit
#' was observed both earlier and later), or `"after last"` (the unit was
#' never observed again).
#'
#' @param data A data frame in long format, with one row per unit and time
#'   point.
#' @param id Name of the column that identifies the unit, in quotes, for
#'   example `"patient"`.
#' @param time Name of the column that identifies the time point, in quotes,
#'   for example `"visit"`.
#' @param times Optional vector of the time points every unit is expected to
#'   have, for example `1:5`. By default this is every time point that
#'   appears anywhere in `data`, which cannot detect a time point that is
#'   absent for all units.
#'
#' @return A list of class `panel_check` with these elements:
#' \describe{
#'   \item{balanced}{`TRUE` if every unit has exactly one row at every
#'     expected time point and no row has a missing unit or time point.}
#'   \item{n_units}{Number of distinct units.}
#'   \item{times}{The expected time points.}
#'   \item{n_expected}{Number of rows a complete data set would have.}
#'   \item{n_rows}{Number of rows in `data`.}
#'   \item{n_missing_keys}{Number of rows where the unit or the time point is
#'     missing. These rows are left out of the other counts.}
#'   \item{duplicates}{Data frame of the unit and time point combinations
#'     that appear on more than one row, with the number of rows in `n_rows`.}
#'   \item{absent}{Data frame of the unit and time point combinations that
#'     have no row, with their classification in `position`.}
#' }
#'
#' @examples
#' result <- check_panel(visits, id = "patient", time = "visit")
#' result
#'
#' # the combinations that have no row
#' head(result$absent)
#'
#' # the country data are complete
#' check_panel(conflict, id = "iso", time = "year")$balanced
#'
#' @export
check_panel <- function(data, id, time, times = NULL) {
  check_columns(data, id, time)

  # rows without a unit or a time point cannot be placed in the grid, so they
  # are counted separately and set aside
  missing_key <- is.na(data[[id]]) | is.na(data[[time]])
  kept <- data[!missing_key, , drop = FALSE]

  all_times <- expected_times(kept[[time]], times)
  ids <- sort(unique(kept[[id]]))
  key <- make_key(kept[[id]], kept[[time]])

  # combinations that appear on more than one row
  repeated <- duplicated(key) | duplicated(key, fromLast = TRUE)
  repeated_keys <- unique(key[repeated])
  first_row <- match(repeated_keys, key)
  duplicates <- kept[first_row, c(id, time), drop = FALSE]
  duplicates$n_rows <- as.integer(table(key[repeated])[repeated_keys])
  rownames(duplicates) <- NULL

  # combinations that have no row
  grid <- full_grid(ids, all_times, id, time)
  absent <- grid[!make_key(grid[[id]], grid[[time]]) %in% key, , drop = FALSE]

  # place each absent row relative to the first and last time point at which
  # its unit was observed, using positions in `all_times` so that this works
  # for numbers, dates and text alike
  position_seen <- match(kept[[time]], all_times)
  unit_seen <- match(kept[[id]], ids)
  first_seen <- tapply(position_seen, unit_seen, min)
  last_seen <- tapply(position_seen, unit_seen, max)
  absent_position <- match(absent[[time]], all_times)
  absent_unit <- as.character(match(absent[[id]], ids))
  absent_first <- as.vector(first_seen[absent_unit])
  absent_last <- as.vector(last_seen[absent_unit])
  absent$position <- ifelse(
    absent_position < absent_first, "before first",
    ifelse(absent_position > absent_last, "after last", "gap")
  )
  rownames(absent) <- NULL

  structure(
    list(
      balanced = nrow(duplicates) == 0 && nrow(absent) == 0 &&
        !any(missing_key),
      n_units = length(ids),
      times = all_times,
      n_expected = length(ids) * length(all_times),
      n_rows = nrow(data),
      n_missing_keys = sum(missing_key),
      duplicates = duplicates,
      absent = absent,
      id = id,
      time = time
    ),
    class = "panel_check"
  )
}

#' @export
print.panel_check <- function(x, ...) {
  shown <- utils::head(x$times, 6)
  time_text <- paste(as.character(shown), collapse = ", ")
  if (length(x$times) > 6) {
    time_text <- paste0(time_text, ", ... , ",
                        as.character(x$times[length(x$times)]))
  }
  where <- table(factor(x$absent$position,
                        levels = c("before first", "gap", "after last")))

  cat("Units (", x$id, "): ", x$n_units, "\n", sep = "")
  cat("Time points (", x$time, "): ", length(x$times), " (", time_text, ")\n",
      sep = "")
  cat("Rows: ", x$n_rows, " found, ", x$n_expected, " expected\n", sep = "")
  cat("Balanced: ", if (x$balanced) "yes" else "no", "\n", sep = "")
  cat("Duplicated combinations: ", nrow(x$duplicates), "\n", sep = "")
  cat("Absent rows: ", nrow(x$absent), sep = "")
  if (nrow(x$absent) > 0) {
    cat(" (before first: ", where[["before first"]], ", gap: ", where[["gap"]],
        ", after last: ", where[["after last"]], ")", sep = "")
  }
  cat("\n")
  cat("Rows with a missing ", x$id, " or ", x$time, ": ", x$n_missing_keys,
      "\n", sep = "")
  if (!x$balanced) {
    cat("See $duplicates and $absent for the rows involved.\n")
  }
  invisible(x)
}
