# Towards Living Medical Guidelines: An Inductive Logic Programming Approach

This repository contains the code and data extraction pipeline for my Master's thesis, *"Towards Living Medical Guidelines: An Inductive Logic Programming Approach"* (MSc Artificial Intelligence, Vrije Universiteit Amsterdam).

The thesis investigates whether Inductive Logic Programming (ILP), using the [Popper](https://github.com/logic-and-learning-lab/Popper) system, can learn interpretable rules from ICU data that characterise sepsis treatment decisions and how those learned rules compare to the Surviving Sepsis Campaign (SSC) 2016 guidelines. Two binary decisions are studied:

- **Pipeline 1:** Which sepsis patients received norepinephrine (the guideline's recommended first-choice vasopressor)?
- **Pipeline 2:** Among patients who received norepinephrine, which required dose escalation or a second vasopressor?

All data is drawn from [MIMIC-IV v3.1](https://physionet.org/content/mimiciv/3.1/), accessed via Google BigQuery.

## Repository Structure

```
.
├── sepsis_cohort_identification.sql   # Identifies the base sepsis cohort (Section 3.1)
├── Pipeline_1/
│   ├── pipeline1_extraction.sql              # Extracts Pipeline 1 cohort + predicates
│   ├── generate_popper_files.py              # Converts extracted data into Popper's bk.pl / bias.pl / exs.pl
│   ├── pipeline1_predicate_distribution.py   # Reproduces Appendix Tables 3 and 5
│   ├── Pipeline_1.csv                        # Extracted cohort (raw predicate values)
│   ├── control/                              # Stage 1: Control Trial (synthetic patients)
│   ├── positive_only/                        # Stage 2: Positive-Only Sanity Check
│   └── full_experiment/                      # Stage 3: Full Experiment (max_body 3 and 5)
└── Pipeline_2/
    ├── pipeline2_extraction.sql              # Extracts Pipeline 2 cohort + predicates
    ├── pipeline2_generate_popper_files.py    # Converts extracted data into Popper's bk.pl / bias.pl / exs.pl
    ├── pipeline2_predicate_distribution.py   # Reproduces Appendix Tables 4 and 6
    ├── Pipeline_2.csv                        # Extracted cohort (raw predicate values)
    ├── control/                              # Stage 1: Control Trial (synthetic patients)
    ├── positive_only/                        # Stage 2: Positive-Only Sanity Check
    └── full_experiment/                      # Stage 3: Full Experiment (max_body 3 and 5)
```

Each `control/`, `positive_only/`, and `full_experiment/` folder contains the three files Popper requires (`bk.pl`, `bias.pl`, `exs.pl`) along with the corresponding raw Popper output (`output_*.txt`) for that stage.

## Reproducing the Results

### 1. Data extraction (BigQuery)
Run `sepsis_cohort_identification.sql` first to identify the base cohort, then `pipeline1_extraction.sql` / `pipeline2_extraction.sql` to extract each pipeline's labelled predicates. All three require access to the [MIMIC-IV v3.1 dataset on PhysioNet](https://physionet.org/content/mimiciv/3.1/) via Google BigQuery.

### 2. Running Popper
Each stage's folder is ready to run directly with Popper:
```bash
python3 popper.py Pipeline_1/control
python3 popper.py Pipeline_1/positive_only
python3 popper.py Pipeline_1/full_experiment
```
(and equivalently for `Pipeline_2/`). See the [Popper repository](https://github.com/logic-and-learning-lab/Popper) for installation instructions.

### 3. Predicate distribution tables (Appendix)
```bash
python3 Pipeline_1/pipeline1_predicate_distribution.py
python3 Pipeline_2/pipeline2_predicate_distribution.py
```
Each script prints both the predicate coverage table and the predicate distribution-by-class table for its pipeline, computed directly from the extracted CSV (i.e. using the same "most recent value before anchor" predicate values that were actually fed into Popper).

## Data Access

This repository does not include the underlying MIMIC-IV patient data, in accordance with PhysioNet's data use agreement. Access to MIMIC-IV requires completing PhysioNet's credentialing process: https://physionet.org/content/mimiciv/

## Citation

If referencing this work, please cite the thesis:

> Maroo, A. (2026). *Towards Living Medical Guidelines: An Inductive Logic Programming Approach.* MSc Thesis, Vrije Universiteit Amsterdam.
