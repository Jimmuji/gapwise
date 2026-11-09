# Country-year data from the CHL5233 armed conflict project.
# conflict.csv is a seven-column extract of that project's final data set
# (data/processed/final_data.csv in github.com/Jimmuji/armed_conflict).
# Run this script from the package root to rebuild data/conflict.rda.

conflict <- read.csv("data-raw/conflict.csv", stringsAsFactors = FALSE)
conflict <- conflict[order(conflict$iso, conflict$year), ]
conflict$year <- as.integer(conflict$year)
conflict$armedconflict <- as.integer(conflict$armedconflict)
conflict$oecd <- as.integer(conflict$oecd)
rownames(conflict) <- NULL

stopifnot(nrow(conflict) == 3720, !anyDuplicated(conflict[, c("iso", "year")]))

save(conflict, file = "data/conflict.rda", compress = "bzip2")
