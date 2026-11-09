# Simulated follow-up data for 60 patients over 5 planned visits.
# Run this script from the package root to rebuild data/visits.rda.

set.seed(5233)

n_patients <- 60
n_visits <- 5

patients <- data.frame(
  patient = sprintf("P%03d", seq_len(n_patients)),
  sex = sample(c("Female", "Male"), n_patients, replace = TRUE),
  baseline_sbp = rnorm(n_patients, mean = 135, sd = 12),
  baseline_weight = rnorm(n_patients, mean = 78, sd = 11),
  # the last visit each patient attends: most stay to the end, some drop out
  last_visit = sample(1:5, n_patients, replace = TRUE,
                      prob = c(0.04, 0.06, 0.08, 0.10, 0.72))
)

visits <- merge(patients, data.frame(visit = seq_len(n_visits)))
visits <- visits[order(visits$patient, visits$visit), ]

visits$sbp <- round(visits$baseline_sbp - 1.5 * (visits$visit - 1) +
                      rnorm(nrow(visits), sd = 6))
visits$weight <- round(visits$baseline_weight +
                         rnorm(nrow(visits), sd = 1.5), 1)

# dropout: no rows after a patient's last visit
visits <- visits[visits$visit <= visits$last_visit, ]

# missed visits: a patient skips one visit and comes back for the next.
# P002 is forced to skip visit 3 so the help pages have a fixed example.
visits$last_visit[visits$patient == "P002"] <- 5
if (!any(visits$patient == "P002" & visits$visit == 4)) {
  stop("P002 dropped out early under this seed; choose another patient.")
}
interior <- visits$visit > 1 & visits$visit < visits$last_visit
skipped <- interior & runif(nrow(visits)) < 0.06
skipped[visits$patient == "P002"] <- visits$visit[visits$patient == "P002"] == 3
visits <- visits[!skipped, ]

# values not recorded even though the patient attended
visits$sbp[runif(nrow(visits)) < 0.04] <- NA
visits$weight[runif(nrow(visits)) < 0.03 * visits$visit] <- NA

visits <- visits[, c("patient", "visit", "sex", "sbp", "weight")]
visits$visit <- as.integer(visits$visit)
rownames(visits) <- NULL

save(visits, file = "data/visits.rda", compress = "bzip2")
