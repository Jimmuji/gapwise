test_that("absent rows and NA values are counted separately", {
  result <- miss_by_time(toy, "unit", "t", vars = "x")
  expect_equal(
    result,
    data.frame(variable = "x", t = c(1, 2, 3, 4), n_units = 4L,
               n_absent = c(1L, 0L, 2L, 1L), n_na = c(0L, 1L, 0L, 0L),
               n_missing = c(1L, 1L, 2L, 1L),
               pct_missing = c(25, 25, 50, 25))
  )
})

test_that("all other columns are summarised by default", {
  result <- miss_by_time(toy, "unit", "t")
  expect_equal(unique(result$variable), c("group", "x"))
  expect_equal(nrow(result), 8)
})

test_that("maternal mortality is missing everywhere in 2018 and 2019", {
  result <- miss_by_time(conflict, "iso", "year", vars = "matmor")
  expect_equal(result$n_missing[result$year %in% 2018:2019], c(186L, 186L))
  # three countries have no maternal mortality figure in any year
  expect_equal(result$n_missing[result$year < 2018], rep(3L, 18))
  expect_true(all(result$n_absent == 0))
})

test_that("unknown variables are refused", {
  expect_error(miss_by_time(toy, "unit", "t", vars = "nope"),
               "no column called 'nope'")
})
