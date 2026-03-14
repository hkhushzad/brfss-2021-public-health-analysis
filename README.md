# 🩺 BRFSS 2021 Public Health Analysis

### Diet, Preventive Care, and Self-Reported Health Outcomes

📊 **Data Science | Public Health | Healthcare Analytics**

This project analyzes national health survey data to explore whether **dietary behavior and preventive healthcare are associated with better health outcomes**.

Using the **Behavioral Risk Factor Surveillance System (BRFSS) 2021 dataset**, the analysis investigates how **fruit consumption and routine medical checkups relate to self-reported health status**.

The project demonstrates a **complete data analysis workflow using R**, including data cleaning, statistical modeling, predictive analysis, and visualization.

---

# 🔬 Research Objective

The goal of this project is to examine how **health behaviors relate to self-reported health outcomes** in a large population dataset.

Key questions explored:

• What percentage of respondents report **good or very good health**?
• Does **time since last routine checkup** relate to health status?
• Do individuals who consume more **fruit per day report better health**?
• Can **health behaviors predict the probability of reporting good health**?

---

# 📂 Dataset

This project uses the **Behavioral Risk Factor Surveillance System (BRFSS) 2021**, a nationwide health survey conducted by the Centers for Disease Control and Prevention.

BRFSS is one of the largest public health datasets in the United States and includes information on:

• Health behaviors
• Preventive healthcare
• Chronic disease risk factors
• Access to healthcare services

Because the dataset is large, it is **not included in this repository**.

Download the dataset here:

https://www.cdc.gov/brfss/annual_data/annual_2021.html

Place the dataset in the project directory:

```id="k7py1y"
data/brfss2021.csv
```

---

# 🧪 Variables Used

| Variable     | Description                             |
| ------------ | --------------------------------------- |
| **GENHLTH**  | Self-reported general health status     |
| **CHECKUP1** | Time since last routine medical checkup |
| **FRUIT2**   | Fruit consumption frequency             |

Fruit consumption values were converted into **estimated servings per day** to standardize measurement.

---

# ⚙️ Tools & Technologies

**Programming**

• R

**Libraries**

• tidyverse
• ggplot2
• psych
• lm.beta

These tools were used for **data wrangling, statistical modeling, and visualization**.

---

# 📊 Example Data Import

```r
library(tidyverse)

brf <- read_csv("data/brfss2021.csv", show_col_types = FALSE)
```

---

# 📈 Statistical Methods

This project applies several statistical techniques commonly used in **public health and healthcare analytics**.

### Data Cleaning

• Removed missing survey responses
• Converted coded dietary frequency variables
• Handled outliers and missing values

### Descriptive Statistics

Explored differences in **fruit consumption across health status categories**.

### Linear Regression

```r
mod_lm <- lm(GENHLTH ~ FRTDAY + CHECKUP1, data = brf_fruit_clean)
summary(mod_lm)
```

This model examines whether **fruit consumption and preventive care predict health status**.

### Logistic Regression

```r
log_model <- glm(
  binHealth ~ FRTDAY + binCheckup,
  data = brf_logistic,
  family = binomial
)
```

The logistic model estimates the **probability of reporting excellent or very good health**.

---

# 📊 Visualizations

The project produces two key visualizations.

### Fruit Consumption by Health Status

```id="32cuf3"
figures/fruit_health_distribution.png
```

Shows how fruit intake differs across health categories.

---

### Predicted Probability of Good Health

```id="jb4xhy"
figures/fruit_health_probability.png
```

Illustrates how increasing fruit consumption relates to the **probability of reporting good health**.

---

# 🧠 Key Insights

Key findings from the analysis include:

• Individuals with **higher fruit consumption tend to report better health**
• Respondents with **recent preventive checkups show higher probability of good health**
• Behavioral health factors may help **predict self-reported health outcomes**

These insights demonstrate how **behavioral health data can inform public health research and policy decisions**.

---

# 📁 Repository Structure

```text
brfss-public-health-analysis
│
├── data
│   └── brfss2021.csv
│
├── figures
│   ├── fruit_health_distribution.png
│   └── fruit_health_probability.png
│
├── R
│   └── brfss_public_health_analysis.R
│
└── README.md
```

---

# 🚀 Skills Demonstrated

This project highlights several **data science and healthcare analytics skills**:

✔ Data cleaning and transformation
✔ Statistical modeling in R
✔ Logistic regression analysis
✔ Predictive probability modeling
✔ Data visualization
✔ Working with large public health datasets

---

# 📌 Future Improvements

Future extensions of this project may include:

• Additional behavioral health variables
• Chronic disease risk factor analysis
• Geographic health disparities
• Advanced predictive modeling
• Expanded visualizations

---

