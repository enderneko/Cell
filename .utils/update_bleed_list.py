import os
import requests
import pandas as pd
from tqdm import tqdm

csv_file = '.utils/SpellEffect.csv'
lua_file = 'Defaults/Indicator_Bleeds.lua'

if os.path.exists(csv_file): os.remove(csv_file)

# ------------------------------------------------------------------------- #
#                                  download                                 #
# ------------------------------------------------------------------------- #
response = requests.get('https://wago.tools/db2/SpellEffect/csv', stream=True)
size = int(response.headers.get('content-length', 0))

progress = tqdm(total=size, unit='B', unit_scale=True)

with open(csv_file, 'wb') as f:
    for chunk in response.iter_content(1024):
        if chunk:
            f.write(chunk)
            progress.update(len(chunk))

progress.close()

# ------------------------------------------------------------------------- #
#                                 update lua                                #
# ------------------------------------------------------------------------- #
df = pd.read_csv(csv_file, usecols=['ID','EffectMechanic','SpellID'], encoding='utf-8', index_col=['ID'])
df = df.loc[df['EffectMechanic'] == 15]
df = df.sort_values(by='SpellID', ascending=False)
# print(df.head())
# df.to_csv('result.csv', columns=['SpellID','EffectMechanic'], index=False)

with open(lua_file, 'r+') as file:
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
    for index, row in df.iterrows():
        file.write('    ['+str(row['SpellID'])+'] = true,\n')
    file.write('}')

# ------------------------------------------------------------------------- #
#                                 delete csv                                #
# ------------------------------------------------------------------------- #
if os.path.exists(csv_file): os.remove(csv_file)