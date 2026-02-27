import pandas as pd
import numpy as np
from scipy import stats

# ===============================
# 1. Load Dataset
# ===============================
file_path = "../dataset/Smart_Contract_Research_Dataset_May2025_COMPREHENSIVE_ENHANCED.xlsx"
df = pd.read_excel(file_path)

print("\nDataset Loaded Successfully")
print("Total Records:", len(df))

# ===============================
# 2. Transparent Missing Handling
# ===============================
print("\nMissing Values Per Column:")
print(df.isnull().sum())

# Mean imputation (documented and neutral)
df = df.fillna(df.mean(numeric_only=True))

# ===============================
# 3. Derived Metrics
# ===============================
df["Gas_Reduction_%"] = ((df["Gas_Before"] - df["Gas_After"]) / df["Gas_Before"]) * 100
df["Fraud_Rate_%"] = (df["Fraud_After"] / df["Fraud_Before"]) * 100
df["Fee_%"] = (df["Transaction_Fee"] / df["Transaction_Value"]) * 100

# ===============================
# 4. Z-Score Outlier Detection (Unbiased)
# ===============================
z_scores = np.abs(stats.zscore(df[["Gas_Reduction_%", "Fraud_Rate_%", "Fee_%"]]))
df_clean = df[(z_scores < 3).all(axis=1)]

print("\nRecords After Outlier Removal:", len(df_clean))

# ===============================
# 5. Descriptive Statistics
# ===============================
print("\nDescriptive Statistics:")
print(df_clean[["Gas_Reduction_%", "Fraud_Rate_%", "Fee_%"]].describe())

# ===============================
# 6. Hypothesis Testing
# ===============================

# H1: Gas Reduction ≥ 40%
t_gas, p_gas = stats.ttest_1samp(df_clean["Gas_Reduction_%"], 40)

# H2: Fraud < 2%
fraud_mean = df_clean["Fraud_Rate_%"].mean()

# H3: Fee < 2%
t_fee, p_fee = stats.ttest_1samp(df_clean["Fee_%"], 2)

print("\nHypothesis Testing Results")
print("Gas Reduction t-stat:", t_gas)
print("Gas Reduction p-value:", p_gas)
print("Mean Fraud Rate %:", fraud_mean)
print("Fee t-stat:", t_fee)
print("Fee p-value:", p_fee)

# ===============================
# 7. Regression Analysis
# ===============================
slope, intercept, r_value, p_reg, std_err = stats.linregress(
    df_clean["Gas_Before"],
    df_clean["Gas_After"]
)

print("\nRegression Results")
print("Slope:", slope)
print("Intercept:", intercept)
print("R²:", r_value**2)
print("p-value:", p_reg)

# ===============================
# 8. 95% Confidence Interval
# ===============================
gas_diff = df_clean["Gas_Before"] - df_clean["Gas_After"]
mean_diff = np.mean(gas_diff)
sem = stats.sem(gas_diff)
ci = stats.t.interval(0.95, len(gas_diff)-1, loc=mean_diff, scale=sem)

print("\n95% Confidence Interval for Gas Reduction:", ci)

# ===============================
# 9. Effect Size (Cohen’s d)
# ===============================
cohens_d = (mean_diff) / np.std(gas_diff, ddof=1)

print("\nEffect Size (Cohen's d):", cohens_d)

print("\nStatistical Validation Completed Successfully")
