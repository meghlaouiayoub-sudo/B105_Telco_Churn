# ============================================================
# B105 Applied Statistical Modelling
# 02 - Exploratory data analysis
# ============================================================

library(dplyr); library(ggplot2); library(scales)

# ---- Churn rate by every categorical variable ----
cat_vars <- c("Contract","InternetService","PaymentMethod","PaperlessBilling",
              "SeniorCitizen","TechSupport","OnlineSecurity","Partner",
              "Dependents","gender")

churn_by_cat <- bind_rows(lapply(cat_vars, function(v) {
  telco %>%
    group_by(Level = .data[[v]]) %>%
    summarise(n = n(), Churned = sum(Churn == "Yes"), .groups = "drop") %>%
    mutate(Variable = v, ChurnRate = round(100 * Churned / n, 2))
})) %>% select(Variable, Level, n, Churned, ChurnRate)

print(as.data.frame(churn_by_cat), row.names = FALSE)

# ---- Churn rate across the customer lifecycle ----
telco$TenureBand <- cut(telco$tenure,
                        breaks = c(-1, 6, 12, 24, 48, 72),
                        labels = c("0-6","7-12","13-24","25-48","49-72"))

tenure_band <- telco %>%
  group_by(TenureBand) %>%
  summarise(n = n(), ChurnRate = round(100 * mean(Churn == "Yes"), 2), .groups = "drop")

print(as.data.frame(tenure_band), row.names = FALSE)
