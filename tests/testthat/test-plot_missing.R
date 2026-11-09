test_that("the plot has one tile per unit and time point with the right status", {
  plot <- plot_missing(toy, "x", "unit", "t")
  expect_s3_class(plot, "ggplot")
  expect_equal(nrow(plot$data), 16)
  expect_equal(as.integer(table(plot$data$status)), c(11L, 1L, 4L))
  expect_equal(levels(plot$data$status),
               c("Observed", "Value missing", "Row absent"))
})

test_that("only one variable can be plotted", {
  expect_error(plot_missing(toy, c("x", "group"), "unit", "t"),
               "single column")
})
