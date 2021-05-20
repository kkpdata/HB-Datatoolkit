# -*- coding: utf-8 -*-
"""
Created on Wed Oct 30 13:44:54 2019

@author: hove
"""

import sqlite3
import os
import shutil
import pandas as pd
import numpy as np

from Bouw_db_funcs import delete_all, determine_uncertainty_df_v3

#%% 

BasisDBdir = 'BasisDB'
GevuldeDBdir = 'GevuldeDB'
if not os.path.exists(GevuldeDBdir):
    os.makedirs(GevuldeDBdir)

# folder waar watestand resultaten staan
trajectfolder = os.path.join('..', r'GIS_kaart\Normtrajectdata')
# shape van polygonen met sigma voor modelonzekerheid
onz_shp = os.path.join('..','GISgegevens','Modelonzekerheden_v5.shp')
    
#%%
    
trajecten = {'52-2': '05_ijsseldelta',
             '52a-1': '05_ijsseldelta',
             '52-4': '05_ijsseldelta',
             '52-3': '05_ijsseldelta',
             '53-2': '05_ijsseldelta',
             '11-2': '05_ijsseldelta',
             '11-1': '05_ijsseldelta',
             '227' : '05_ijsseldelta',
             '206' : '05_ijsseldelta',
             '8-4' : '05_ijsseldelta',
             '10-3': '05_ijsseldelta',
             '225' : '05_ijsseldelta',
             '10-1': '05_vechtdelta',
             '10-2': '05_vechtdelta',
             '53-3': '06_vechtdelta',
             '9-1' : '06_vechtdelta',
             '9-2' : '06_vechtdelta',
             '7-1' : '06_vechtdelta',
             '202' : '06_vechtdelta',
             'Ijsselas' : '05_ijsseldelta',
             'Vechtas' : '06_vechtdelta'}

QIJssel2QVecht = {100 : 10,
                  500 : 100,
                  950 : 250,
                  1400: 400,
                  1850: 550,
                  2300: 700,
                  2750: 850,
                  2975: 925,
                  3200: 1000,
                  3400: 1067,
                  3600: 1133,
                  3800: 1200,
                  4000: 1267}

# versie komt in naam van sqlite te staan
versie = 1

#%%

def watersysteem(traject):
    """
    Watersysteem nummer en naam
    """
    watersysteem = trajecten[traject]
    wssysteem = watersysteem.split('_')[1]
    wsnummer = watersysteem.split('_')[0]
    
    return watersysteem, wssysteem, wsnummer

#%%

def laden_resultaten(resultfolder, traject):
    """
    Laden van resultaten waterstand en bodemhoogtes
    """
     
    Results = pd.read_csv(os.path.join(trajectfolder, "{}\Waterlevels_Database_Filtered_{}.csv".format(traject, traject)))
    Locations = pd.read_excel(os.path.join(trajectfolder, "{}\Database_{}.xlsx".format(traject, traject)))
    
    if any(Results.columns[5:].tolist() != Locations.Name):
        print('Locaties in resultaten niet gelijk aan locaties in koppelings database. Los dit eerst op')
        
    print('Traject {} bevat {} locaties'.format(traject, len(Locations)))
    
    # Dict voor namen in hydra en namen in waqua
    Hydra2Waqua = dict(zip(Locations.Hydranaam, Locations.Name))
    
    return Results, Locations, Hydra2Waqua

#%%

def maak_database(wssysteem, traject, versie):
    """
    Maak database door basis te kopieren
    """

    # maak databases aan
    srcdb = os.path.join(BasisDBdir,'DEMO_{}_BedLevel.sqlite'.format(wssysteem))
    dstdb = os.path.join(GevuldeDBdir,'RD2018_N8892_zRB_wda_un_{}_V{:02d}_check.sqlite'.format(traject,versie))
    if os.path.exists(dstdb):
        os.remove(dstdb)
    shutil.copy2(srcdb,dstdb)
    print('dstdb = {}'.format(dstdb))
    
    return dstdb

#%%

def schrijf_locaties(Locations, dstdb):
    """
    HRD locaties wegschrijven in database
    """
    print("HRD locaties wegschrijven in database")
    
    HRDLocations = []
    for ix, row in Locations.iterrows():
        HRDLocations.append([row.HRDLocationID, 2, row.Hydranaam, row.x, row.y, 0, row.bedlevel])
    HRDLocations = pd.DataFrame(HRDLocations,columns=['HRDLocationId','LocationTypeId','Name','XCoordinate','YCoordinate','WaterLevelCorrection', 'BedLevel'])
    
    # schrijf de locatie gegevens naar sql
    conn = sqlite3.connect(dstdb)
    table = 'HRDLocations'
    delete_all(table, conn)
    HRDLocations.to_sql(table,conn, if_exists='append',index=False)
    conn.close()
    
    del ix, row 
    
    return HRDLocations

#%%

def lees_windrichtingen(dstdb):
    """
    Lees windrichtingen uit de sqlite database
    """
    print("Lees windrichtingen uit sqlite database")
    
    # ophalen van winddirections uit sql
    query= "SELECT * FROM HRDWindDirections"        
    conn = sqlite3.connect(dstdb)
    WindDirection = pd.read_sql(query,conn)
    conn.close()
    
    HRDWindDirectionIds = WindDirection['HRDWindDirectionId'].tolist()
    
    return WindDirection, HRDWindDirectionIds

#%%
    
def schrijf_hydrodynamica(Results, Locations, HRDLocations, WindDirection, Hydra2Waqua):
    """
    HydroDynamicData in database zetten
    """
    print("Hydrodynamic data in database zetten")
    
    HDDcolumns = ['HydroDynamicDataId','HRDLocationId','ClosingSituationId','HRDWindDirectionId']
    HydroDynamicData = pd.DataFrame(columns= HDDcolumns)
    
    HDIDcolumns = ['HydroDynamicDataId','HRDInputColumnId','Value']
    HydroDynamicInputData =  pd.DataFrame(columns= HDIDcolumns)
    
    HDRDcolumns = ['HydroDynamicDataId','HRDResultColumnId','Value']
    HydroDynamicResultData = pd.DataFrame(columns= HDRDcolumns)
    
    # klaarzetten van de basisgegevens voor de windrichting
    # zorg dat D matched met de waardes die in de sql database zitten
    Results['ID_WS'] = 1
    for d in np.unique(Results['D']):        
        if d in [22, 67, 112, 157, 202, 247, 292, 337]:
            dnew = d+0.5
        else:
            dnew = d
        Results.loc[Results['D']==d,'Dnew'] = dnew
    
    # merge winddirection
    Results = pd.merge(Results, WindDirection, left_on='Dnew', right_on='Direction')
    Results.drop('Dnew', axis=1, inplace=True)
    
    # sorteer alle Results dataframes op dezelfde manier zodat de IDs goed komen te staan
    Results.sort_values(['K', 'Q','U','D','M'], ascending=[True, True,True,True,True], inplace=True)
    Results.reset_index(drop=True, inplace=True)
    
    HDRDidstart = 1
    
    ii = 0
    for LocId in Locations['HRDLocationID'].tolist():
        if ii % 5 == 0:
            print('{traject} locatie {i} van {N}'.format(traject=traject, i=ii, N=len(Locations)))
        ii += 1
        
        Hydranaam = HRDLocations.loc[HRDLocations['HRDLocationId']==LocId, 'Name'].values[0]
        Waquanaam = Hydra2Waqua[Hydranaam]
        #opnieuw zetten HydrodynamicResultdata:
        HRDids = np.arange(HDRDidstart,HDRDidstart+len(Results))
        Results['HydrodynamicdataId'] = HRDids
        
        HDRDidstart = HDRDidstart+len(Results)
        
        tmp = Results[['HydrodynamicdataId','ID_WS',Waquanaam]]
        # rond waterstanden af op 2 decimalen
        tmp = tmp.round({Waquanaam: 2}) 
        tmp.columns = HDRDcolumns
        HydroDynamicResultData = pd.concat([HydroDynamicResultData, tmp])
            
        if wssysteem == 'ijsseldelta':
            tmp = Results[['HydrodynamicdataId','Q']]
            # insert kolom at position 1 with name 'ID_Q' and values 2
            tmp.insert(1, 'ID_Q', 2, True)
            tmp.columns = HDIDcolumns
            HydroDynamicInputData = pd.concat([HydroDynamicInputData,tmp])
            
            tmp = Results[['HydrodynamicdataId','U']]
            tmp.insert(1, 'ID_U', 3, True)
            tmp.columns = HDIDcolumns
            HydroDynamicInputData = pd.concat([HydroDynamicInputData,tmp])
            
            tmp = Results[['HydrodynamicdataId','M']]
            tmp.insert(1, 'ID_M', 4, True)
            tmp.columns = HDIDcolumns
            HydroDynamicInputData = pd.concat([HydroDynamicInputData,tmp])
            
        elif wssysteem == 'vechtdelta':
            tmp = Results[['HydrodynamicdataId','Q']]
            tmp['ID_Q'] = 1
            tmp = tmp[['HydrodynamicdataId','ID_Q','Q']]
            for q in np.unique(tmp['Q']): 
                qnew = QIJssel2QVecht[q]
                tmp.loc[tmp['Q']==q,'Q'] = qnew
            tmp.columns = HDIDcolumns
            HydroDynamicInputData = pd.concat([HydroDynamicInputData,tmp])
            
            tmp = Results[['HydrodynamicdataId','U']]
            tmp.insert(1, 'ID_U', 3, True)
            tmp.columns = HDIDcolumns
            HydroDynamicInputData = pd.concat([HydroDynamicInputData,tmp])
            
            tmp = Results[['HydrodynamicdataId','M']]
            tmp.insert(1, 'ID_M', 4, True)
            tmp.columns = HDIDcolumns
            HydroDynamicInputData = pd.concat([HydroDynamicInputData,tmp])
            
        # HydroDynamicData
        tmp = Results[['HydrodynamicdataId', 'K', 'HRDWindDirectionId']]
        tmp.insert(1, 'LocId', LocId, True)
        tmp.columns = HDDcolumns
        HydroDynamicData = pd.concat([HydroDynamicData,tmp])
    
    # Wegschrijven naar sql
    conn = sqlite3.connect(dstdb)
    
    # HydroDynamicData
    HydroDynamicData.drop_duplicates(inplace=True)
    table = 'HydroDynamicData'
    delete_all(table, conn)
    HydroDynamicData.to_sql(table, conn, if_exists='append', index=False)
    print('HydroDynamicData toegevoegd')
    del HydroDynamicData
    
    # HydroDynamicInputData
    HydroDynamicInputData.drop_duplicates(inplace=True)
    table = 'HydroDynamicInputData'
    delete_all(table, conn)
    HydroDynamicInputData.to_sql(table, conn, if_exists='append', index=False)
    print('HydroDynamicInputData toegevoegd')
    del HydroDynamicInputData
    
    # HydroDynamicResultData
    HydroDynamicResultData = pd.DataFrame(HydroDynamicResultData, columns=HDRDcolumns)
    HydroDynamicResultData.drop_duplicates(inplace=True)
    table = 'HydroDynamicResultData'
    delete_all(table, conn)
    HydroDynamicResultData.to_sql(table, conn, if_exists='append', index=False)
    print('HydroDynamicResultData toegevoegd')
    del HydroDynamicResultData
    del Results
    
    conn.close()

#%%
    
def schrijf_modelonzekerheid(HRDLocations, dstdb, onz_shp):
    """
    Onzekerheidsmodel factor toevoegen in sql 
    """ 
    print("Modelonzekerheid in database zetten")
    
    bretschneiderlocs = HRDLocations.Name.tolist()
        
    conn = sqlite3.connect(dstdb)
    table = 'UncertaintyModelFactor'
    UncertaintyModelFactor = determine_uncertainty_df_v3(onz_shp, HRDLocations, conn, watersysteem, bretschneiderlocs)
    delete_all(table, conn)
    UncertaintyModelFactor.to_sql(table, conn, if_exists='append', index=False)
    conn.close()
    print("Onzekerheidsmodel factor toegevoegd")

#%%

def schrijf_sluitscenarios(HRDWindDirectionIds, dstdb):
    """
    Closing scenarios toevoegen in sql 
    """
    print("Sluitscenario's in database zetten")

    ClosingScenarioId = 1
    Kans_Failing_Closing = 0.01 # deze waarde varieren tussen 0 en 1 om de faalkansen van de kering te beïnvloeden. (WBI2017 = 0.01)
    ClosingSituationIds = [1, 2]
    ClosingScenarios = []
    for WindDirectionId in HRDWindDirectionIds:
        for ClosingSituationId in ClosingSituationIds:
            if ClosingSituationId == 1:
                ClosingScenarios.append([ClosingScenarioId,ClosingSituationId,WindDirectionId,np.nan,np.nan,'Failed Closing',Kans_Failing_Closing,np.nan,np.nan,ClosingSituationId])
            elif ClosingSituationId == 2:
                ClosingScenarios.append([ClosingScenarioId,ClosingSituationId,WindDirectionId,np.nan,np.nan,'Correctly Closed',1-Kans_Failing_Closing,np.nan,np.nan,ClosingSituationId])
            ClosingScenarioId +=1
    ClosingScenarios = pd.DataFrame(ClosingScenarios,columns= ['ClosingScenarioId','ClosingSituationId','WindDirectionId',
                                                               'ClosingCriterionId','ClosingCriterion_2Id','Description',
                                                               'ScenarioProbability','ReversedCriterium','ReversedCriterium_2','RuleId'])
    table = 'ClosingScenarios'
    conn = sqlite3.connect(dstdb)
    delete_all(table, conn)
    ClosingScenarios.to_sql(table,conn, if_exists='append',index=False) 
    print("Closing scenarios toegevoegd")
    
    # vacuum en commit
    conn.isolation_level = None
    conn.execute('VACUUM')
    conn.isolation_level = '' # <- note that this is the default value of isolation_level
    conn.commit()
    conn.close()

#%%

"""
Run alle functies om sqlite database te maken
"""
    
traject = '10-1'
print("start traject {}".format(traject))
watersysteem, wssysteem, wsnummer = watersysteem(traject)

# Laden van resultaten 
Results, Locations, Hydra2Waqua = laden_resultaten(trajectfolder, traject)

# Schrijf alle data weg naar een sqlite
dstdb = maak_database(wssysteem, traject, versie)
HRDLocations = schrijf_locaties(Locations, dstdb)
WindDirection, HRDWindDirectionIds = lees_windrichtingen(dstdb)
schrijf_hydrodynamica(Results, Locations, HRDLocations, WindDirection, Hydra2Waqua)
schrijf_modelonzekerheid(HRDLocations, dstdb, onz_shp)
schrijf_sluitscenarios(HRDWindDirectionIds, dstdb)

print('klaar met traject {}'.format(traject))