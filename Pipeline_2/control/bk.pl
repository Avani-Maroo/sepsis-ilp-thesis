% ============================================================
% Pipeline 2 - Control Trial
% Background knowledge - hand-built ideal patients
% Perfect positive: low SOFA, normal lactate, adequate/high MAP, young, low comorbidity
% Perfect negative: high SOFA, severe lactate, very low/low MAP, elderly, high comorbidity
% ============================================================

% --- Perfect positive patients (p001-p010) ---
% Treatment held: norepinephrine was sufficient on its own

low_sofa(p001). normal_lactate(p001). adequate_map_before(p001). young_patient(p001). low_comorbidity(p001).
low_sofa(p002). normal_lactate(p002). high_map_before(p002). young_patient(p002). low_comorbidity(p002).
low_sofa(p003). normal_lactate(p003). adequate_map_before(p003). young_patient(p003). low_comorbidity(p003).
low_sofa(p004). normal_lactate(p004). high_map_before(p004). young_patient(p004). low_comorbidity(p004).
low_sofa(p005). normal_lactate(p005). adequate_map_before(p005). young_patient(p005). low_comorbidity(p005).
low_sofa(p006). normal_lactate(p006). high_map_before(p006). young_patient(p006). low_comorbidity(p006).
low_sofa(p007). normal_lactate(p007). adequate_map_before(p007). young_patient(p007). low_comorbidity(p007).
low_sofa(p008). normal_lactate(p008). high_map_before(p008). young_patient(p008). low_comorbidity(p008).
low_sofa(p009). normal_lactate(p009). adequate_map_before(p009). young_patient(p009). low_comorbidity(p009).
low_sofa(p010). normal_lactate(p010). high_map_before(p010). young_patient(p010). low_comorbidity(p010).

% --- Perfect negative patients (n001-n010) ---
% Treatment escalated: norepinephrine was not sufficient on its own

high_sofa(n001). severe_lactate(n001). very_low_map_before(n001). elderly_patient(n001). high_comorbidity(n001).
high_sofa(n002). severe_lactate(n002). low_map_before(n002). elderly_patient(n002). high_comorbidity(n002).
high_sofa(n003). severe_lactate(n003). very_low_map_before(n003). elderly_patient(n003). high_comorbidity(n003).
high_sofa(n004). severe_lactate(n004). low_map_before(n004). elderly_patient(n004). high_comorbidity(n004).
high_sofa(n005). severe_lactate(n005). very_low_map_before(n005). elderly_patient(n005). high_comorbidity(n005).
high_sofa(n006). severe_lactate(n006). low_map_before(n006). elderly_patient(n006). high_comorbidity(n006).
high_sofa(n007). severe_lactate(n007). very_low_map_before(n007). elderly_patient(n007). high_comorbidity(n007).
high_sofa(n008). severe_lactate(n008). low_map_before(n008). elderly_patient(n008). high_comorbidity(n008).
high_sofa(n009). severe_lactate(n009). very_low_map_before(n009). elderly_patient(n009). high_comorbidity(n009).
high_sofa(n010). severe_lactate(n010). low_map_before(n010). elderly_patient(n010). high_comorbidity(n010).
