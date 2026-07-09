-- Pipeline 2 CSV Extraction (Norepinephrine Escalation)
-- ------------------------------------------------------------
-- Extracts the Pipeline 2 cohort and raw predicate values used to predict whether norepinephrine treatment held or required escalation.
-- Restricted to sepsis patients who received norepinephrine (Pipeline 1's positive class).
--
-- Outcome definition (thresholds per clinical consultation):
--   - Positive (treatment held): dose never exceeded 125% of the 6-hour baseline average, no second vasoactive agent added, OR the entire norepinephrine course lasted under 6 hours.
--   - Negative (treatment escalated): dose exceeded 125% of baseline at any point after the first 6 hours, and/or a second vasoactive agent was added.
--
-- Exclusions:
--   - Patients discharged to hospice (comfort care confound)
--   - Norepinephrine rate values > 10 mcg/kg/min treated as charting errors and excluded from the dose escalation calculation
--
-- Predicates extracted (raw values, prior to categorisation), all measured at or before norepinephrine start time:
--   - anchor_age, cci (Charlson Comorbidity Index)
--   - sofa_before_norepi, lactate_before_norepi, map_before_norepi
--     (most recent value before norepinephrine start)
--
-- Output: 2,123 stays (637 positive / 1,486 negative)
-- ------------------------------------------------------------

WITH sepsis_cohort AS (
  SELECT
    s.stay_id,
    s.subject_id
  FROM `physionet-data.mimiciv_3_1_derived.sepsis3` s
  INNER JOIN `physionet-data.mimiciv_3_1_hosp.patients` p
    ON s.subject_id = p.subject_id
  INNER JOIN `physionet-data.mimiciv_3_1_icu.icustays` i
    ON s.stay_id = i.stay_id
  WHERE s.sepsis3 = TRUE
    AND p.anchor_year_group = '2017 - 2019'
    AND p.anchor_age >= 18
    AND i.los > 0.0417
),

-- Step 1: norepinephrine start time per stay
norepi_start AS (
  SELECT
    ie.stay_id,
    ie.subject_id,
    MIN(ie.starttime) AS norepi_start_time
  FROM `physionet-data.mimiciv_3_1_icu.inputevents` ie
  JOIN sepsis_cohort sc ON ie.stay_id = sc.stay_id
  WHERE ie.itemid = 221906
    AND ie.amount > 0
  GROUP BY ie.stay_id, ie.subject_id
),

-- Step 2: treatment window end (max endtime of any vasoactive agent)
window_end AS (
  SELECT
    ns.stay_id,
    MAX(ie.endtime) AS window_end_time
  FROM norepi_start ns
  JOIN `physionet-data.mimiciv_3_1_icu.inputevents` ie
    ON ns.stay_id = ie.stay_id
    AND ie.itemid IN (
      221906, 222315, 221289, 229617,
      221662, 221749, 229630, 229632, 221986
    )
    AND ie.amount > 0
    AND ie.endtime >= ns.norepi_start_time
  GROUP BY ns.stay_id
),

-- Step 3: norepinephrine dose events within window, cleaned
-- (rates > 10 mcg/kg/min excluded as charting errors)
norepi_events AS (
  SELECT
    ns.stay_id,
    ie.starttime,
    ie.rate
  FROM norepi_start ns
  JOIN window_end we ON ns.stay_id = we.stay_id
  JOIN `physionet-data.mimiciv_3_1_icu.inputevents` ie
    ON ns.stay_id = ie.stay_id
    AND ie.itemid = 221906
    AND ie.amount > 0
    AND ie.starttime >= ns.norepi_start_time
    AND ie.starttime <= we.window_end_time
    AND ie.rate <= 10.0
),

-- Step 4: 6-hour baseline average per stay
baseline AS (
  SELECT
    ns.stay_id,
    AVG(ne.rate) AS baseline_rate,
    TIMESTAMP_ADD(ns.norepi_start_time, INTERVAL 6 HOUR) AS baseline_end
  FROM norepi_start ns
  JOIN norepi_events ne ON ns.stay_id = ne.stay_id
  WHERE ne.starttime <= TIMESTAMP_ADD(ns.norepi_start_time, INTERVAL 6 HOUR)
  GROUP BY ns.stay_id, ns.norepi_start_time
),

-- Step 5: check if any post-6h rate exceeds 125% of baseline
escalation_check AS (
  SELECT
    b.stay_id,
    b.baseline_rate,
    MAX(ne.rate) AS max_post_baseline_rate,
    MAX(CASE WHEN ne.rate > b.baseline_rate * 1.25 THEN 1 ELSE 0 END) AS dose_escalated
  FROM baseline b
  JOIN norepi_events ne ON b.stay_id = ne.stay_id
  WHERE ne.starttime > b.baseline_end
  GROUP BY b.stay_id, b.baseline_rate
),

-- Step 6: short stays (< 6 hours on norepi) -- positive by default per
-- clinical consultation
short_stays AS (
  SELECT
    ns.stay_id,
    TIMESTAMP_DIFF(we.window_end_time, ns.norepi_start_time, MINUTE) AS duration_minutes
  FROM norepi_start ns
  JOIN window_end we ON ns.stay_id = we.stay_id
  WHERE TIMESTAMP_DIFF(we.window_end_time, ns.norepi_start_time, MINUTE) < 360
),

-- Step 7: second agent added during window
second_agent AS (
  SELECT
    ns.stay_id,
    MAX(CASE WHEN ie.itemid != 221906 THEN 1 ELSE 0 END) AS second_agent_added
  FROM norepi_start ns
  JOIN window_end we ON ns.stay_id = we.stay_id
  JOIN `physionet-data.mimiciv_3_1_icu.inputevents` ie
    ON ns.stay_id = ie.stay_id AND ie.itemid IN (
      222315, 221289, 229617,
      221662, 221749, 229630, 229632, 221986
    )
    AND ie.amount > 0
    AND ie.starttime >= ns.norepi_start_time
    AND ie.starttime <= we.window_end_time
  GROUP BY ns.stay_id
),

-- Step 8: discharge location for comfort care exclusion
discharge AS (
  SELECT
    i.stay_id,
    a.discharge_location
  FROM `physionet-data.mimiciv_3_1_icu.icustays` i
  JOIN `physionet-data.mimiciv_3_1_hosp.admissions` a
    ON i.hadm_id = a.hadm_id
),

-- Step 9: predicates
sofa_before AS (
  SELECT
    ns.stay_id,
    ARRAY_AGG(sf.sofa_24hours ORDER BY sf.starttime DESC LIMIT 1)[OFFSET(0)] AS sofa_before_norepi
  FROM norepi_start ns
  JOIN `physionet-data.mimiciv_3_1_derived.sofa` sf
    ON ns.stay_id = sf.stay_id
    AND sf.starttime <= ns.norepi_start_time
  GROUP BY ns.stay_id
),

lactate_before AS (
  SELECT
    ns.stay_id,
    ARRAY_AGG(le.valuenum ORDER BY le.charttime DESC LIMIT 1)[OFFSET(0)] AS lactate_before_norepi
  FROM norepi_start ns
  JOIN `physionet-data.mimiciv_3_1_hosp.labevents` le
    ON ns.subject_id = le.subject_id
    AND le.itemid = 50813
    AND le.charttime <= ns.norepi_start_time
  GROUP BY ns.stay_id
),

map_before AS (
  SELECT
    ns.stay_id,
    ARRAY_AGG(v.mbp ORDER BY v.charttime DESC LIMIT 1)[OFFSET(0)] AS map_before_norepi
  FROM norepi_start ns
  JOIN `physionet-data.mimiciv_3_1_derived.vitalsign` v
    ON ns.stay_id = v.stay_id
    AND v.charttime <= ns.norepi_start_time
    AND v.mbp IS NOT NULL
  GROUP BY ns.stay_id
),

charlson_deduped AS (
  SELECT
    hadm_id,
    MAX(charlson_comorbidity_index) AS cci
  FROM `physionet-data.mimiciv_3_1_derived.charlson`
  GROUP BY hadm_id
)

-- Final: assign labels
SELECT
  ns.stay_id,
  p.anchor_age,
  cd.cci,
  sb.sofa_before_norepi,
  lb.lactate_before_norepi,
  mb.map_before_norepi,
  CASE
    WHEN ss.stay_id IS NOT NULL THEN 'positive'
    WHEN sa.second_agent_added = 1 THEN 'negative'
    WHEN ec.dose_escalated = 1 THEN 'negative'
    WHEN ec.dose_escalated = 0 THEN 'positive'
    ELSE 'positive'
  END AS label
FROM norepi_start ns
JOIN `physionet-data.mimiciv_3_1_hosp.patients` p
  ON ns.subject_id = p.subject_id
JOIN `physionet-data.mimiciv_3_1_icu.icustays` i
  ON ns.stay_id = i.stay_id
LEFT JOIN charlson_deduped cd ON i.hadm_id = cd.hadm_id
LEFT JOIN sofa_before sb ON ns.stay_id = sb.stay_id
LEFT JOIN lactate_before lb ON ns.stay_id = lb.stay_id
LEFT JOIN map_before mb ON ns.stay_id = mb.stay_id
LEFT JOIN discharge d ON ns.stay_id = d.stay_id
LEFT JOIN short_stays ss ON ns.stay_id = ss.stay_id
LEFT JOIN second_agent sa ON ns.stay_id = sa.stay_id
LEFT JOIN escalation_check ec ON ns.stay_id = ec.stay_id
WHERE d.discharge_location != 'HOSPICE'
  OR d.discharge_location IS NULL
ORDER BY label
