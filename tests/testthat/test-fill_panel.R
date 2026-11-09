test_that("absent rows are added with NA and the result is balanced", {
  filled <- fill_panel(toy, "unit", "t")
  expect_equal(nrow(filled), 16)
  expect_equal(names(filled), names(toy))
  expect_true(check_panel(filled, "unit", "t")$balanced)
  expect_equal(filled$unit, rep(c("A", "B", "C", "D"), each = 4))
  expect_equal(filled$t, rep(1:4, times = 4))
  # B at time 3 is new, so x is NA there and unchanged elsewhere
  expect_equal(filled$x[filled$unit == "B"], c(20, 21, NA, 23))
})

test_that("existing values are never changed", {
  filled <- fill_panel(toy, "unit", "t")
  back <- merge(toy, filled, by = c("unit", "t"), suffixes = c("", ".filled"))
  expect_equal(nrow(back), nrow(toy))
  expect_equal(back$x, back$x.filled)
})

test_that("`constant` columns are copied into added rows", {
  plain <- fill_panel(toy, "unit", "t")
  expect_true(is.na(plain$group[plain$unit == "B" & plain$t == 3]))
  kept <- fill_panel(toy, "unit", "t", constant = "group")
  expect_equal(kept$group, rep(c("u", "v", "u", "v"), each = 4))
  expect_error(fill_panel(toy, "unit", "t", constant = "x"),
               "more than one value within a unit")
})

test_that("`flag` marks exactly the added rows", {
  filled <- fill_panel(toy, "unit", "t", flag = TRUE)
  expect_equal(sum(filled$.filled), 4)
  expect_equal(filled$t[filled$.filled], c(3, 3, 4, 1))
})

test_that("column types survive, including factors and dates", {
  typed <- data.frame(
    unit = factor(c("A", "A", "B")),
    day = as.Date(c("2026-01-01", "2026-01-02", "2026-01-01")),
    n = c(1L, 2L, 3L)
  )
  filled <- fill_panel(typed, "unit", "day")
  expect_s3_class(filled$unit, "factor")
  expect_s3_class(filled$day, "Date")
  expect_type(filled$n, "integer")
  expect_equal(filled$n, c(1L, 2L, 3L, NA))
})

test_that("duplicates and missing keys are refused", {
  expect_error(fill_panel(rbind(toy, toy[1, ]), "unit", "t"),
               "more than one row")
  broken <- toy
  broken$t[1] <- NA
  expect_error(fill_panel(broken, "unit", "t"), "missing values")
})
