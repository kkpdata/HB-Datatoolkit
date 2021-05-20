# -*- coding: utf-8 -*-
"""
Created on Sat May 26 10:05:44 2018

@author: Kuijper
"""

import os
import pandas as pd
import sqlite3
import matplotlib as mpl
import matplotlib.style as style

rc_defaults = dict(mpl.rcParams)
# if not installed in "C:\Users\Stijnen\.matplotlib\stylelib" then use locally from directory 'stylelib' with style.context('stylelib/muted.mplstyle'):
# style.use('HKV')


dbPad = r'd:\20201120_backup_d-schijf\4280.10_databases_IJVD\Controle_databases\Databases_na_ext_test\10-3'

for ii, dbNaam in enumerate(os.listdir(dbPad)):
    if (('hlcd' in dbNaam) or ('.config' in dbNaam) or ('.zip' in dbNaam)):
        continue
    savefol = 'Controle_{}'.format(dbNaam.split('.')[0]) 
    if not os.path.exists(savefol):
        os.makedirs(savefol)

    # Open de database
    dbFile = os.path.join(dbPad,dbNaam)
    conn = sqlite3.connect(dbFile)
    query = 'SELECT * FROM HRDLocations'
    locaties = pd.read_sql(query, conn)
    locaties = locaties.Name.tolist()
    for iii, locatie in enumerate(locaties):
        if iii < 100:
            continue
        print('db {}/{}, locatie {}/{} - {}'.format(ii+1, len(os.listdir(dbPad)), iii+1, len(locaties), locatie))
        # Bepaal de locatie id
        tabel = 'HRDLocations'
        query = 'SELECT * FROM %s WHERE Name = "%s"' % (tabel,locatie)
        HRD   = pd.read_sql(query,conn)
        locid = HRD['HRDLocationId'][0]
    
        # Bepaal de berekening id's bij deze locatie
        tabel = 'HydroDynamicData'
        query = f'SELECT * FROM {tabel} WHERE HRDLocationId = {locid:.0f}'
        HDD   = pd.read_sql(query,conn)
        HDD.set_index(['HydroDynamicDataId'],inplace=True)
        berids = HDD.index.tolist()
         
        # Lees de invoervariabelen bij deze berekening id's
        tabel = 'HydroDynamicInputData'
        berlist_txt = ','.join([str(x) for x in berids])
        query = f'SELECT * FROM {tabel} WHERE HydroDynamicDataId IN ({berlist_txt})'
        HDID  = pd.read_sql(query,conn)
        HDID.set_index(['HydroDynamicDataId','HRDInputColumnId'],inplace=True)
        HDID  = HDID.unstack()
        kolomnamen = pd.read_sql('SELECT ColumnName FROM HRDInputVariables',conn)
        HDID.columns = kolomnamen.values.squeeze().tolist()
         
        # Lees de resultaatvaribaleen bij deze berekening id's
        tabel = 'HydroDynamicResultData'
        query = 'SELECT * FROM %s WHERE HydroDynamicDataId IN (%s)' % (tabel,','.join([str(x) for x in berids]))
        HDOD  = pd.read_sql(query,conn)
        HDOD.set_index(['HydroDynamicDataId','HRDResultColumnId'],inplace=True)
        HDOD  = HDOD.unstack()
        kolomnamen = pd.read_sql('SELECT ColumnName FROM HRDResultVariables',conn)
        if len(HDOD.columns) == 1: #alleen waterstanden in de database
            HDOD.columns = [kolomnamen.values.squeeze().tolist()[0]]
        else:
            HDOD.columns = kolomnamen.values.squeeze().tolist()
        
        resultaat = HDID.join(HDOD).join(HDD)
        xlsFile = os.path.join(os.getcwd(),savefol,'SQLite_data_%s.xlsx' % locatie)
        HDID.join(HDOD).join(HDD).to_excel(xlsFile,sheet_name='Data')
        
        # Schrijf uitvoer naar een JSON-bestand om in te laden in Vega
        out = resultaat.to_json(orient='records')[1:-1]

        # vega code 
        with open('Vega_Base_IJVD.txt', 'r') as f:
            text = f.read()
        
        text = text.replace('$DATA$',out)
        with open(os.path.join(savefol,'VEGAcode_{}.txt'.format(locatie)) , 'w') as f:
            f.write(text)        
    conn.close()
