
import pandas as pd

df = pd.read_excel("May2025_Baseline.xlsx")

with open("remix_input.txt", "w") as f:
    for _, row in df.iterrows():
        line = f"addContractData({int(row['Gas_Before'])}, {int(row['Gas_After'])}, {int(row['Fraud_Before'])}, {int(row['Fraud_After'])}, {int(row['Transaction_Value'])}, {int(row['Transaction_Fee'])});\n"
        f.write(line)

print("Remix-ready script generated.")
