#' Simulated follow-up visits for 60 patients
#'
#' A made-up cohort of 60 patients who were each meant to attend 5 visits.
#' The data have the problems that real follow-up data have: some patients
#' stop attending, some skip a visit and return for the next one, and some
#' measurements were not recorded at a visit the patient did attend. A visit
#' that was not attended has no row.
#'
#' Patient `P002` attended visits 1, 2, 4 and 5 but not visit 3, and is used
#' in the examples throughout the package.
#'
#' @format A data frame with 240 rows and 5 columns:
#' \describe{
#'   \item{patient}{Patient identifier, `"P001"` to `"P060"`.}
#'   \item{visit}{Visit number, 1 to 5.}
#'   \item{sex}{`"Female"` or `"Male"`. Does not change within a patient.}
#'   \item{sbp}{Systolic blood pressure in mmHg.}
#'   \item{weight}{Body weight in kilograms.}
#' }
#' @source Simulated. The script is `data-raw/visits.R` in the package
#'   repository.
"visits"

#' Armed conflict and mortality in 186 countries, 2000 to 2019
#'
#' One row per country and year, with every country present in every year.
#' No rows are absent, but several variables have missing values. The
#' maternal mortality ratio is missing for all countries in 2018 and 2019.
#'
#' @format A data frame with 3720 rows and 7 columns:
#' \describe{
#'   \item{iso}{ISO-3 country code.}
#'   \item{year}{Calendar year, 2000 to 2019.}
#'   \item{armedconflict}{1 if the country had an armed conflict with at
#'     least 25 battle-related deaths in that year, otherwise 0.}
#'   \item{matmor}{Maternal deaths per 100,000 live births.}
#'   \item{un5mor}{Deaths before age 5 per 1,000 live births.}
#'   \item{gdp_1000}{Gross domestic product per person, in thousands of US
#'     dollars.}
#'   \item{oecd}{1 if the country is a member of the OECD, otherwise 0.}
#' }
#' @source Assembled in CHL5233 from the replication data for Jawad M, Hone T,
#'   Vamos EP, Cetorelli V, Millett C (2021) "Implications of armed conflict
#'   for maternal and child health: A regression analysis of data from 181
#'   countries for 2000 to 2019", PLOS Medicine 18(9): e1003810.
"conflict"
