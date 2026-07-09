-- Sepsis Cohort Identification
-- ------------------------------------------------------------
-- Identifies the sepsis cohort used throughout this thesis from
-- MIMIC-IV v3.1, applying the following inclusion criteria:
--   - Confirmed Sepsis-3 diagnosis (per MIT-LCP's derived.sepsis3 table)
--   - Admitted during anchor_year_group '2017 - 2019' (post Sepsis-3 definition, pre-COVID)
--   - Adults only (age >= 18)
--   - ICU length of stay > 1 hour (0.0417 days), excluding patients who died within one hour of ICU admission (adopted from Huang et al.,consistent with their exclusion of likely withdrawal-of-care cases)
--
-- Source tables:
--   physionet-data.mimiciv_3_1_derived.sepsis3
--   physionet-data.mimiciv_3_1_hosp.patients
--   physionet-data.mimiciv_3_1_icu.icustays
--
-- Output: 4,134 unique patients across 4,834 ICU stays
-- ------------------------------------------------------------

SELECT
  s.subject_id,
  s.stay_id
FROM `physionet-data.mimiciv_3_1_derived.sepsis3` s
INNER JOIN `physionet-data.mimiciv_3_1_hosp.patients` p
  ON s.subject_id = p.subject_id
INNER JOIN `physionet-data.mimiciv_3_1_icu.icustays` i
  ON s.stay_id = i.stay_id
WHERE s.sepsis3 = TRUE
  AND p.anchor_year_group = '2017 - 2019'
  AND p.anchor_age >= 18
  AND i.los > 0.0417
