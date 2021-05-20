# -*- coding: utf-8 -*-
"""
Created on Wed May 15 12:28:44 2019

Aanmaken van Hydra-NL berekeningen

@author: daggenvoorde
"""

import os
import sqlite3
import pandas as pd
from datetime import datetime

#instellingen:
WS = False #waterstandsberekeningen aanmaken?
HBN = False#HBN-berekeningen aanmaken?
HS = True

WM = os.path.join('Interne_controles')

path = os.path.join('..',WM)

q = 50

def maakinvoer(BERPATH, invoertext_WS, invoertext_HBN, invoertext_HS,
               DBNAAM, LOC, X, Y, WERKMAP, type='WS', q=50):
    """
    Maak een berekeningspad aan.
    """
    
#    # als het pad als bestaat doe niks
#    if os.path.exists(BERPATH):
#        return

    now = datetime.now()
    date = f'{now.day:02d}-{now.month:02d}-{now.year:04d}'
    time = f'{now.hour}:{now.minute}:{now.second}'
    
    if type == 'WS':
        invoertext = invoertext_WS
    elif type == 'HBN':
        invoertext = invoertext_HBN
    elif type == 'HS':
        invoertext = invoertext_HS
    
    #pas de basisinvoer aan
    invoertext = invoertext.replace('$DBNAAM$', DBNAAM)
    invoertext = invoertext.replace('$LOC$', LOC)
    invoertext = invoertext.replace('$XCOORDINAAT$', str(X))
    invoertext = invoertext.replace('$YCOORDINAAT$', str(Y))
    invoertext = invoertext.replace('$WERKMAP$', WERKMAP)
    invoertext = invoertext.replace('$Q$', str(q))
    invoertext = invoertext.replace('$Q_m3$', str(q/1000))
    invoertext = invoertext.replace('$DATE$', f'{date} {time}')
    
    if not os.path.exists(BERPATH):
        os.makedirs(BERPATH)
    
    with open(os.path.join(BERPATH,'invoer.hyd'), 'w') as f:
        f.write(invoertext)

#%% maak berekeningen aan
for dbnaam in os.listdir(path):
    traject = dbnaam.split('_')[2]
    delta = dbnaam.split('_')[1]
    print(dbnaam)
    if delta == 'Vechtdelta':
        WS_basis = os.path.join('..', 'basisinvoer', 'invoer_WS_Vecht.hyd')
        WS_onz = os.path.join('..', 'basisinvoer', 'invoer_WS_onz_Vecht.hyd')        
        HBN_basis = os.path.join('..', 'basisinvoer', 'invoer_HBN_Vecht.hyd')
        HS_onz = os.path.join('..', 'basisinvoer', 'invoer_HS_onz_Vecht.hyd')
        with open(WS_basis, 'r') as f:
            invoertext_WS = f.read()
        with open(WS_onz, 'r') as f:
            invoertext_WS_onz = f.read()
        with open(HBN_basis, 'r') as f:
            invoertext_HBN = f.read()
        with open(HS_onz, 'r') as f:
            invoertext_HS = f.read()
    elif delta == 'IJsseldelta':
        WS_basis = os.path.join('..', 'basisinvoer', 'invoer_WS_IJssel.hyd')
        WS_onz = os.path.join('..', 'basisinvoer', 'invoer_WS_onz_IJssel.hyd')
        HBN_basis = os.path.join('..', 'basisinvoer', 'invoer_HBN_IJssel.hyd')
        HS_onz = os.path.join('..', 'basisinvoer', 'invoer_HS_onz_IJssel.hyd')
        with open(WS_basis, 'r') as f:
            invoertext_WS = f.read()
        with open(WS_onz, 'r') as f:
            invoertext_WS_onz = f.read()
        with open(HBN_basis, 'r') as f:
            invoertext_HBN = f.read()
        with open(HS_onz, 'r') as f:
            invoertext_HS = f.read()
    else:
        raise ValueError(f'{delta} onbekend')

    conn_path = os.path.join(path, dbnaam, f'copy_{dbnaam}.sqlite') 
    if not os.path.exists(conn_path):
        print(f'Nog geen db beschikbaar: {dbnaam}')
        continue
    
    conn = sqlite3.connect(conn_path)
    locaties = pd.read_sql('SELECT * FROM HRDLocations', conn)
    conn.close()
    locaties.set_index('Name', inplace=True)

    print(traject)
    for loc in locaties.index:
        if loc.startswith('_') or os.path.isfile(os.path.join(path, dbnaam, loc)):
            continue
        loc = loc.replace('Ijsselmeer', 'IJsselmeer')
        X = int(locaties.at[loc, 'XCoordinate'])
        Y = int(locaties.at[loc, 'YCoordinate'])
        
        if WS:
            BERNAAM = 'WS_zonz'
            BERPATH = os.path.join(path, dbnaam, loc, 'Berekeningen', BERNAAM)
            BERPATH = os.path.abspath(BERPATH)
            
            #maak waterstandsinvoer aan
            maakinvoer(BERPATH, invoertext_WS, invoertext_HBN, invoertext_HS,
                       dbnaam, loc, X, Y, WM, type='WS')
            
            BERNAAM = 'WS_onz'
            BERPATH = os.path.join(path, dbnaam, loc, 'Berekeningen', BERNAAM)
            BERPATH = os.path.abspath(BERPATH)
            
            #maak waterstandsinvoer aan
            maakinvoer(BERPATH, invoertext_WS_onz, invoertext_HBN, invoertext_HS,
                       dbnaam, loc, X, Y, WM, type='WS')
                
        #HBN
        if HBN:
            BERNAAM = f'HBN_zonz_1op3_{q}'
            BERPATH = os.path.join(path, dbnaam, loc, 'Berekeningen', BERNAAM)
            BERPATH = os.path.abspath(BERPATH)

            maakinvoer(BERPATH, invoertext_WS, invoertext_HBN, invoertext_HS,
                   dbnaam, loc, X, Y, WM, type='HBN', q=q)
        
        if HS:
            BERNAAM = 'HS_onz'
            BERPATH = os.path.join(path, dbnaam, loc, 'Berekeningen', BERNAAM)
            BERPATH = os.path.abspath(BERPATH)

            maakinvoer(BERPATH, invoertext_WS, invoertext_HBN, invoertext_HS,
                   dbnaam, loc, X, Y, WM, type='HS')            
            
            
