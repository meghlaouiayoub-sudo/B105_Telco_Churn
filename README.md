# B105 — Statistical Analysis of Customer Churn

Statistical analysis of customer churn for a telecommunications provider, submitted for
**B105 Applied Statistical Modelling**, GISMA University of Applied Sciences.

## Dataset

IBM Telco Customer Churn — 7,043 customers, 21 variables, 26.54% churn rate.
Source: https://www.kaggle.com/datasets/blastchar/telco-customer-churn

## Software

R version 4.6.1 (2026-06-24), RStudio.

Required packages:

```r
install.packages(c("dplyr","tidyr","readr","ggplot2","scales",
                   "car","pROC","broom","vcd","pscl","e1071"))
```

## How to reproduce

Open `105.Rproj` in RStudio and run the scripts in order:

```r
source("01_import_cleaning.R")      # import, cleaning, imputation, factor recoding
source("02_eda.R")                  # churn rates by category and tenure band
source("03_descriptive.R")          # descriptive statistics and outlier screening
source("04_inference.R")            # H1 chi-square, H2 and H3 Welch t-tests
source("05_logistic_regression.R")  # H4 logistic regression, AUC, sensitivity check
```

`set.seed(2026)` fixes every random operation, so the train/test split and all
reported numbers reproduce exactly.

## Business questions

| | Question |
|---|---|
| BQ1 | Is churn associated with contract type? |
| BQ2 | Do customers who churn pay different monthly charges? |
| BQ3 | Is customer tenure associated with churn? |
| BQ4 | Which characteristics predict churn probability jointly? |

## Headline results

| Hypothesis | Test | Statistic | p | Effect size | Decision |
|---|---|---|---|---|---|
| H1 Contract | Pearson chi-square | X2(2) = 1184.60 | < .001 | Cramer's V = 0.41 | Reject H0 |
| H2 Monthly charges | Welch t-test | t(4135.8) = -18.41 | < .001 | Cohen's d = 0.446 | Reject H0 |
| H3 Tenure | Welch t-test | t(4048.3) = 34.82 | < .001 | Cohen's d = -0.852 | Reject H0 |
| H4 Model | Likelihood-ratio | X2(14) = 1590.31 | < .001 | McFadden R2 = 0.279 | Reject H0 |

Model performance on the 2,113-customer hold-out sample: **AUC = 0.838, 95% CI [0.820, 0.856]**,
Hosmer-Lemeshow p = .648. At the Youden-optimal threshold of 0.276 the model reaches
75.94% sensitivity and 76.48% specificity.

## Repository structure

```
.
├── data/
│   └── telco.csv                  # raw dataset
├── figures/                       # figures produced by 06_figures.R
├── 01_import_cleaning.R
├── 02_eda.R
├── 03_descriptive.R
├── 04_inference.R
├── 05_logistic_regression.R
├── 105.Rproj
└── README.md
```
Ayoub Meghlaoui
