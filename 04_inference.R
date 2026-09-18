# ============================================================
# B105 Applied Statistical Modelling
# 04 - Inferential statistics: H1, H2, H3
# ============================================================

library(car); library(vcd)

# ============================================================
# H1: Churn is independent of contract type
# Two categorical variables -> chi-square test of independence
# ============================================================

tab1 <- table(telco$Contract, telco$Churn)
print(tab1)
cat("\n-- Row percentages (churn rate per contract) --\n")
print(round(100 * prop.table(tab1, 1), 2))

# ASSUMPTION: all expected frequencies must be >= 5
cat("\n-- Expected frequencies --\n")
print(round(chisq.test(tab1)$expected, 1))
cat("Minimum expected count:", round(min(chisq.test(tab1)$expected), 1), "\n")

chi1 <- chisq.test(tab1)
print(chi1)

cat("\n-- Effect size --\n")
print(assocstats(tab1))
cat("\n-- Standardised residuals --\n")
print(round(chi1$stdres, 2))

cat("\nDECISION H1: p < 0.05 -> reject H0.\n")


# ============================================================
# H2: Mean monthly charges are equal in both churn groups
# ============================================================

print(shapiro.test(sample(telco$MonthlyCharges[telco$Churn == "No"], 5000)))
print(leveneTest(MonthlyCharges ~ Churn, data = telco, center = median))

t2 <- t.test(MonthlyCharges ~ Churn, data = telco, var.equal = FALSE)
print(t2)

g1 <- telco$MonthlyCharges[telco$Churn == "No"]
g2 <- telco$MonthlyCharges[telco$Churn == "Yes"]
sp <- sqrt(((length(g1)-1)*var(g1) + (length(g2)-1)*var(g2)) / (length(g1)+length(g2)-2))
cat("Mean difference (Yes - No) =", round(mean(g2)-mean(g1), 2), "USD\n")
cat("Cohen's d =", round((mean(g2)-mean(g1))/sp, 3), "\n")

print(wilcox.test(MonthlyCharges ~ Churn, data = telco, conf.int = TRUE))

cat("\nDECISION H2: p < 0.05 -> reject H0.\n")


# ============================================================
# H3: Mean tenure is equal in both churn groups
# ============================================================

print(leveneTest(tenure ~ Churn, data = telco, center = median))

t3 <- t.test(tenure ~ Churn, data = telco, var.equal = FALSE)
print(t3)

ten_no  <- telco$tenure[telco$Churn == "No"]
ten_yes <- telco$tenure[telco$Churn == "Yes"]
sp3 <- sqrt(((length(ten_no)-1)*var(ten_no) + (length(ten_yes)-1)*var(ten_yes)) /
              (length(ten_no)+length(ten_yes)-2))
cat("Mean difference (Yes - No) =", round(mean(ten_yes)-mean(ten_no), 2), "months\n")
cat("Cohen's d =", round((mean(ten_yes)-mean(ten_no))/sp3, 3), "\n")

print(wilcox.test(tenure ~ Churn, data = telco, conf.int = TRUE))

cat("\nDECISION H3: p < 0.05 -> reject H0.\n")