# -*- coding: utf-8 -*-
"""
Created on Fri Sep 25 10:41:37 2020

zet HLCD, HRD en .config klaar

@author: daggenvoorde
"""

import os
import shutil
import tqdm

hrdbdir = os.path.join('..', '..', 'Controle_databases', 'Databases')
configdir = os.path.join('..', '..', 'Controle_databases', 'New_HLCD_config')
for hrd in tqdm.tqdm(os.listdir(hrdbdir)):
    if not os.path.isfile(os.path.join(hrdbdir, hrd)):
        continue
    traject = hrd.split('_')[2]
    print(traject)
    if not traject == '10-2':
        continue
    if os.path.exists(os.path.join('..', traject)):
        continue
    os.makedirs(os.path.join('..', traject))
    
    #copy hrd
    shutil.copy2(os.path.join(hrdbdir, hrd), os.path.join('..', traject, hrd))    
    #copy hlcd
    shutil.copy2(os.path.join(configdir, 'hlcd.sqlite'), os.path.join('..', traject, 'hlcd.sqlite'))    
    #copy config
    configname = hrd.replace('.sqlite', '.config.sqlite')
    shutil.copy2(os.path.join(configdir, configname), os.path.join('..', traject, configname))
    