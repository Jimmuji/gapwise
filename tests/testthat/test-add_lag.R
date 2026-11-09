test_that("the lag is matched on time, not on the row above", {
  lagged <- add_lag(toy, "x", "unit", "t")
  expect_equal(
    lagged$x_lag1,
    c(NA, 10, NA, 12,   # A: x is NA at time 2, so time 3 has an NA lag
      NA, 20, NA,       # B: no row at time 3, so time 4 has an NA lag
      NA, 30,           # C
      NA, 41, 42)       # D: starts at time 2, nothing carried over from C
  )
})

test_that("a row-based lag gives a different, wrong answer where rows are absent", {
  row_based <- ave(toy$x, toy$unit, FUN = function(v) c(NA, v[-length(v)]))
  time_based <- add_lag(toy, "x", "unit", "t")$x_lag1
  b_at_4 <- toy$unit == "B" & toy$t == 4
  expect_equal(row_based[b_at_4], 21)
  expect_true(is.na(time_based[b_at_4]))
  expect_equal(time_based[!b_at_4], row_based[!b_at_4])
})

test_that("on complete data the result equals a row-based lag", {
  row_based <- ave(conflict$armedconflict, conflict$iso,
                   FUN = function(v) c(NA, v[-length(v)]))
  lagged <- add_lag(conflict, "armedconflict", "iso", "year")
  expect_equal(lagged$armedconflict_lag1, row_based)
  expect_equal(sum(is.na(lagged$armedconflict_lag1)), 186)
})

test_that("row order does not matter and is preserved", {
  set.seed(1)
  shuffled <- toy[sample(nrow(toy)), ]
  lagged <- add_lag(shuffled, "x", "unit", "t")
  expect_equal(lagged[, names(toy)], shuffled)
  reference <- add_lag(toy, "x", "unit", "t")
  restored <- lagged[order(lagged$unit, lagged$t), ]
  expect_equal(restored$x_lag1, reference$x_lag1)
})

test_that("longer lags, several variables and custom names work", {
  lagged <- add_lag(toy, "x", "unit", "t", n = 2)
  expect_equal(lagged$x_lag2[lagged$unit == "A"], c(NA, NA, 10, NA))
  expect_equal(lagged$x_lag2[lagged$unit == "B"], c(NA, NA, 21))

  both <- add_lag(toy, c("x", "group"), "unit", "t",
                  name = c("x_before", "group_before"))
  expect_true(all(c("x_before", "group_before") %in% names(both)))
  expect_equal(both$group_before[both$unit == "A"], c(NA, "u", "u", "u"))
})

test_that("date time points are lagged in days", {
  daily <- data.frame(
    unit = "A",
    day = as.Date(c("2026-01-01", "2026-01-02", "2026-01-04")),
    x = c(1, 2, 4)
  )
  expect_equal(add_lag(daily, "x", "unit", "day")$x_lag1, c(NA, 1, NA))
})

test_that("bad input gives a readable error", {
  expect_error(add_lag(toy, "nope", "unit", "t"), "no column called 'nope'")
  expect_error(add_lag(toy, "x", "unit", "group"), "numeric or a date")
  expect_error(add_lag(toy, "x", "unit", "t", n = 0), "positive whole number")
  expect_error(add_lag(toy, "x", "unit", "t", n = 1.5), "positive whole number")
  expect_error(add_lag(toy, "x", "unit", "t", name = c("a", "b")),
               "one new column name")
  expect_error(add_lag(rbind(toy, toy[1, ]), "x", "unit", "t"),
               "more than one row")
})
