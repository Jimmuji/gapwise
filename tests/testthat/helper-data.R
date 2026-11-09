# A small data set with known problems, used across the test files.
# Unit A is complete. Unit B has no row at time 3 (a gap). Unit C stops after
# time 2. Unit D starts at time 2. x is NA for A at time 2.
toy <- data.frame(
  unit = c("A", "A", "A", "A", "B", "B", "B", "C", "C", "D", "D", "D"),
  t = c(1, 2, 3, 4, 1, 2, 4, 1, 2, 2, 3, 4),
  group = c("u", "u", "u", "u", "v", "v", "v", "u", "u", "v", "v", "v"),
  x = c(10, NA, 12, 13, 20, 21, 23, 30, 31, 41, 42, 43),
  stringsAsFactors = FALSE
)
