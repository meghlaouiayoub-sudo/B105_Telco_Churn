
# ============================================================
# B105 Applied Statistical Modelling
# 01 - Data import and initial inspection
# Dataset: IBM Telco Customer Churn (Kaggle)
# ============================================================

library(dplyr); library(tidyr); library(readr)
set.seed(2026)          # reproducibility for every random operation

# ---- Import the dataset ----
raw <- read.csv("data/telco.csv", stringsAsFactors = FALSE)

# ---- Initial inspection ----
dim(raw)                            # rows and columns
str(raw)                            # variable types
sum(duplicated(raw$customerID))     # duplicate customers?
colSums(is.na(raw))                 # missing values per column
table(raw$Churn)                    # response distribution# 

# Cleaning decisions - each one justified, not a default rule


telco <- raw

# (a) Inspect the 11 unusable TotalCharges before deciding what to do
blank_tc <- telco[is.na(telco$TotalCharges),
                  c("customerID","tenure","MonthlyCharges","TotalCharges","Churn")]
print(blank_tc)
cat("Number of unusable TotalCharges:", nrow(blank_tc), "\n")
cat("All of them have tenure == 0:", all(blank_tc$tenure == 0), "\n")
table(blank_tc$Churn)

# All 11 are tenure = 0 customers: acquired but not yet billed.
# The economically correct value is 0, not missing.
telco$TotalCharges[is.na(telco$TotalCharges)] <- 0

# (b) customerID is a unique key with no statistical content
telco$customerID <- NULL

# (c) SeniorCitizen is coded 0/1 but is categorical
telco$SeniorCitizen <- factor(telco$SeniorCitizen, levels = c(0,1), labels = c("No","Yes"))

# (d) "No internet service" / "No phone service" duplicate information
#     already carried by InternetService and PhoneService
collapse_vars <- c("MultipleLines","OnlineSecurity","OnlineBackup",
                   "DeviceProtection","TechSupport","StreamingTV","StreamingMovies")
for (v in collapse_vars) {
  telco[[v]][telco[[v]] %in% c("No internet service","No phone service")] <- "No"
}

# (e) Remaining character columns become factors
chr_vars <- names(telco)[sapply(telco, is.character)]
telco[chr_vars] <- lapply(telco[chr_vars], factor)

# (f) Reference levels set so coefficients answer the business questions
telco$Churn           <- relevel(telco$Churn,           ref = "No")
telco$Contract        <- relevel(telco$Contract,        ref = "Month-to-month")
telco$InternetService <- relevel(telco$InternetService, ref = "DSL")
telco$PaymentMethod   <- relevel(telco$PaymentMethod,   ref = "Electronic check")

# ---- Post-cleaning checks ----
cat("Dimensions:", dim(telco), "\n")
cat("Any NA left:", sum(is.na(telco)), "\n")
cat("tenure range:", range(telco$tenure), "\n")
round(prop.table(table(telco$Churn)) * 100, 2)