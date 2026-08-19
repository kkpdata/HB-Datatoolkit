# -*- coding: utf-8 -*-
"""
Created on Thu Feb 24 10:13:50 2022

Created on  : 24-02-2022
Author      : Cees Oerlemans
Project     : PR4539.10 BOI Meren
Description : Script voor leggen koppeling tussen HRDLocations en golfmodel (SWAN/Bretschneider)
"""

import os
from pathlib import Path
import pandas as pd
pd.options.mode.chained_assignment = None  # default='warn'
import numpy as np
import tqdm
from re import search

parent_dir = Path(__file__).resolve().parent.parent
print(f'we werken in {parent_dir}')
workdir = os.path.join(parent_dir,'NWM')

def info_golven(koptabfile, swan_points_file, swan_check_file): 
    
    """
    # Uitvoer
    # Dataframe "df_dhydro_swan" met meerdere kolommen: 
    # 1. HRDlocationID
    # 2. HRDLocationName
    # 3. De naam van de gebruikte locatie in DHYDRO (BaseLineName)
    # 4. TrackCode (normtjraject) 
    # 5. X-coördinaat locatie voor database
    # 6. Y-coördinaat locatie voor database
    # 7. True/False of golven uit SWAN komen
    # 8. True/False of golven uit Bretschneider komen
    # 9. Bretschneider ID van de basislocatie
    #     Dit kan voor situaties met golven uit SWAN een NaN zijn.
    """
    
    #lees SWAN points in
    SWANpoints = pd.read_csv(os.path.join(dir_generalmodeldata, swan_points_file), sep=',')
    SWANpoints['X'] = SWANpoints['X'] - 10
    SWANpoints['X'] = round(SWANpoints['X'],0).astype(int)
    SWANpoints['Y'] = SWANpoints['Y'] - 10
    SWANpoints['Y'] = round(SWANpoints['Y'],0).astype(int)

    #lees koppeltabel in
    koptab = pd.read_csv(koptabfile, sep=';')
    koptab['x'] = round(koptab['x'], 0).astype(int)
    koptab['y'] = round(koptab['y'], 0).astype(int)
    
    #maak SWAN koppeltabel 
    df_dhydro_swan = pd.DataFrame(columns=['HRDLocationID', 'HRDLocationName', 'BaseLineName', 'TrackCode', 'XCoordinate', 'YCoordinate', 'SWAN', 'Bretschneider', 'BretID'])
    df_dhydro_swan['HRDLocationID'] = koptab['HRDLocationID']
    df_dhydro_swan['HRDLocationName'] = koptab['Hydranaam']
    df_dhydro_swan['BaseLineName']  = koptab['Name']
    df_dhydro_swan['TrackCode']     = koptab['normtraject']
    df_dhydro_swan['XCoordinate']   = koptab['x']
    df_dhydro_swan['YCoordinate']   = koptab['y']
    
    #toevoegen Bretschneider of SWAN info
    df_dhydro_swan['SWAN'] = True
    df_dhydro_swan['Bretschneider'] = False
    df_dhydro_swan['BretID'] = -999
    
    #check of alle basislocaties die gebruik maken van SWAN ook in de SWAN-resultaten aanwezig zijn
    # lees headerregel
    select_kolommen = ['Xp', 'Yp', 'Hsig', 'TPsmoo', 'Tm_10', 'Dir']
    with open(swan_check_file, 'r') as f:
        for line in f.readlines():
            if select_kolommen[0] in line:
                header = line[1:].split()
                break
    select_indices = [header.index(col) for col in select_kolommen]
    
    # lees golfbestand uit
    swan_resultaat = pd.read_table(swan_check_file, delim_whitespace=True, comment='%', header=None, 
                              usecols=select_indices, names=select_kolommen)
    
    basislocaties_swan = df_dhydro_swan['BaseLineName'].loc[df_dhydro_swan['SWAN'] == True].to_list()
    for basisloc in basislocaties_swan:
        x_koppel = df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'XCoordinate'].to_list()[0]
        y_koppel = df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'YCoordinate'].to_list()[0]
        # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Xp'] == x_koppel]
        # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Yp'] == y_koppel]
        SWANpoints_selection = swan_resultaat.loc[(swan_resultaat['Xp'] == x_koppel) & (swan_resultaat['Yp'] == y_koppel)]
        if x_koppel not in SWANpoints_selection['Xp'].to_list():
            print('Locatie ', basisloc, ' met coordinaten ', x_koppel, ' , ', y_koppel, 'heeft geen bijbehorende SWAN-locatie')
            
            #koppel met locatie die maximaal één X of Y coordinaat verschilt
            x_koppel_min = x_koppel - 1
            x_koppel_plus = x_koppel + 1
            y_koppel_min = y_koppel - 1
            y_koppel_plus = y_koppel + 1
            
            koppels = [(x_koppel_min, y_koppel_min),
                      (x_koppel_min, y_koppel), 
                      (x_koppel_min, y_koppel_plus),
                      (x_koppel, y_koppel_min),
                      (x_koppel, y_koppel),
                      (x_koppel, y_koppel_plus),
                      (x_koppel_plus, y_koppel_min),
                      (x_koppel_plus, y_koppel),
                      (x_koppel_plus, y_koppel_plus)]
            
            for koppel in koppels:
                SWANpoints_selection = swan_resultaat.loc[(swan_resultaat['Xp'] == koppel[0]) & (swan_resultaat['Yp'] == koppel[1])]
                if (koppel[0] in SWANpoints_selection['Xp'].to_list()):
                    print('Locatie ', basisloc, ' vervangen door ', koppel[0], ' , ', koppel[1])
                    df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'XCoordinate'] = koppel[0]
                    df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'YCoordinate'] = koppel[1]
                    break



            # #x_koppel_min matchen met y_koppel_min/y_koppel/y_koppel_plus
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Xp'] == x_koppel_min]
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Yp'] == y_koppel_min]
            # if x_koppel_min in SWANpoints_selection['Xp'].to_list():
            #     print('Locatie ', basisloc, ' vervangen door ', x_koppel_min, ' , ', y_koppel_min)
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'XCoordinate'] = x_koppel_min
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'YCoordinate'] = y_koppel_min
                
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Xp'] == x_koppel_min]
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Yp'] == y_koppel]
            # if x_koppel_min in SWANpoints_selection['Xp'].to_list():
            #     print('Locatie ', basisloc, ' vervangen door ', x_koppel_min, ' , ', y_koppel)
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'XCoordinate'] = x_koppel_min
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'YCoordinate'] = y_koppel
                
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Xp'] == x_koppel_min]
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Yp'] == y_koppel_plus]
            # if x_koppel_min in SWANpoints_selection['Xp'].to_list():
            #     print('Locatie ', basisloc, ' vervangen door ', x_koppel_min, ' , ', y_koppel_plus)
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'XCoordinate'] = x_koppel_min
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'YCoordinate'] = y_koppel_plus
                
            
            # #x_koppel matchen met y_koppel_min/y_koppel/y_koppel_plus
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Xp'] == x_koppel]
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Yp'] == y_koppel_min]
            # if x_koppel in SWANpoints_selection['Xp'].to_list():
            #     print('Locatie ', basisloc, ' vervangen door ', x_koppel, ' , ', y_koppel_min)
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'XCoordinate'] = x_koppel
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'YCoordinate'] = y_koppel_min
                
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Xp'] == x_koppel]
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Yp'] == y_koppel]
            # if x_koppel in SWANpoints_selection['Xp'].to_list():
            #     print('Locatie ', basisloc, ' vervangen door ', x_koppel, ' , ', y_koppel)
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'XCoordinate'] = x_koppel
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'YCoordinate'] = y_koppel
                
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Xp'] == x_koppel]
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Yp'] == y_koppel_plus]
            # if x_koppel in SWANpoints_selection['Xp'].to_list():
            #     print('Locatie ', basisloc, ' vervangen door ', x_koppel, ' , ', y_koppel_plus)
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'XCoordinate'] = x_koppel
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'YCoordinate'] = y_koppel_plus
                
            
            # #x_koppel_plus matchen met y_koppel_min/y_koppel/y_koppel_plus
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Xp'] == x_koppel_plus]
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Yp'] == y_koppel_min]
            # if x_koppel_plus in SWANpoints_selection['Xp'].to_list():
            #     print('Locatie ', basisloc, ' vervangen door ', x_koppel_plus, ' , ', y_koppel_min)
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'XCoordinate'] = x_koppel_plus
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'YCoordinate'] = y_koppel_min
                
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Xp'] == x_koppel_plus]
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Yp'] == y_koppel]
            # if x_koppel_plus in SWANpoints_selection['Xp'].to_list():
            #     print('Locatie ', basisloc, ' vervangen door ', x_koppel_plus, ' , ', y_koppel)
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'XCoordinate'] = x_koppel_plus
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'YCoordinate'] = y_koppel
                
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Xp'] == x_koppel_plus]
            # SWANpoints_selection = swan_resultaat.loc[swan_resultaat['Yp'] == y_koppel_plus]
            # if x_koppel_plus in SWANpoints_selection['Xp'].to_list():
            #     print('Locatie ', basisloc, ' vervangen door ', x_koppel_plus, ' , ', y_koppel_plus)
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'XCoordinate'] = x_koppel_plus
            #     df_dhydro_swan.loc[df_dhydro_swan['BaseLineName'] == basisloc, 'YCoordinate'] = y_koppel_plus
                
    return df_dhydro_swan
    
def opslaan_golven_info(df_dhydro_swan, ws, dir_general_modeldata, versie):
    print('Opslaan DHYDRO-SWAN koppeltabel')
    df_dhydro_swan.to_csv(os.path.join(dir_general_modeldata, '{}_DHYDRO_SWAN_koppeling_{}.csv'.format(ws, versie)), index=False)
    
#watersysteem
ws = 'vrm' # in kleine letters: 'grev', 'vrm', 'vzm', 'mm'
versie = 'v1'
dir_generalmodeldata = os.path.join(workdir,
                                     f'database_figuren_meren/input_generalmodeldata/{ws.upper()}')

#paden naar watersysteem-specifieke bestanden
if ws == 'grev':
    swan_points_file = 'swan-grevelingen-hr2023_6-v1a_4_boi_obs.xyn.csv'
    swan_check_file = os.path.join(workdir,
                                   'swan-grev-hr2023/grevU10D023Mm030Va/results/grevU10D023Mm030Va_p4_boi.tab')
    koptabfile = os.path.join(dir_generalmodeldata,
                               'grev_koppeltabel_v2022_06_10.csv')
elif ws == 'vrm':
    swan_points_file = 'swan-vrm-hr2023_6-v1a_4_boi_obs.xyn.csv'
    swan_check_file = os.path.join(workdir,
                                   'swan-vrm_hr2023/vrmU10D023Mm025Vb/results/vrmU10D023Mm025Vb_p4_boi.tab')
    koptabfile = os.path.join(dir_generalmodeldata,
                               'VRM_koppeltabel_v2026_04_20.csv')   
elif ws == 'vzm':
    swan_points_file = 'swan-vzm-hr2023_6-v1a_4_boi_obs.xyn.csv'
    swan_check_file = os.path.join(workdir,
                                   'swan-vzm-hr2023/vzmU10D023Mp000Va/results/vzmU10D023Mp000Va_p4_boi.tab')
    koptabfile = os.path.join(dir_generalmodeldata,
                               'VZM_koppeltabel_v2022_06_10.csv')
elif ws == 'mm':
    swan_points_file = 'swan-markermeer-hr2023_6-v1a_4_boi_obs.xyn.csv'
    swan_check_file = os.path.join(workdir,
                                   'swan-mm_hr2023/mmU10D023Mm025Va/results/mmU10D023Mm025Va_p4_boi.tab')
    koptabfile = os.path.join(dir_generalmodeldata,
                               'MM_koppeltabel_v2022_06_10.csv')


df_dhydro_swan = info_golven(koptabfile, swan_points_file, swan_check_file)
opslaan_golven_info(df_dhydro_swan, ws, dir_generalmodeldata, versie)



















