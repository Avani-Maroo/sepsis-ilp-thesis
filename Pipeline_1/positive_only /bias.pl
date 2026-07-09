% ============================================================
% Experiment 5 - Norepinephrine Administration in Sepsis
% Bias file - shared across control, positive-only, full experiment
% Based on SSC 2016 guidelines (Rhodes et al.)
% ============================================================

% Maximum clause length
max_vars(1).
max_body(3).

% Head predicate
head_pred(administer_norepinephrine, 1).
type(administer_norepinephrine, (stay,)).
direction(administer_norepinephrine, (in,)).

% SOFA at anchor time
body_pred(low_sofa, 1).
body_pred(moderate_sofa, 1).
body_pred(high_sofa, 1).
body_pred(missing_sofa, 1).
type(low_sofa, (stay,)).
type(moderate_sofa, (stay,)).
type(high_sofa, (stay,)).
type(missing_sofa, (stay,)).
direction(low_sofa, (in,)).
direction(moderate_sofa, (in,)).
direction(high_sofa, (in,)).
direction(missing_sofa, (in,)).

% Lactate at anchor time
body_pred(normal_lactate, 1).
body_pred(elevated_lactate, 1).
body_pred(severe_lactate, 1).
body_pred(missing_lactate, 1).
type(normal_lactate, (stay,)).
type(elevated_lactate, (stay,)).
type(severe_lactate, (stay,)).
type(missing_lactate, (stay,)).
direction(normal_lactate, (in,)).
direction(elevated_lactate, (in,)).
direction(severe_lactate, (in,)).
direction(missing_lactate, (in,)).

% MAP at anchor time
body_pred(very_low_map_before, 1).
body_pred(low_map_before, 1).
body_pred(adequate_map_before, 1).
body_pred(high_map_before, 1).
body_pred(missing_map_before, 1).
type(very_low_map_before, (stay,)).
type(low_map_before, (stay,)).
type(adequate_map_before, (stay,)).
type(high_map_before, (stay,)).
type(missing_map_before, (stay,)).
direction(very_low_map_before, (in,)).
direction(low_map_before, (in,)).
direction(adequate_map_before, (in,)).
direction(high_map_before, (in,)).
direction(missing_map_before, (in,)).

% Age
body_pred(young_patient, 1).
body_pred(middle_aged_patient, 1).
body_pred(elderly_patient, 1).
type(young_patient, (stay,)).
type(middle_aged_patient, (stay,)).
type(elderly_patient, (stay,)).
direction(young_patient, (in,)).
direction(middle_aged_patient, (in,)).
direction(elderly_patient, (in,)).

% Charlson Comorbidity Index
body_pred(low_comorbidity, 1).
body_pred(moderate_comorbidity, 1).
body_pred(high_comorbidity, 1).
type(low_comorbidity, (stay,)).
type(moderate_comorbidity, (stay,)).
type(high_comorbidity, (stay,)).
direction(low_comorbidity, (in,)).
direction(moderate_comorbidity, (in,)).
direction(high_comorbidity, (in,)).
