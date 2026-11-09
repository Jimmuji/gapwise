#' Plot which units are missing a variable at which time points
#'
#' Draws one tile for every unit at every time point, coloured by whether
#' the value was observed, the row is present but the value is `NA`, or the
#' row is absent altogether. Units are ordered so that those with the most
#' missing data are at the top.
#'
#' Unit labels are hidden when there are more than 40 units, because they
#' would overlap. [miss_by_time()] gives the same information as numbers.
#'
#' @inheritParams check_panel
#' @param var Name of the column to plot, in quotes.
#'
#' @return A `ggplot` object, which can be changed further with the usual
#'   ggplot2 functions.
#'
#' @examples
#' plot_missing(visits, var = "sbp", id = "patient", time = "visit")
#'
#' @importFrom ggplot2 .data
#' @export
plot_missing <- function(data, var, id, time, times = NULL) {
  check_columns(data, id, time)
  check_vars(data, var, arg = "var")
  if (length(var) != 1) {
    stop("`var` must name a single column.", call. = FALSE)
  }

  filled <- fill_panel(data, id, time, times = times, flag = TRUE)
  status_levels <- c("Observed", "Value missing", "Row absent")
  status <- ifelse(filled$.filled, "Row absent",
                   ifelse(is.na(filled[[var]]), "Value missing", "Observed"))

  # units with the most missing data go at the top of the plot
  n_missing <- tapply(status != "Observed", as.character(filled[[id]]), sum)
  unit_order <- names(sort(n_missing))

  plot_data <- data.frame(
    unit = factor(as.character(filled[[id]]), levels = unit_order),
    time = factor(as.character(filled[[time]]),
                  levels = as.character(sort(unique(filled[[time]])))),
    status = factor(status, levels = status_levels)
  )

  plot <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = .data$time, y = .data$unit, fill = .data$status)
  ) +
    ggplot2::geom_tile(colour = "white", linewidth = 0.2) +
    ggplot2::scale_fill_manual(
      values = c("Observed" = "#2a78d6", "Value missing" = "#eb6834",
                 "Row absent" = "#1baf7a"),
      drop = FALSE, name = NULL
    ) +
    ggplot2::scale_x_discrete(expand = c(0, 0)) +
    ggplot2::scale_y_discrete(expand = c(0, 0)) +
    ggplot2::labs(x = time, y = id,
                  title = paste0("Missing data in `", var, "`")) +
    ggplot2::theme_minimal() +
    ggplot2::theme(panel.grid = ggplot2::element_blank(),
                   legend.position = "top")

  if (length(unit_order) > 40) {
    plot <- plot +
      ggplot2::theme(axis.text.y = ggplot2::element_blank(),
                     axis.ticks.y = ggplot2::element_blank())
  }
  plot
}
