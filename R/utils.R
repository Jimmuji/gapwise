# Internal helpers shared by the exported functions. None of these are
# exported, so they have no help pages.

# Stop unless `data` is a data frame and `id` and `time` each name one of its
# columns.
check_columns <- function(data, id, time) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  args <- list(id = id, time = time)
  for (arg in names(args)) {
    value <- args[[arg]]
    if (!is.character(value) || length(value) != 1 || is.na(value)) {
      stop("`", arg, "` must be a single column name in quotes.", call. = FALSE)
    }
    if (!value %in% names(data)) {
      stop("`data` has no column called '", value, "'.", call. = FALSE)
    }
  }
  if (id == time) {
    stop("`id` and `time` must be two different columns.", call. = FALSE)
  }
  invisible(TRUE)
}

# Stop unless every name in `vars` is a column of `data`.
check_vars <- function(data, vars, arg = "vars") {
  if (!is.character(vars) || length(vars) == 0 || anyNA(vars)) {
    stop("`", arg, "` must be one or more column names in quotes.",
         call. = FALSE)
  }
  unknown <- setdiff(vars, names(data))
  if (length(unknown) > 0) {
    stop("`data` has no column called '", paste(unknown, collapse = "', '"),
         "'.", call. = FALSE)
  }
  invisible(TRUE)
}

# One string per row that identifies its unit and time point. Two rows get the
# same key exactly when they share both values.
make_key <- function(id, time) {
  paste(as.character(id), as.character(time), sep = "\r")
}

# The time points every unit is expected to have: the ones supplied by the
# user, or otherwise every time point seen anywhere in the data.
expected_times <- function(observed, times = NULL) {
  if (is.null(times)) {
    return(sort(unique(observed)))
  }
  if (anyNA(times) || anyDuplicated(times) > 0) {
    stop("`times` must not contain missing or repeated values.", call. = FALSE)
  }
  outside <- setdiff(as.character(unique(observed)), as.character(times))
  if (length(outside) > 0) {
    stop("`times` leaves out time points that appear in the data: ",
         paste(utils::head(outside, 5), collapse = ", "),
         if (length(outside) > 5) ", ..." else "", ".", call. = FALSE)
  }
  sort(times)
}

# Every combination of unit and expected time point, sorted by unit and then
# by time, in a two-column data frame named after the original columns.
full_grid <- function(ids, times, id, time) {
  grid <- data.frame(rep(ids, each = length(times)),
                     rep(times, times = length(ids)),
                     stringsAsFactors = FALSE)
  names(grid) <- c(id, time)
  grid
}

# Functions that need one row per unit and time point call this first. It
# stops with a pointer to check_panel() when that assumption does not hold.
require_clean_keys <- function(data, id, time) {
  if (anyNA(data[[id]]) || anyNA(data[[time]])) {
    stop("`", id, "` or `", time, "` has missing values. ",
         "Run check_panel() to see how many rows are affected.", call. = FALSE)
  }
  if (anyDuplicated(make_key(data[[id]], data[[time]])) > 0) {
    stop("Some combinations of `", id, "` and `", time,
         "` appear on more than one row. ",
         "Run check_panel() and look at $duplicates to find them.",
         call. = FALSE)
  }
  invisible(TRUE)
}
