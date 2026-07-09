import csv
import os

INPUT_FILE = 'Pipeline_2.csv' #update as needed

def categorise_sofa(val):
    if val is None:
        return 'missing_sofa'
    if val < 6:
        return 'low_sofa'
    elif val < 10:
        return 'moderate_sofa'
    else:
        return 'high_sofa'

def categorise_lactate(val):
    if val is None:
        return 'missing_lactate'
    if val < 2:
        return 'normal_lactate'
    elif val <= 4:
        return 'elevated_lactate'
    else:
        return 'severe_lactate'

def categorise_map(val):
    if val is None:
        return 'missing_map_before'
    if val < 55:
        return 'very_low_map_before'
    elif val < 65:
        return 'low_map_before'
    elif val < 80:
        return 'adequate_map_before'
    else:
        return 'high_map_before'

def categorise_age(val):
    if val < 50:
        return 'young_patient'
    elif val < 70:
        return 'middle_aged_patient'
    else:
        return 'elderly_patient'

def categorise_cci(val):
    if val is None:
        return None
    if val <= 2:
        return 'low_comorbidity'
    elif val <= 5:
        return 'moderate_comorbidity'
    else:
        return 'high_comorbidity'

pos_examples = []
neg_examples = []
bk_facts = []

with open(INPUT_FILE) as f:
    reader = csv.DictReader(f)
    for row in reader:
        stay_id = row['stay_id']
        label = row['label']

        try:
            sofa = float(row['sofa_before_norepi']) if row['sofa_before_norepi'] else None
        except:
            sofa = None
        try:
            lactate = float(row['lactate_before_norepi']) if row['lactate_before_norepi'] else None
        except:
            lactate = None
        try:
            map_val = float(row['map_before_norepi']) if row['map_before_norepi'] else None
        except:
            map_val = None
        try:
            age = int(float(row['anchor_age']))
        except:
            age = None
        try:
            cci = int(float(row['cci'])) if row['cci'] else None
        except:
            cci = None

        if label == 'positive':
            pos_examples.append(f'pos(treatment_held({stay_id})).')
        elif label == 'negative':
            neg_examples.append(f'neg(treatment_held({stay_id})).')

        bk_facts.append(f'{categorise_sofa(sofa)}({stay_id}).')
        bk_facts.append(f'{categorise_lactate(lactate)}({stay_id}).')
        bk_facts.append(f'{categorise_map(map_val)}({stay_id}).')
        if age:
            bk_facts.append(f'{categorise_age(age)}({stay_id}).')
        cci_cat = categorise_cci(cci)
        if cci_cat:
            bk_facts.append(f'{cci_cat}({stay_id}).')

bk_content = '% Background knowledge - Pipeline 2\n' + '\n'.join(bk_facts)
with open('positive_only/bk.pl', 'w') as f:
    f.write(bk_content)
with open('full_experiment/bk.pl', 'w') as f:
    f.write(bk_content)

with open('positive_only/exs.pl', 'w') as f:
    f.write('% Positive examples only - sanity check\n')
    f.write('\n'.join(pos_examples))

with open('full_experiment/exs.pl', 'w') as f:
    f.write('% Positive examples\n')
    f.write('\n'.join(pos_examples))
    f.write('\n\n% Negative examples\n')
    f.write('\n'.join(neg_examples))

print('Done! Files written:')
print(f'  positive_only/exs.pl  — {len(pos_examples)} positive examples only')
print(f'  full_experiment/exs.pl — {len(pos_examples)} positive, {len(neg_examples)} negative examples')
print(f'  bk.pl — {len(bk_facts)} facts (written to both folders)')
