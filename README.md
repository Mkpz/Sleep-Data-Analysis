# Sleep Patterns Analysis: Age, Gender & Time Trends in American Sleep Habits

[![R](https://img.shields.io/badge/R-276DC3?style=flat&logo=r&logoColor=white)](https://www.r-project.org/)
[![Statistical Analysis](https://img.shields.io/badge/Statistical-Analysis-blue)](https://github.com/Mkpz/Sleep-Data-Analysis)
[![Bayesian Modeling](https://img.shields.io/badge/Bayesian-Regression-green)](https://github.com/Mkpz/Sleep-Data-Analysis)
[![ANOVA Testing](https://img.shields.io/badge/ANOVA-Testing-orange)](https://github.com/Mkpz/Sleep-Data-Analysis)
[![Machine Learning](https://img.shields.io/badge/Machine%20Learning-Decision%20Trees-red)](https://github.com/Mkpz/Sleep-Data-Analysis)
[![Random Forest](https://img.shields.io/badge/Random-Forest-purple)](https://github.com/Mkpz/Sleep-Data-Analysis)
[![Data Visualization](https://img.shields.io/badge/Data-Visualization-yellow)](https://github.com/Mkpz/Sleep-Data-Analysis)
[![MCMC](https://img.shields.io/badge/MCMC-Diagnostics-teal)](https://github.com/Mkpz/Sleep-Data-Analysis)

A comprehensive statistical analysis of American sleep patterns (2003-2017) using advanced regression techniques, ANOVA testing, and Bayesian prediction models to examine relationships between age, gender, and sleep duration across 945 observations.

## Project Overview

This project analyzes sleep data from the American Time Use Survey collected by the U.S. Bureau of Labor Statistics, investigating how sleep patterns vary by age group, gender, and day type over 14 years. The analysis combines hypothesis testing, multiple regression models, decision trees, random forests, and Bayesian prediction to provide comprehensive insights into American sleep habits.

### Key Findings

- 15-24 years age group sleeps the most (~9.9 hours average)
- 45-54 years age group sleeps the least (~8.3 hours average)  
- 65+ age group sleeps more than middle-aged groups but less than teenagers
- Type of day and age group are the most important predictors (18.9% and 16.5% importance)
- Sleep patterns show general increase over years despite economic/political events
- Weekend days show higher sleep hours than non-holiday weekdays

## Research Questions

1. Do different age groups have significantly different average sleep times?
2. Which age group has the highest average sleep time?
3. How do sleep patterns vary by day type (weekday vs. weekend)?
4. Can we predict sleep hours based on demographic and temporal factors?

## Repository Structure

```
Sleep-Data-Analysis/
│
├── Sleep Data Analysis Code.R           # Complete analysis code
├── Sleep Data Analysis Project.pdf      # Comprehensive written report
├── Sleep Data Analysis Presentation.pptx # Visual presentation slides
├── Errorfunction.R                      # Custom error function for model evaluation
└── README.md                            # Project documentation
```

## Getting Started

### Prerequisites

```r
# Required R version
R >= 4.0.0

# Install required packages
install.packages(c("tree", "rpart", "randomForest", "rstanarm", 
                   "ggplot2", "dplyr", "leaps", "lars", "olsrr",
                   "rpart.plot", "corrplot", "wesanderson"))
```

### Running the Analysis

1. Clone the repository:
```bash
git clone https://github.com/yourusername/Sleep-Data-Analysis.git
cd Sleep-Data-Analysis
```

2. Load the error function:
```r
# Load custom error function for model evaluation
source("Errorfunction.R")

# Custom error function for model evaluation
regr.error <- function(predicted, actual) {
  mae <- mean(abs(actual - predicted))
  mse <- mean((actual - predicted)^2)
  rmse <- sqrt(mse)
  mape <- mean(abs((actual - predicted) / actual))
  c(mae = mae, mse = mse, rmse = rmse, mape = mape)
}
```

3. Run complete analysis:
```r
source("Sleep Data Analysis Code.R")

# Or run sections individually:
# - Data loading and preprocessing
# - ANOVA and hypothesis testing
# - Decision trees and random forests
# - Regression models
# - Bayesian predictions
```

4. View results:
- Review PDF report for comprehensive findings
- Examine PowerPoint presentation for visual summary

## Dataset Information

**Source**: American Time Use Survey (U.S. Bureau of Labor Statistics)  
**Time Period**: 2003-2017  
**Sample Size**: 945 observations  

**Variables**:
- `Year`: Survey year (2003-2017)
- `AvgHours`: Average hours per day sleeping
- `Standard.Error`: Statistical error measure
- `Type.of.Days`: All days / Nonholiday weekdays / Weekend days and holidays
- `Age.Group`: 7 categories (15-24, 25-34, 35-44, 45-54, 55-64, 65+, 15+)
- `Sex`: Men / Women / Both

## Technologies & Methods

### Programming & Statistical Tools
- **Language**: R
- **Key Packages**:
  - `tree`, `rpart` - Decision trees
  - `randomForest` - Ensemble learning
  - `rstanarm` - Bayesian regression
  - `ggplot2` - Data visualization
  - `dplyr` - Data manipulation
  - `leaps`, `lars` - Variable selection
  - `olsrr` - Model diagnostics

### Statistical Methods Implemented

**1. ANOVA Testing**
- **Hypothesis 1**: Each age group has different average sleep times
- **Result**: All F-values significant (p < 2e-16) → Reject H₀
- **Conclusion**: Age groups differ significantly in sleep duration

**2. Pairwise t-tests with Bonferroni Correction**
- **Adjusted α**: 0.05/21 = 0.00238
- **Key Finding**: 15-24 years vs. 45-54 years most significantly different (p < 2e-16)

**3. Tukey HSD Post-Hoc Tests**
- 15-24 years sleep 1.02 hours more than 45-54 years (p < 0.001)
- 65+ years sleep 0.53 hours less than 15-24 years (p < 0.001)
- All pairwise comparisons revealed significant differences except:
  - 15 years and over ↔ 25-34 years (p = 0.999)
  - 55-64 years ↔ 45-54 years (p = 1.000)

## Analysis Results

### Age Group Sleep Patterns

| Age Group | Average Sleep (hours) | Ranking |
|-----------|----------------------|---------|
| 15-24 years | 9.9 | 1st (Highest) |
| 65+ years | 8.7 | 2nd |
| 15+ years (overall) | 8.7 | 2nd |
| 25-34 years | 8.7 | 2nd |
| 55-64 years | 8.4 | 5th |
| 35-44 years | 8.3 | 6th |
| 45-54 years | 8.3 | 7th (Lowest) |

### Temporal Trends (2003-2017)

**15-24 Years Age Group**:
- General increasing trend in sleep hours
- Sudden decrease 2005-2007 (possible factors: technology, social media)
- Peak in 2009, drastic drop in 2010
- Recovery and stabilization 2011-2017

**65+ Years Age Group**:
- Stable around 8.9 hours (2003-2011)
- Sudden drop 2012-2013 (possibly related to Sandy Hook shooting, Boston Marathon bombing)
- Recovery trend 2014-2015
- Decrease 2015-2017 (possibly related to 2016 election)

**Historical Context**:
- 2005: Hurricane Katrina
- 2007: iPhone release
- 2008: Obama election
- 2012: Sandy Hook, Obama re-election
- 2013: Boston Marathon bombing
- 2016: Trump election

### Sleep Deprivation Patterns (<9 hours)

**2005 Analysis**:
- 15-24 years: ~1 person sleep-deprived (non-holiday weekdays only)
- 65+ years: ~3 people sleep-deprived (mainly non-holiday weekdays)

**2010 Analysis**:
- 15-24 years: ~2 people sleep-deprived (increase from 2005)
- 65+ years: ~3 people sleep-deprived (consistent with 2005)

**2015 Analysis**:
- 15-24 years: ALL sleep >9 hours (dramatic improvement!)
- 65+ years: Only group with sleep deprivation

## Machine Learning Models

### Decision Tree Results

**Root Node (All Ages)**: 8.9 hours average

**Branch 1 - High Sleepers (14% of population)**:
- **Age Group**: 15-24 years
- **Average**: 9.9 hours

**Branch 2 - Weekend Sleepers (29% of population)**:
- **Type of Days**: Weekend days and holidays
- **Average**: 8.7 hours

**Branch 3 - Low Sleepers (29% of population)**:
- **Age Groups**: 35-44, 45-54, 55-64 years
- **Type of Days**: All days and non-holiday weekdays
- **Average**: 8.3 hours

**Branch 4 - Moderate Sleepers (29% of population)**:
- **Age Groups**: 15+, 25-34, 65+ years
- **Type of Days**: All days and non-holiday weekdays
- **Average**: 8.7 hours

### Random Forest Variable Importance

| Variable | %IncMSE | Importance Rank |
|----------|---------|-----------------|
| Type of Days | 20.84% | 1st (Highest) |
| Age Group | 18.60% | 2nd |
| Sex | -4.22% | 3rd |
| Year | 0.00% | 4th (Lowest) |

**Interpretation**: Type of day (weekday vs. weekend) and age group are the most critical predictors of sleep duration.

### Regression Models Performance

**Model Comparison (RMSE on test data)**:

| Model | RMSE | MAE | Features |
|-------|------|-----|----------|
| Model 1 (Basic) | 0.7728 | 0.6275 | Age, Sex, Type of Days, Year |
| Model 2 (Interactions) | 0.7688 | 0.6223 | + Age:Sex, Type:Sex, Year:Age, Year:Type |
| Model 3 (Full) | 0.7704 | 0.6238 | + Year:Sex |

**Best Model**: Model 2 with interaction terms (lowest RMSE)

**Model Selection Criteria**:
- Lowest BIC: Model 1 (-520.62)
- Lowest AIC: Model 2 (-697.56)
- Best Prediction: Model 2 (RMSE = 0.7688)

## Bayesian Prediction Analysis

### Model Specification

```r
stan_glm(AvgHours ~ Gender + Year + Age + 
         Age:Gender + Day:Gender + Year:Age + Year:Day,
         family = "gaussian",
         prior_intercept = normal(0, 2.5, autoscale = TRUE),
         prior = normal(0, 2.5, autoscale = TRUE),
         prior_aux = exponential(1, autoscale = TRUE),
         chains = 4, iter = 10000)
```

### 2017 Predictions by Age Group

| Age Group | Predicted Average Sleep (hours) |
|-----------|--------------------------------|
| Age 2 (15-24 years) | 8.79 |
| Age 3 (25-34 years) | 8.72 |
| Age 4 (35-44 years) | 8.65 |
| Age 5 (45-54 years) | 8.59 |
| Age 6 (55-64 years) | 8.52 |
| Age 7 (65+ years) | 8.46 |

**Trend**: As age increases, predicted average sleep hours decrease  
**Validation**: Supports hypothesis that middle-aged groups sleep less than younger groups

### MCMC Diagnostics
- Chains mixed well (trace plots converged)
- Sufficient chain length (density overlays consistent)
- Low autocorrelation (ACF plots acceptable)
- Sample size ratio >10% (adequate data)
- R-hat close to 1.0 (<1.05) (stable simulation)

## Data Visualizations

### Created Visualizations

1. **Bar Plots**:
   - Average sleep hours by age group
   - Temporal trends for 15-24 years (2003-2017)
   - Temporal trends for 65+ years (2003-2017)

2. **Pie Charts**:
   - Distribution of high sleepers (>9 hours) by age group
   - Type of days for different sleep patterns

3. **Stacked Bar Plots**:
   - Sleep deprivation (<9 hours) by age group (2005, 2010, 2015)
   - Gender distribution within age groups

4. **Jitter/Scatter Plots**:
   - Sleep hours over years colored by type of day
   - Multi-age group comparison across time

5. **Decision Tree Diagrams**:
   - Visual representation of sleep pattern classification

## Conclusions

### Major Findings

1. **Age Group Differences**: All age groups have statistically different sleep patterns (p < 0.001)

2. **Highest Sleepers**: 15-24 years age group sleeps most (~9.9 hours), contradicting the hypothesis that 65+ sleeps most

3. **Lowest Sleepers**: 45-54 years age group sleeps least (~8.3 hours), potentially due to work/family demands

4. **Important Predictors**: Type of day (weekday vs. weekend) is the strongest predictor, followed by age group

5. **Temporal Trends**: General increase in sleep hours over time despite major events (economic recession, political changes)

6. **Model Performance**: Interaction terms improve prediction accuracy (RMSE = 0.77)

7. **Bayesian Validation**: Predictions confirm decreasing sleep trend with increasing age

### Practical Implications

- **Public Health**: Middle-aged adults (45-54) may need interventions for sleep deprivation
- **Policy**: Weekend sleep recovery is critical for younger age groups
- **Research**: Sleep patterns influenced more by routine (weekday/weekend) than demographics
- **Education**: Teenagers' higher sleep needs should inform school start times

---

**Note**: This analysis represents academic coursework demonstrating proficiency in statistical hypothesis testing, machine learning, Bayesian modeling, and comprehensive data analysis using R.
