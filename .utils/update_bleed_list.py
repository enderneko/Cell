import os
import requests
import pandas as pd
from tqdm import tqdm

lua_file = 'Defaults/Indicator_Bleeds.lua'
csv_files = [
    ('.utils/SpellEffect.csv', 'https://wago.tools/db2/SpellEffect/csv'),
    ('.utils/SpellCategories.csv', 'https://wago.tools/db2/SpellCategories/csv'),
    ('.utils/SpellName.csv', 'https://wago.tools/db2/SpellName/csv'),
    ('.utils/SpellNameCN.csv', 'https://wago.tools/db2/SpellName/csv?locale=zhCN'),
]

for csv_file, url in csv_files:
    if os.path.exists(csv_file): os.remove(csv_file)

# ------------------------------------------------------------------------- #
#                                  download                                 #
# ------------------------------------------------------------------------- #
for csv_file, url in csv_files:
    # os.makedirs(os.path.dirname(csv_file), exist_ok=True)

    response = requests.get(url, stream=True)
    size = int(response.headers.get('content-length', 0))

    progress = tqdm(total=size, unit='B', unit_scale=True, desc=f'Downloading {csv_file}')

    with open(csv_file, 'wb') as f:
        for chunk in response.iter_content(1024):
            if chunk:
                f.write(chunk)
                progress.update(len(chunk))

    progress.close()

# ------------------------------------------------------------------------- #
#                                   filter                                  #
# ------------------------------------------------------------------------- #
spell_effect_df = pd.read_csv(csv_files[0][0], usecols=['Effect','EffectMechanic','SpellID'], encoding='utf-8')

# SpellCategories.csv Mechanic == 15 and SpellEffect.csv Effect == 6
spell_categories_df = pd.read_csv(csv_files[1][0], usecols=['Mechanic','SpellID'], encoding='utf-8')
spell_categories_df = spell_categories_df.loc[spell_categories_df['Mechanic'] == 15]
spell_categories_df = spell_categories_df['SpellID']
spell_categories_df = spell_effect_df[(spell_effect_df['Effect'] == 6) & (spell_effect_df['SpellID'].isin(spell_categories_df))]

# SpellEffect.csv EffectMechanic == 15 and Effect == 6
spell_effect_df = spell_effect_df.loc[(spell_effect_df['EffectMechanic'] == 15) & (spell_effect_df['Effect'] == 6)]

# merge
merged_df = pd.merge(spell_effect_df[['SpellID']], spell_categories_df[['SpellID']], on='SpellID', how='outer')
merged_df = merged_df.sort_values(by='SpellID', ascending=False)
merged_df = merged_df.drop_duplicates(subset='SpellID')

# enUS
en_df = pd.read_csv(csv_files[2][0], encoding='utf-8')
merged_df = pd.merge(merged_df, en_df, left_on='SpellID', right_on='ID', how='left')

# zhCN
cn_df = pd.read_csv(csv_files[3][0], encoding='utf-8')
merged_df = pd.merge(merged_df, cn_df, left_on='SpellID', right_on='ID', how='left')

# rename columns
merged_df = merged_df[["SpellID", 'Name_lang_x', 'Name_lang_y']]
merged_df.columns = ['SpellID', 'EN', 'CN']

# print(df.head())
# merged_df.to_csv('result.csv', index=False)

# ------------------------------------------------------------------------- #
#                                 update lua                                #
# ------------------------------------------------------------------------- #
with open(lua_file, 'r+', encoding='utf-8') as file:
    while True:
        line = file.readline()
        if not line:
            break
        if line.strip() == 'bleedList = {':
            break

    # delete old
    file.seek(file.tell())
    file.truncate()

    # write new
    for index, row in merged_df.iterrows():
        file.write('    ['+str(row['SpellID'])+'] = true, -- '+str(row['CN'])+' - '+str(row['EN'])+'\n')
    file.write('}')

# ------------------------------------------------------------------------- #
#                                 delete csv                                #
# ------------------------------------------------------------------------- #
# for csv_file, url in csv_files:
#     if os.path.exists(csv_file): os.remove(csv_file)