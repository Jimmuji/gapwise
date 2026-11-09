test_that("a complete data set is reported as balanced", {
  complete <- expand.grid(unit = c("A", "B"), t = 1:3)
  result <- check_panel(complete, "unit", "t")
  expect_true(result$balanced)
  expect_equal(result$n_units, 2)
  expect_equal(result$n_expected, 6)
  expect_equal(nrow(result$absent), 0)
  expect_equal(nrow(result$duplicates), 0)
})

test_that("absent rows are found and placed correctly", {
  result <- check_panel(toy, "unit", "t")
  expect_false(result$balanced)
  expect_equal(result$n_expected, 16)
  expect_equal(result$n_rows, 12)
  expect_equal(
    result$absent,
    data.frame(unit = c("B", "C", "C", "D"), t = c(3, 3, 4, 1),
               position = c("gap", "after last", "after last", "before first"))
  )
})

test_that("duplicated combinations are listed with their row count", {
  doubled <- rbind(toy, toy[c(1, 1, 5), ])
  result <- check_panel(doubled, "unit", "t")
  expect_false(result$balanced)
  expect_equal(result$duplicates,
               data.frame(unit = c("A", "B"), t = c(1, 1), n_rows = c(3L, 2L)))
})

test_that("rows with a missing unit or time point are counted", {
  broken <- toy
  broken$unit[1] <- NA
  broken$t[5] <- NA
  result <- check_panel(broken, "unit", "t")
  expect_equal(result$n_missing_keys, 2)
  expect_false(result$balanced)
})

test_that("`times` detects a time point that nobody has", {
  complete <- expand.grid(unit = c("A", "B"), t = c(1, 2, 4))
  expect_true(check_panel(complete, "unit", "t")$balanced)
  result <- check_panel(complete, "unit", "t", times = 1:4)
  expect_false(result$balanced)
  expect_equal(result$absent$t, c(3, 3))
  expect_equal(result$absent$position, c("gap", "gap"))
})

test_that("bad input gives a readable error", {
  expect_error(check_panel(1:3, "unit", "t"), "must be a data frame")
  expect_error(check_panel(toy, "nope", "t"), "no column called 'nope'")
  expect_error(check_panel(toy, "unit", "unit"), "two different columns")
  expect_error(check_panel(toy, "unit", "t", times = 1:2), "leaves out")
})

test_that("the shipped data sets have the documented structure", {
  expect_true(check_panel(conflict, "iso", "year")$balanced)
  result <- check_panel(visits, "patient", "visit")
  expect_equal(result$n_units, 60)
  expect_equal(result$n_expected, 300)
  expect_equal(result$n_rows, 240)
  expect_true(any(result$absent$patient == "P002" & result$absent$visit == 3 &
                    result$absent$position == "gap"))
})

test_that("the print method runs and returns its input", {
  result <- check_panel(toy, "unit", "t")
  expect_output(returned <- print(result), "Balanced: no")
  expect_identical(returned, result)
})
