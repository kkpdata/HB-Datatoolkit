# -*- coding: utf-8 -*-
"""
Created on Mon Jun  8 16:22:09 2020

vindt voor alle locaties in het SWAN-model welk percentage van de
belastingcombinaties een locatie nat is.

@author: daggenvoorde
"""

import os
import pandas as pd
import tqdm
SWANdir = r'..\SWAN'

N = 4368
colnames = ['X', 'Y', 'Depth']
for idx, somid in tqdm.tqdm(enumerate(os.listdir(SWANdir)), total=N):
    file = os.path.join(SWANdir, somid, f'{somid}_02.tab')
    data = pd.read_csv(file, skiprows=7, delim_whitespace=True,
                       usecols=[0, 1, 2], names=colnames)
    if idx == 0: #initieer de lijst
        results = data.copy()
        results.columns = ['X', 'Y', 'Nat']
        results.Nat = (results.Nat > 0).astype(int)
    else:
        results.Nat = results.Nat + (data.Depth > 0).astype(int)

results['Perc_nat'] = results.Nat / N

#results.to_csv('Percentage_nat.csv')
