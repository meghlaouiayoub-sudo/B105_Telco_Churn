# ============================================================
# B105 Applied Statistical Modelling
# 03 - Descriptive statistics
# ============================================================

library(dplyr); library(e1071)

num_vars <- c("tenure","MonthlyCharges","TotalCharges")

# Custom summary function: central tendency, spread and shape
describe <- function(x) {
  n <- length(x); m <- mean(x); s <- sd(x)
  data.frame(n = n, Mean = round(m, 2), SD = round(s, 2),
             Median = round(median(x), 2),
             Min = round(min(x), 2), Max = round(max(x), 2),
             Q1 = round(quantile(x, .25), 2), Q3 = round(quantile(x, .75), 2),
             IQR = round(IQR(x), 2),
             Skewness = round(skewness(x), 2),
             Kurtosis = round(kurtosis(x), 2))
}

# ---- Table 1: all customers ----
desc_all <- bind_rows(lapply(num_vars, function(v)
  cbind(Variable = v, describe(telco[[v]]))))
print(desc_all, row.names = FALSE)

# ---- Table 2: split by churn group ----
desc_grp <- bind_rows(lapply(num_vars, function(v)
  bind_rows(lapply(levels(telco$Churn), function(g)
    cbind(Variable = v, Churn = g, describe(telco[[v]][telco$Churn == g]))))))
print(desc_grp, row.names = FALSE)

# ---- Outlier screening (1.5 x IQR rule) ----
for (v in num_vars) {
  q <- quantile(telco[[v]], c(.25, .75)); iqr <- IQR(telco[[v]])
  lo <- q[1] - 1.5 * iqr; hi <- q[2] + 1.5 * iqr
  cat(sprintf("%-15s lower fence = %9.2f  upper fence = %9.2f  outliers = %d\n",
              v, lo, hi, sum(telco[[v]] < lo | telco[[v]] > hi)))
}