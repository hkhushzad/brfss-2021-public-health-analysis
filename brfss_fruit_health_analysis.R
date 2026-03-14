############################################################
# BRFSS 2021 Public Health Analysis
# Relationship Between Fruit Consumption, Health Status,
# and Preventive Medical Checkups
#
# Dataset: CDC BRFSS 2021
# Source: Behavioral Risk Factor Surveillance System
#
# Objective:
# Examine whether fruit consumption and preventive healthcare
# utilization are associated with self-reported health status.
############################################################


# ---------------------------------------------------------
# 1. Setup
# ---------------------------------------------------------

# Clear the current R environment to avoid conflicts
# with objects from previous analyses
rm(list = ls())

# Load required libraries for data manipulation,
# statistical analysis, and visualization
library(tidyverse)   # Data manipulation and visualization
library(psych)       # Descriptive statistics
library(lm.beta)     # Standardized regression coefficients
library(ggplot2)     # Data visualization


# ---------------------------------------------------------
# 2. Load Dataset
# ---------------------------------------------------------

# Import the BRFSS 2021 dataset
# show_col_types = FALSE suppresses column type messages
brf <- read_csv("brfss2021.csv", show_col_types = FALSE)


# ---------------------------------------------------------
# 3. Select Relevant Variables
# ---------------------------------------------------------

# The BRFSS dataset contains hundreds of variables.
# For this analysis we focus on three variables related
# to diet, health status, and preventive healthcare.

# GENHLTH = Self-reported general health
# 1 = Excellent
# 2 = Very Good
# 3 = Good
# 4 = Fair
# 5 = Poor
# 7 = Don't know
# 9 = Refused

# CHECKUP1 = Time since last routine medical checkup
# 1 = Within past year
# 2 = Within past 2 years
# 3 = Within past 5 years
# 4 = 5+ years ago
# 8 = Never
# 7/9 = Missing

# FRUIT2 = Fruit consumption frequency

# Select only variables needed for this analysis
brf_selected <- brf %>%
  select(FRUIT2, CHECKUP1, GENHLTH)

# Preview first 10 rows
head(brf_selected, 10)


# ---------------------------------------------------------
# 4. Data Cleaning
# ---------------------------------------------------------

# Remove observations with invalid or missing values
# for health status and checkup frequency

brf_clean <- brf_selected %>%
  filter(!GENHLTH %in% c(7, 9)) %>%     # Remove "Don't know" and "Refused"
  filter(!CHECKUP1 %in% c(7, 9)) %>%    # Remove missing checkup responses
  filter(!is.na(GENHLTH), !is.na(CHECKUP1))

# Preview cleaned data
head(brf_clean, 10)


# ---------------------------------------------------------
# 5. Percentage Reporting Good / Very Good Health
# ---------------------------------------------------------

# Calculate the proportion of respondents reporting
# "Good" or "Very Good" health

Q3 <- brf_clean %>%
  filter(GENHLTH %in% c(2, 3)) %>%
  summarise(
    Count = n(),
    Percent = round((Count / nrow(brf_clean)) * 100, 1)
  )

Q3


# ---------------------------------------------------------
# 6. Health by Time Since Last Checkup
# ---------------------------------------------------------

# Examine how health status distribution varies by
# time since last preventive medical checkup

Q4 <- brf_clean %>%
  filter(GENHLTH %in% c(1, 2, 3)) %>%   # Focus on healthier categories
  group_by(CHECKUP1) %>%
  summarise(
    respondents = n(),
    proportion = round(respondents / nrow(brf_clean), 3)
  )

Q4


# ---------------------------------------------------------
# 7. Convert Fruit Consumption to Servings Per Day
# ---------------------------------------------------------

# FRUIT2 uses a coded system representing frequency
# per day, week, or month. This section converts the
# values into a standardized variable: servings per day.

brf_fruit <- brf_clean %>%
  filter(!FRUIT2 %in% c(777, 999)) %>%  # Remove missing codes
  mutate(
    FRTDAY = case_when(
      between(FRUIT2, 101, 199) ~ FRUIT2 - 100,         # Times per day
      between(FRUIT2, 201, 299) ~ (FRUIT2 - 200) / 7,   # Times per week
      between(FRUIT2, 301, 399) ~ (FRUIT2 - 300) / 30,  # Times per month
      FRUIT2 == 300 ~ 0.02,                             # Rare consumption
      FRUIT2 == 555 ~ 0,                                # Never
      TRUE ~ NA_real_
    )
  ) %>%
  select(FRTDAY, CHECKUP1, GENHLTH)

head(brf_fruit, 10)


# ---------------------------------------------------------
# 8. Descriptive Statistics
# ---------------------------------------------------------

# Summarize fruit consumption by health status group

Q6 <- brf_fruit %>%
  group_by(GENHLTH) %>%
  summarise(
    Mean = round(mean(FRTDAY, na.rm = TRUE), 2),
    Median = round(median(FRTDAY, na.rm = TRUE), 2),
    SD = round(sd(FRTDAY, na.rm = TRUE), 2),
    Count = n()
  )

Q6


# ---------------------------------------------------------
# 9. Handle Outliers and Missing Values
# ---------------------------------------------------------

# Replace extreme fruit consumption values (>8 servings/day)
# with NA and impute missing values using the median

brf_fruit_clean <- brf_fruit %>%
  mutate(FRTDAY = ifelse(FRTDAY > 8, NA, FRTDAY)) %>%
  mutate(FRTDAY = ifelse(is.na(FRTDAY),
                         median(FRTDAY, na.rm = TRUE),
                         FRTDAY))

# Generate descriptive statistics for cleaned dataset
Q7 <- describe(brf_fruit_clean)
Q7


# ---------------------------------------------------------
# 10. Linear Regression
# ---------------------------------------------------------

# Convert checkup variable to categorical factor
brf_fruit_clean$CHECKUP1 <- as.factor(brf_fruit_clean$CHECKUP1)

# Fit linear regression model predicting health status
# from fruit consumption and checkup frequency

mod_lm <- lm(GENHLTH ~ FRTDAY + CHECKUP1, data = brf_fruit_clean)

# Standardize regression coefficients
mod_lm_std <- lm.beta(mod_lm)

summary(mod_lm_std)


# ---------------------------------------------------------
# 11. Logistic Regression
# ---------------------------------------------------------

# Create binary variables for logistic regression:
# Good health vs not good health
# Recent checkup vs not recent checkup

brf_logistic <- brf_fruit_clean %>%
  mutate(
    binHealth = factor(ifelse(GENHLTH %in% c(1, 2), 1, 0)),
    binCheckup = factor(ifelse(CHECKUP1 == 1, 1, 0))
  )

# Fit logistic regression model

log_model <- glm(
  binHealth ~ FRTDAY + binCheckup,
  data = brf_logistic,
  family = binomial
)

summary(log_model)


# ---------------------------------------------------------
# 12. Predict Probability for New Individuals
# ---------------------------------------------------------

# Create hypothetical individuals with different
# fruit intake levels and checkup behavior

new_individuals <- data.frame(
  ID = c("Person1","Person2","Person3","Person4","Person5"),
  FRTDAY = c(0,1,2,3,6),
  binCheckup = factor(c(0,0,0,1,1))
)

# Predict probability of reporting good health

predicted_probabilities <- round(
  predict(log_model,
          newdata = new_individuals,
          type = "response"),
  3
)

predicted_probabilities


# ---------------------------------------------------------
# 13. Visualization: Fruit Consumption vs Health
# ---------------------------------------------------------

# Boxplot showing distribution of fruit consumption
# across self-reported health categories

ggplot(brf_fruit_clean,
       aes(x = factor(GENHLTH),
           y = FRTDAY)) +
  geom_boxplot() +
  labs(
    title = "Fruit Consumption by Self-Reported Health Status",
    x = "Health Status Category",
    y = "Fruit Servings Per Day"
  ) +
  theme_minimal()

ggsave("figures/fruit_health_distribution.png")


# ---------------------------------------------------------
# 14. Predicted Probability Curve
# ---------------------------------------------------------

# Generate a sequence of fruit consumption values
# to visualize predicted probability of good health

fruit_seq <- seq(0, 6, by = 0.1)

prediction_data <- data.frame(
  FRTDAY = fruit_seq,
  binCheckup = factor(1)
)

prediction_data$prob_good_health <- predict(
  log_model,
  newdata = prediction_data,
  type = "response"
)

# Plot predicted probability curve

ggplot(prediction_data,
       aes(x = FRTDAY,
           y = prob_good_health)) +
  geom_line() +
  labs(
    title = "Predicted Probability of Good Health by Fruit Intake",
    x = "Fruit Servings Per Day",
    y = "Probability of Reporting Good Health"
  ) +
  theme_minimal()

ggsave("figures/fruit_health_probability.png")
