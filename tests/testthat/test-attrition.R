test_that("observed units and last sightings are counted per time point", {
  result <- attrition(toy, "unit", "t")
  expect_equal(
    result,
    data.frame(t = c(1, 2, 3, 4), n_units = 4L,
               n_observed = c(3L, 4L, 2L, 3L),
               pct_observed = c(75, 100, 50, 75),
               n_dropped_after = c(0L, 1L, 0L, 0L))
  )
})

test_that("`var` counts a unit only when the value is not NA", {
  result <- attrition(toy, "unit", "t", var = "x")
  expect_equal(result$n_observed, c(3L, 3L, 2L, 3L))
})

test_that("counts agree with the visits data", {
  result <- attrition(visits, "patient", "visit")
  expect_equal(result$n_observed, as.integer(table(visits$visit)))
  expect_equal(result$n_observed[1], 60L)
  # everyone who is not seen at the final visit was last seen somewhere earlier
  expect_equal(sum(result$n_dropped_after), 60L - result$n_observed[5])
})
