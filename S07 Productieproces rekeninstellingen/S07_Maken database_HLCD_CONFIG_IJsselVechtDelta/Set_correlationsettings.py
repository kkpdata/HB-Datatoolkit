# -*- coding: utf-8 -*-
"""
Created on Fri Nov 20 10:55:11 2020

Schrijf hier waarvoor deze module is geschreven

@author: daggenvoorde
"""

import os
import sqlite3
import tqdm
import shutil

trajecten = ['225', '11-2', '11-1', '10-3', '10-2', '8-4'] # deze trajecten moeten een aangepaste hlcd hebben.
configdir = os.path.join('..', 'New_HLCD_config')
dstdir = os.path.join('..', 'Databases_na_ext_test')

for traject in tqdm.tqdm(os.listdir(dstdir)):
    if traject in ['53-2', '52-3', '52-4', '206', '52a-1', '53-3']:
        # deze trajecten zijn al eerder opgeleverd
        continue
    pth = os.path.join(dstdir, traject)
    config = [f for f in os.listdir(pth) if 'config' in f][0]
    
    #copy config
    shutil.copy2(os.path.join(configdir, config),
                 os.path.join(pth, config))
    #copy hlcd
    shutil.copy2(os.path.join(configdir, 'hlcd.sqlite'),
                 os.path.join(pth, 'hlcd.sqlite'))
    
    #adjust hlcd if necessary
    if traject in trajecten:
        conn = sqlite3.connect(os.path.join(pth, 'hlcd.sqlite'))
        query = 'UPDATE LoadVariablesData SET CorrelationTypeId = NULL WHERE RegionId = 5'
        conn.execute(query)
        
        # Verwijder overbodige ruimte uit de Database
        conn.isolation_level = None
        conn.execute('VACUUM')
        conn.isolation_level = ''
        conn.commit()
        conn.close()