"""Summary statistics and chart for the cold/warm start dataset.

Usage: python analysis/summary.py
Needs pandas, scipy and matplotlib.
"""
import pandas as pd
import matplotlib.pyplot as plt
from scipy import stats

df = pd.read_csv("data/cold_warm_starts.csv")

summary = df.groupby("start_type")["duration_ms"].agg(
    ["count", "mean", "median", "std", "min", "max"]).round(1)
print(summary, "\n")

cold = df.loc[df.start_type == "cold", "duration_ms"]
warm = df.loc[df.start_type == "warm", "duration_ms"]
t, p = stats.ttest_ind(cold, warm, equal_var=False)
print(f"Welch t-test: t = {t:.2f}, p = {p:.2e}")

fig, ax = plt.subplots(figsize=(8, 4))
for kind, colour in (("cold", "#1f77b4"), ("warm", "#ff7f0e")):
    part = df[df.start_type == kind]
    ax.scatter(part.run, part.duration_ms, label=kind, color=colour)
ax.set_xlabel("Invocation number")
ax.set_ylabel("Duration (ms)")
ax.set_title("Cold vs warm start duration across 50 invocations")
ax.legend()
fig.tight_layout()
fig.savefig("analysis/cold_vs_warm.png", dpi=150)
print("Saved analysis/cold_vs_warm.png")
