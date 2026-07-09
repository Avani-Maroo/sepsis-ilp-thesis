% ============================================================
% Experiment 5 - Control Trial
% Background knowledge - hand-built ideal patients
% Perfect positive: low/very low MAP, high SOFA, elevated/severe lactate, elderly, high CCI
% Perfect negative: adequate/high MAP, low SOFA, normal lactate, young, low CCI
% ============================================================

% --- Perfect positive patients (p001-p010) ---
% Should receive norepinephrine: haemodynamically unstable, high organ dysfunction

very_low_map_before(p001). high_sofa(p001). elevated_lactate(p001). elderly_patient(p001). high_comorbidity(p001).
very_low_map_before(p002). high_sofa(p002). severe_lactate(p002). elderly_patient(p002). high_comorbidity(p002).
low_map_before(p003).      high_sofa(p003). elevated_lactate(p003). elderly_patient(p003). high_comorbidity(p003).
low_map_before(p004).      high_sofa(p004). severe_lactate(p004).   elderly_patient(p004). high_comorbidity(p004).
very_low_map_before(p005). high_sofa(p005). severe_lactate(p005).   elderly_patient(p005). high_comorbidity(p005).
very_low_map_before(p006). high_sofa(p006). elevated_lactate(p006). elderly_patient(p006). high_comorbidity(p006).
low_map_before(p007).      high_sofa(p007). severe_lactate(p007).   elderly_patient(p007). high_comorbidity(p007).
very_low_map_before(p008). high_sofa(p008). elevated_lactate(p008). elderly_patient(p008). high_comorbidity(p008).
low_map_before(p009).      high_sofa(p009). severe_lactate(p009).   elderly_patient(p009). high_comorbidity(p009).
very_low_map_before(p010). high_sofa(p010). elevated_lactate(p010). elderly_patient(p010). high_comorbidity(p010).

% --- Perfect negative patients (n001-n010) ---
% Should NOT receive norepinephrine: haemodynamically stable, low organ dysfunction

high_map_before(n001). low_sofa(n001). normal_lactate(n001). young_patient(n001). low_comorbidity(n001).
adequate_map_before(n002). low_sofa(n002). normal_lactate(n002). young_patient(n002). low_comorbidity(n002).
high_map_before(n003). low_sofa(n003). normal_lactate(n003). young_patient(n003). low_comorbidity(n003).
adequate_map_before(n004). low_sofa(n004). normal_lactate(n004). young_patient(n004). low_comorbidity(n004).
high_map_before(n005). low_sofa(n005). normal_lactate(n005). young_patient(n005). low_comorbidity(n005).
adequate_map_before(n006). low_sofa(n006). normal_lactate(n006). young_patient(n006). low_comorbidity(n006).
high_map_before(n007). low_sofa(n007). normal_lactate(n007). young_patient(n007). low_comorbidity(n007).
adequate_map_before(n008). low_sofa(n008). normal_lactate(n008). young_patient(n008). low_comorbidity(n008).
high_map_before(n009). low_sofa(n009). normal_lactate(n009). young_patient(n009). low_comorbidity(n009).
adequate_map_before(n010). low_sofa(n010). normal_lactate(n010). young_patient(n010). low_comorbidity(n010).
