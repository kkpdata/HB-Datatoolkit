# -*- coding: utf-8 -*-
"""
Created on Fri Jul  3 14:09:04 2020

Schrijf hier waarvoor deze module is geschreven

@author: daggenvoorde
"""

import os
import sqlite3
import pandas as pd
from datetime import datetime
import shutil
import numpy as np
from shapely.geometry import Point
import geopandas as gpd
import tqdm

def delete_all(table, conn):
    """
    Delete all rows in the tasks table
    :param conn: Connection to the SQLite database
    :return:
    """
    sql = 'DELETE FROM {}'.format(table)
    cur = conn.cursor()
    cur.execute(sql)

now = datetime.now()
date = f'{now.day:02d}-{now.month:02d}-{now.year:04d}'
time = f'{now.hour}:{now.minute}:{now.second}'

#verzamel alle locaties

query = 'SELECT * FROM HRDLocations'
HRDLocations = pd.DataFrame(columns=['HRDLocationId', 'LocationTypeId', 'Name',
                                     'XCoordinate', 'YCoordinate',
                                     'WaterLevelCorrection', 'BedLevel'])

dbdir = r'd:\4280.10_databases_IJVD\Controle_databases\Databases_na_ext_test'
tracks = []

for traject in os.listdir(dbdir):
    path = os.path.join(dbdir, traject)
    db = [f for f in os.listdir(path) if 'terBeoordeling.sqlite' in f][0]
    conn = sqlite3.connect(os.path.join(path, db))
    HRDLocs = pd.read_sql(query, conn)
    
    HRDLocations = HRDLocations.append(HRDLocs, ignore_index=True, sort=False)
    
    if 'IJsseldelta' in db:
        regionid = 5
    elif 'Vechtdelta' in db:
        regionid = 6
    traject = db.split('_')[2]
    trajectnum = str(HRDLocs.iloc[0]['HRDLocationId'])[1:4]
    tid = int(f'{regionid}{trajectnum}')
    tracks.append([tid, regionid, traject, db])
    
    #pas tabel general aan in de HRD
    General = pd.read_sql('SELECT * FROM General', conn)
    General['TrackID'] = tid
    General['Track'] = int(trajectnum)
    General['CreationDate'] = f'{date} {time}'
    delete_all('General', conn)
    General.to_sql('General', conn, if_exists='append', index=False)
    conn.close()
tracks = pd.DataFrame(tracks, columns=['TrackId', 'RegionId',
                                       'Name', 'HRDFileName'])    

#%% pas HLCD aan

path = os.path.join('..', 'Base_HLCD_config', 'hlcd.sqlite')
pathnew = os.path.join('..', 'New_HLCD_config', 'hlcd.sqlite')
shutil.copy2(path, pathnew)

conn = sqlite3.connect(pathnew)
#tracks
delete_all('Tracks', conn)
tracks.to_sql('Tracks', conn, if_exists='append', index=False)
tracks['trajectnum'] = [str(x)[1:4] for x in tracks.TrackId]

#pas Locations aan
rows = []
for idx, row in  tqdm.tqdm(HRDLocations.iterrows(), total=8):
    trajectnum = str(row.HRDLocationId)[1:4]
    tid = tracks.loc[tracks.trajectnum==trajectnum, 'TrackId'].values[0]
    row = [row.HRDLocationId, 2, tid, row.HRDLocationId,
           np.nan, np.nan, np.nan, np.nan]
    rows.append(row)

tmp = pd.read_sql('SELECT * FROM Locations', conn)
Locations = pd.DataFrame(rows, columns=tmp.columns)
del tmp
delete_all('Locations', conn)
Locations.to_sql('Locations', conn, if_exists='append', index=False)

# pas General aan:
General = pd.read_sql('SELECT * FROM General', conn)
General.loc[:, 'CreationDate'] = f'{date} {time}'
delete_all('General', conn)
General.to_sql('General', conn, if_exists='append', index=False)

# Verwijder overbodige ruimte uit de Database
conn.isolation_level = None
conn.execute('VACUUM')
conn.isolation_level = ''
conn.commit()
conn.close()

#%% pas config aan
print('Maak .configs')
path = os.path.join('..', 'Base_HLCD_config', 'Base.config.sqlite')
#instellingen
xlsx = pd.ExcelFile('Inhoud Config_VIJD.xlsx')
# to read all sheets to a map
data = {}
for sheet_name in xlsx.sheet_names:
    data[sheet_name] = xlsx.parse(sheet_name)
#shape met gebieden met instellingen
rekensets = gpd.read_file(os.path.join('NumericsSettingsShapes', 
                                       'NumericsSettings_VIJD.shp'))
for traject in tqdm.tqdm(os.listdir(dbdir)):
    pth = os.path.join(dbdir, traject)
    db = [f for f in os.listdir(pth) if 'terBeoordeling.sqlite' in f][0]
    conn = sqlite3.connect(os.path.join(pth, db))
    HRDLocs = pd.read_sql(query, conn)
    conn.close()

    pathnew = os.path.join('..', 'New_HLCD_config', f'{db.replace(".", ".config.")}')
#    if os.path.exists(pathnew):
#        continue
    shutil.copy2(path, pathnew)
    conn = sqlite3.connect(pathnew)

    table = 'DesignTablesSettings'
    base = data[table]
    df = [pd.DataFrame(columns=base.columns)]
    for idx, row in HRDLocs.iterrows():
        tmp = base.copy()
        tmp[base.columns[0]] = row.HRDLocationId
        df.append(tmp)
    df = pd.concat(df, axis=0)

    # clear existing table
    delete_all(table, conn)
    df.to_sql(table, conn, if_exists='append', index=False)
    
    table = 'TimeIntegrationSettings'
    base = data[table]
    df = [pd.DataFrame(columns=base.columns)]
    for idx, row in HRDLocs.iterrows():
        tmp = base.copy()
        tmp[base.columns[0]] = row.HRDLocationId
        df.append(tmp)
    df = pd.concat(df, axis=0)

    # clear existing table
    delete_all(table, conn)
    df.to_sql(table, conn, if_exists='append', index=False)
    
    table = 'NumericsSettings'
    base = data[f'{table}_A']
    df = [pd.DataFrame(columns=base.columns)]
    
    for idx, row in HRDLocs.iterrows():
        rekenset = rekensets.loc[rekensets.intersects(Point(row.XCoordinate,
                                                            row.YCoordinate))].Set.values[0]

        base = data[f'{table}_{rekenset}']
        tmp = base.copy()
        tmp[base.columns[0]] = row.HRDLocationId
        df.append(tmp)
    df = pd.concat(df, axis=0)
    # clear existing table
    delete_all(table, conn)
    df.to_sql(table, conn, if_exists='append', index=False)

    # table General
    General = pd.read_sql('SELECT * FROM General', conn)
    General['CreationDate'] = f'{date} {time}'
    General['HRDName'] = db
    General['HRDCreationDate'] = f'{date} {time}'
    General['HRDTrackID'] = tracks.loc[tracks.HRDFileName==db, 'TrackId'].values[0]
    General['HRDNameRegion'] = db.split('_')[1]
    delete_all('General', conn)
    General.to_sql('General', conn, if_exists='append', index=False)

    # Verwijder overbodige ruimte uit de Database
    conn.isolation_level = None
    conn.execute('VACUUM')
    conn.isolation_level = ''
    conn.commit()
    conn.close()
