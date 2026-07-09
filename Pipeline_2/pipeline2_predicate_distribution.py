"""
Computes both:
  (1) the predicate COVERAGE by class for Pipeline 2 (Table 4 in the thesis appendix)
  (2) the predicate DISTRIBUTION by class for Pipeline 2 (Table 6 in the thesis appendix)

Input:  Pipeline_2.csv (columns: stay_id, anchor_age, cci, sofa_before_norepi, lactate_before_norepi, map_before_norepi, label)
Output: printed coverage table and marginal distribution table

Categorisation thresholds match Table 1 of the thesis (Predicate categories and thresholds).
"""

import csv
from collections import defaultdict

INPUT_CSV = "/Users/avani/Desktop/Masters Thesis/Sepsis_Work/Experiments/Pipeline_2/Pipeline_2.csv"  #update path as needed


def sofa_cat(v):
    if v is None or v == "":
        return "missing"
    v = float(v)
    if v < 6:
        return "low"
    if v < 10:
        return "moderate"
    return "high"


def lactate_cat(v):
    if v is None or v == "":
        return "missing"
    v = float(v)
    if v < 2:
        return "normal"
    if v <= 4:
        return "elevated"
    return "severe"


def map_cat(v):
    if v is None or v == "":
        return "missing"
    v = float(v)
    if v < 55:
        return "very_low"
    if v < 65:
        return "low"
    if v < 80:
        return "adequate"
    return "high"


def age_cat(v):
    v = float(v)
    if v < 50:
        return "young"
    if v < 70:
        return "middle_aged"
    return "elderly"


def cci_cat(v):
    if v is None or v == "":
        return "missing"
    v = float(v)
    if v <= 2:
        return "low"
    if v <= 5:
        return "moderate"
    return "high"


PREDICATES = {
    "sofa_cat": ("SOFA", "sofa_before_norepi", sofa_cat),
    "lactate_cat": ("Lactate", "lactate_before_norepi", lactate_cat),
    "map_cat": ("MAP", "map_before_norepi", map_cat),
    "age_cat": ("Age", "anchor_age", age_cat),
    "cci_cat": ("CCI", "cci", cci_cat),
}


def load_data():
    with open(INPUT_CSV) as f:
        return list(csv.DictReader(f))


def compute_marginals(rows, column, fn):
    """Returns {category: {label: count}} for a given predicate."""
    counts = defaultdict(lambda: defaultdict(int))
    for r in rows:
        cat = fn(r[column])
        counts[cat][r["label"]] += 1
    return counts


def print_coverage_table(rows, totals):
    print("=" * 60)
    print("TABLE 4: Predicate coverage for Pipeline 2 by class")
    print("=" * 60)
    print(f"{'Predicate':<10} {'Positive coverage':<20} {'Negative coverage':<20}")
    for key, (label, column, fn) in PREDICATES.items():
        counts = compute_marginals(rows, column, fn)
        missing_pos = counts.get("missing", {}).get("positive", 0)
        missing_neg = counts.get("missing", {}).get("negative", 0)
        # age has no missing category, so this naturally resolves to 100%
        cov_pos = 100 * (totals["positive"] - missing_pos) / totals["positive"]
        cov_neg = 100 * (totals["negative"] - missing_neg) / totals["negative"]
        print(f"{label:<10} {cov_pos:<20.1f} {cov_neg:<20.1f}")


def print_distribution_table(rows, totals):
    print("\n" + "=" * 60)
    print("TABLE 6: Predicate distribution by class for Pipeline 2")
    print("=" * 60)
    for key, (label, column, fn) in PREDICATES.items():
        counts = compute_marginals(rows, column, fn)
        print(f"\n=== {label} ===")
        for cat in sorted(counts.keys()):
            pos = counts[cat].get("positive", 0)
            neg = counts[cat].get("negative", 0)
            pos_pct = 100 * pos / totals["positive"]
            neg_pct = 100 * neg / totals["negative"]
            print(f"{cat:15s} pos={pos:5d} ({pos_pct:5.1f}%)  neg={neg:5d} ({neg_pct:5.1f}%)")
        tot_pos = sum(counts[c].get("positive", 0) for c in counts)
        tot_neg = sum(counts[c].get("negative", 0) for c in counts)
        print(f"  [check] total pos={tot_pos}, total neg={tot_neg}")


def main():
    rows = load_data()
    print(f"Total rows: {len(rows)}")

    label_counts = defaultdict(int)
    for r in rows:
        label_counts[r["label"]] += 1
    totals = dict(label_counts)
    print("Label counts:", totals, "\n")

    print_coverage_table(rows, totals)
    print_distribution_table(rows, totals)


if __name__ == "__main__":
    main()
