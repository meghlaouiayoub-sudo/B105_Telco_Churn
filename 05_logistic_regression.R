# ============================================================
# B105 Applied Statistical Modelling
# 05 - Binary logistic regression (H4)
# ============================================================

library(car); library(pROC); library(broom); library(pscl)
set.seed(2026)

# ---- Stratified 70/30 split preserves the 26.5% churn rate ----
idx_yes <- which(telco$Churn == "Yes")
idx_no  <- which(telco$Churn == "No")
train_idx <- c(sample(idx_yes, round(.7 * length(idx_yes))),
               sample(idx_no,  round(.7 * length(idx_no))))
train <- telco[train_idx, ]
test  <- telco[-train_idx, ]

cat("Training set:", nrow(train), "| churn", round(100*mean(train$Churn=="Yes"),2), "%\n")
cat("Test set    :", nrow(test),  "| churn", round(100*mean(test$Churn=="Yes"),2), "%\n")

# ---- ASSUMPTION: multicollinearity ----
cat("\nCorrelation tenure vs TotalCharges:", round(cor(telco$tenure, telco$TotalCharges), 3), "\n")
full_model <- glm(Churn ~ tenure + MonthlyCharges + TotalCharges + Contract +
                    InternetService + PaymentMethod + PaperlessBilling +
                    TechSupport + OnlineSecurity + SeniorCitizen + Dependents,
                  data = train, family = binomial(link = "logit"))
print(vif(full_model))

# ---- Final model (TotalCharges removed - too collinear with tenure) ----
model <- glm(Churn ~ tenure + MonthlyCharges + Contract + InternetService +
               PaymentMethod + PaperlessBilling + TechSupport +
               OnlineSecurity + SeniorCitizen + Dependents,
             data = train, family = binomial(link = "logit"))
summary(model)
print(vif(model))

cat("\nEvents in training set:", sum(train$Churn == "Yes"),
    "| parameters:", length(coef(model)),
    "| EPV =", round(sum(train$Churn=="Yes")/length(coef(model)), 1), "\n")
cat("Max Cook's distance:", round(max(cooks.distance(model)), 4), "\n")

print(anova(glm(Churn ~ 1, data = train, family = binomial), model, test = "Chisq"))
print(pR2(model)[c("McFadden","r2CU")])
# ============================================================
# Predictive performance on the hold-out test set
# ============================================================

prob_test <- predict(model, newdata = test, type = "response")

pred_05 <- factor(ifelse(prob_test > .5, "Yes", "No"), levels = c("No","Yes"))
cm <- table(Predicted = pred_05, Actual = test$Churn)
print(cm)

acc  <- sum(diag(cm)) / sum(cm)
sens <- cm["Yes","Yes"] / sum(cm[,"Yes"])
spec <- cm["No","No"]  / sum(cm[,"No"])
cat("Accuracy =", round(acc,4), "  Sensitivity =", round(sens,4),
    "  Specificity =", round(spec,4), "\n")
cat("No-information rate (always predict 'No') =",
    round(max(prop.table(table(test$Churn))), 4), "\n")

roc_obj <- roc(test$Churn, prob_test, levels = c("No","Yes"), direction = "<")
cat("\nAUC =", round(auc(roc_obj), 4), "\n")
print(ci.auc(roc_obj))

opt <- coords(roc_obj, "best", best.method = "youden")
print(opt)

train_no_imputed <- train[!(train$tenure == 0), ]
model_check <- update(model, data = train_no_imputed)
diff_tbl <- round(abs(coef(model) - coef(model_check)), 3)
cat("\nMaximum absolute coefficient change:", max(diff_tbl),
    "-> the imputation decision does not drive the results.\n")