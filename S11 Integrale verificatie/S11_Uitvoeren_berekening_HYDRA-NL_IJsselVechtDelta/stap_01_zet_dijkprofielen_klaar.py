# -*- coding: utf-8 -*-
"""
Created on Tue Jun 11 09:39:14 2019

Zet de profielen klaar voor 4066.10

Deze profielen worden overgenomen uit PR3871.20, in PR4066.10 worden exact dezelfde HBN-berekeningen gemaakt, maar nu met andere modelonzekerheden voor de golven

@author: daggenvoorde
"""

import os
import pandas as pd
import tqdm

WM = os.path.join('..', 'Interne_controles_special')
locdatadir = os.path.join('..', '..', 'Controle_databases', 'GIS_kaart',
                          'Normtrajectdata')

basisprof = os.path.join('..','Profielen', '1op3.prfl')

with open(basisprof, 'r') as f:
    proflines = f.readlines()
for db in os.listdir(WM):
    traject = db.split('_')[2]
    locdata = pd.read_excel(os.path.join(locdatadir, traject,
                                       f'Database_{traject}.xlsx'))
    print(f'{db} bevat {len(locdata)} locaties')
    for idx, row in tqdm.tqdm(locdata.iterrows(), total=len(locdata)):
        orient = row.orientatie
        loc = row.Hydranaam
        
        newproflines = proflines
        newprofdir = os.path.join(WM, db, loc, 'Profielen')
        if not os.path.exists(newprofdir):
            os.makedirs(newprofdir)
        
        for i, line in enumerate(newproflines):
            if line.startswith('RICHTING'):
                break
        newproflines[i] = f'RICHTING\t{orient}\n'
        print('Locatie, dijknormaal = ',loc, orient)
        
        with open(os.path.join(newprofdir, '1op3.prfl'), 'w') as f:
            for line in proflines:
                f.write(line)