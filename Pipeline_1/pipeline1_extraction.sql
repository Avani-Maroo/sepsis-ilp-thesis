-- Pipeline 1 CSV Extraction (Administer Norepinephrine)
-- ------------------------------------------------------------
-- Extracts the Pipeline 1 cohort and raw predicate values used to predict whether a sepsis patient received norepinephrine.
--
-- Cohort definition:
--   - Positive class: stays where norepinephrine (itemid 221906) was administered. Anchor time = norepinephrine start time.
--   - Negative class: stays where no vasoactive agent at all was administered. Anchor time = suspected infection time + 24 hours.
--   - Stays where a different vasopressor was administered (but not norepinephrine) are excluded from both classes (see thesis Section 3.4 for rationale).
--
-- Predicates extracted (raw values, prior to categorisation):
--   - anchor_age, cci (Charlson Comorbidity Index)
--   - sofa_before_anchor: most recent SOFA score at or before anchor time
--   - lactate_before_anchor: most recent serum lactate at or before anchor time
--   - map_before_anchor: most recent MAP reading at or before anchor time
--
-- Note: "most recent value before anchor" is used throughout (via ARRAY_AGG ... ORDER BY ... DESC LIMIT 1), not the maximum value ever recorded before the anchor.
--
-- Output: 4,150 stays (2,198 positive / 1,952 negative)
-- ------------------------------------------------------------

WITH sepsis_cohort AS (
  SELECT s.stay_id, s.subject_id, s.suspected_infection_time
  FROM `physionet-data.mimiciv_3_1_derived.sepsis3` s
  INNER JOIN `physionet-data.mimiciv_3_1_hosp.patients` p ON s.subject_id = p.subject_id
  INNER JOIN `physionet-data.mimiciv_3_1_icu.icustays` i ON s.stay_id = i.stay_id
  WHERE s.sepsis3 = TRUE AND p.anchor_year_group = '2017 - 2019'
  AND p.anchor_age >= 18 AND i.los > 0.0417
),
norepi_start AS (
  SELECT ie.stay_id, MIN(ie.starttime) AS norepi_start_time
  FROM `physionet-data.mimiciv_3_1_icu.inputevents` ie
  JOIN sepsis_cohort sc ON ie.stay_id = sc.stay_id
  WHERE ie.itemid = 221906 AND ie.amount > 0
  GROUP BY ie.stay_id
),
positive_cohort AS (
  SELECT ns.stay_id, sc.subject_id, ns.norepi_start_time AS anchor_time, 'positive' AS label
  FROM norepi_start ns JOIN sepsis_cohort sc ON ns.stay_id = sc.stay_id
),
negative_cohort AS (
  SELECT sc.stay_id, sc.subject_id,
    TIMESTAMP_ADD(sc.suspected_infection_time, INTERVAL 24 HOUR) AS anchor_time, 'negative' AS label
  FROM sepsis_cohort sc
  WHERE sc.stay_id NOT IN (
    SELECT DISTINCT stay_id FROM `physionet-data.mimiciv_3_1_icu.inputevents`
    WHERE itemid IN (221906, 222315, 221289, 229617, 221662, 221749, 229630, 229632, 221986)
    AND amount > 0
  )
),
combined AS (SELECT * FROM positive_cohort UNION ALL SELECT * FROM negative_cohort),
sofa_before AS (
  SELECT c.stay_id,
    ARRAY_AGG(sf.sofa_24hours ORDER BY sf.starttime DESC LIMIT 1)[OFFSET(0)] AS sofa_before_anchor
  FROM combined c
  JOIN `physionet-data.mimiciv_3_1_derived.sofa` sf
    ON c.stay_id = sf.stay_id AND sf.starttime <= c.anchor_time
  GROUP BY c.stay_id
),
lactate_before AS (
  SELECT c.stay_id,
    ARRAY_AGG(le.valuenum ORDER BY le.charttime DESC LIMIT 1)[OFFSET(0)] AS lactate_before_anchor
  FROM combined c
  JOIN `physionet-data.mimiciv_3_1_hosp.labevents` le
    ON c.subject_id = le.subject_id AND le.itemid = 50813 AND le.charttime <= c.anchor_time
  GROUP BY c.stay_id
),
map_before AS (
  SELECT c.stay_id,
    ARRAY_AGG(v.mbp ORDER BY v.charttime DESC LIMIT 1)[OFFSET(0)] AS map_before_anchor
  FROM combined c
  JOIN `physionet-data.mimiciv_3_1_derived.vitalsign` v
    ON c.stay_id = v.stay_id AND v.charttime <= c.anchor_time AND v.mbp IS NOT NULL
  GROUP BY c.stay_id
),
charlson_deduped AS (
  SELECT hadm_id, MAX(charlson_comorbidity_index) AS cci
  FROM `physionet-data.mimiciv_3_1_derived.charlson`
  GROUP BY hadm_id
)
SELECT
  c.stay_id,
  c.label,
  p.anchor_age,
  cd.cci,
  sb.sofa_before_anchor,
  lb.lactate_before_anchor,
  mb.map_before_anchor
FROM combined c
JOIN `physionet-data.mimiciv_3_1_hosp.patients` p ON c.subject_id = p.subject_id
JOIN `physionet-data.mimiciv_3_1_icu.icustays` i ON c.stay_id = i.stay_id
LEFT JOIN charlson_deduped cd ON i.hadm_id = cd.hadm_id
LEFT JOIN sofa_before sb ON c.stay_id = sb.stay_id
LEFT JOIN lactate_before lb ON c.stay_id = lb.stay_id
LEFT JOIN map_before mb ON c.stay_id = mb.stay_id
ORDER BY c.label
