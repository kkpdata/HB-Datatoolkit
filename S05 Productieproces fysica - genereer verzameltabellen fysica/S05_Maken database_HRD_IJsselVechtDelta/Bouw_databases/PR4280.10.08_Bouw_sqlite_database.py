# -*- coding: utf-8 -*-
"""
Created on Wed Oct 30 13:44:54 2019

@author: hove
"""

import sqlite3
from sys import exit
import os
import shutil
import pandas as pd
import numpy as np
from Golven_info import info_golven_SWAN_BRET

from Bouw_db_funcs import delete_all, determine_uncertainty_df_v4

#%% 

BasisDBdir = 'BasisDB'
GevuldeDBdir = 'GevuldeDB'
if not os.path.exists(GevuldeDBdir):
    os.makedirs(GevuldeDBdir)

# folder waar watestand resultaten staan
datafolder    = os.path.join('..', 'Hulpgegevens')
trajectfolder = os.path.join('..', r'GIS_kaart\Normtrajectdata')
# shape van polygonen met sigma voor modelonzekerheid waterstand
onz_shp = os.path.join('..','GISgegevens','modelonzekerheden_VIJD.shp')
    
#%%
    
trajecten = {'52-2': '05_IJsseldelta',
             '52a-1': '05_IJsseldelta',
             '52-4': '05_IJsseldelta',
             '52-3': '05_IJsseldelta',
             '53-2': '05_IJsseldelta',
             '11-2': '05_IJsseldelta',
             '11-1': '05_IJsseldelta',
             '227' : '05_IJsseldelta',
             '206' : '05_IJsseldelta',
             '8-4' : '05_IJsseldelta',
             '10-3': '05_IJsseldelta',
             '225' : '05_IJsseldelta',
             '10-1': '06_Vechtdelta',
             '10-2': '06_Vechtdelta',
             '53-3': '06_Vechtdelta',
             '9-1' : '06_Vechtdelta',
             '9-2' : '06_Vechtdelta',
             '7-1' : '06_Vechtdelta',
             '202' : '06_Vechtdelta',
             'IJsselas' : '05_IJsseldelta',
             'Vechtas' : '06_Vechtdelta'}

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
versie = 0

#%%

def watersysteem_traject(traject):
    """
    Watersysteem nummer en naam
    """
    watersysteem = trajecten[traject]
    wssysteem = watersysteem.split('_')[1]
    wsnummer = watersysteem.split('_')[0]
    
    return watersysteem, wssysteem, wsnummer

#%%

def laden_resultaten(resultfolder, traject, locaties_traject):
    """
    Laden van resultaten waterstand en golven
    """
     
    Results_H   = pd.read_csv(os.path.join(trajectfolder, "{}\Waterlevels_Database_Filtered_{}.csv".format(traject, traject)))
    if any(Results_H.columns[5:].tolist() != locaties_traject.index):
        exit('Locaties in resultaten waterstanden niet gelijk aan locaties in koppelingsdatabase. Los dit eerst op')

    if traject in ['9-1', '10-1', '52a-1', '52-3', '52-4', '53-2', '53-3', '206']:
        golvenmodel = 'Bret'
    elif traject in ['7-1', '8-4', '11-2', '202', '225', '227']:
        golvenmodel = 'SWAN'
    elif traject in ['9-2', '10-2', '10-3', '11-1']:
        golvenmodel = 'Comb'

    Results_Hs  = pd.read_csv(os.path.join(trajectfolder, "{}\Golfparameter_{}_Hs_{}.csv".format(traject, golvenmodel, traject)))
    if any(Results_Hs.columns[5:].tolist() != locaties_traject.index):
        exit('Locaties in resultaten golfhoogte niet gelijk aan locaties in koppelingsdatabase. Los dit eerst op')
        
    Results_Tp  = pd.read_csv(os.path.join(trajectfolder, "{}\Golfparameter_{}_Tp_{}.csv".format(traject, golvenmodel, traject)))
    if any(Results_Tp.columns[5:].tolist() != locaties_traject.index):
        exit('Locaties in resultaten piekperiode niet gelijk aan locaties in koppelingsdatabase. Los dit eerst op')
        
    Results_Tm  = pd.read_csv(os.path.join(trajectfolder, "{}\Golfparameter_{}_Tm_{}.csv".format(traject, golvenmodel, traject)))
    if any(Results_Tm.columns[5:].tolist() != locaties_traject.index):
        exit('Locaties in resultaten spectrale golfperiode niet gelijk aan locaties in koppelingsdatabase. Los dit eerst op')
        
    Results_dir = pd.read_csv(os.path.join(trajectfolder, "{}\Golfparameter_{}_dir_{}.csv".format(traject, golvenmodel, traject)))
    if any(Results_dir.columns[5:].tolist() != locaties_traject.index):
        exit('Locaties in resultaten golfrichtingen niet gelijk aan locaties in koppelingsdatabase. Los dit eerst op')
        
    print('Traject {} bevat {} locaties'.format(traject, len(locaties_traject)))
    
    return Results_H, Results_Hs, Results_Tp, Results_Tm, Results_dir

#%%

def maak_database(wssysteem, traject, versie):
    """
    Maak database door basis te kopieren
    """

    # maak databases aan
    srcdb = os.path.join(BasisDBdir,'DEMO_{}_BedLevel.sqlite'.format(wssysteem))
    dstdb = os.path.join(GevuldeDBdir,'WBI2023_{}_{}_v{:02d}_terBeoordeling.sqlite'.format(wssysteem,traject,versie))
    if os.path.exists(dstdb):
        os.remove(dstdb)
    shutil.copy2(srcdb,dstdb)
    print('dstdb = {}'.format(dstdb))
    
    return dstdb

#%%

def schrijf_locaties(locaties_traject, dstdb):
    """
    HRD locaties wegschrijven in database
    """
    print("HRD locaties wegschrijven in database")
    
    HRDLocations = []
    for ix, row in locaties_traject.iterrows():
        HRDLocations.append([row.LocationID, 2, row.Hydranaam, round(row.x,3), round(row.y,3), 0, row.bedlevel])
    HRDLocations = pd.DataFrame(HRDLocations,columns=['HRDLocationId','LocationTypeId','Name','XCoordinate','YCoordinate','WaterLevelCorrection', 'BedLevel'])
    
    # schrijf de locatie gegevens naar sql
    conn = sqlite3.connect(dstdb)
    table = 'HRDLocations'
    delete_all(table, conn)
    HRDLocations.to_sql(table,conn, if_exists='append',index=False)
    conn.close()
    
    return HRDLocations

#%%

def lees_windrichtingen(dstdb):
    """
    Lees windrichtingen uit de sqlite database
    """
    print("Lees windrichtingen uit sqlite database")
    
    # ophalen van winddirections uit sqlite
    query= "SELECT * FROM HRDWindDirections"        
    conn = sqlite3.connect(dstdb)
    WindDirection = pd.read_sql(query,conn)
    conn.close()
    
    HRDWindDirectionIds = WindDirection['HRDWindDirectionId'].tolist()
    
    return WindDirection, HRDWindDirectionIds

#%%

def windrichting_bijstellen(Results):
    # klaarzetten van de basisgegevens voor de windrichting
    # zorg dat D matched met de waardes die in de sqlite-database zitten
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
    Results.sort_values(['K','Q','U','D','M'], ascending=[True,True,True,True,True], inplace=True)
    Results.reset_index(drop=True, inplace=True)
    
    return Results

#%%
    
def schrijf_hydrodynamica(locaties_traject, Results_H, Results_Hs, Results_Tp, Results_Tm, Results_dir, HRDLocations, WindDirection):
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
    # zorg dat D matched met de waardes die in de sqlite-database zitten
    Results_H = windrichting_bijstellen(Results_H)
    Results_H['ID_Res'] = 1

    Results_Hs = windrichting_bijstellen(Results_Hs)
    Results_Hs['ID_Res'] = 2
    
    Results_Tp = windrichting_bijstellen(Results_Tp)
    Results_Tp['ID_Res'] = 3
    
    Results_Tm = windrichting_bijstellen(Results_Tm)
    Results_Tm['ID_Res'] = 4
    
    Results_dir = windrichting_bijstellen(Results_dir)
    Results_dir['ID_Res'] = 5

    # sorteer alle Results dataframes op dezelfde manier zodat de IDs goed komen te staan
    Results_H.sort_values(['K','Q','U','D','M'], ascending=[True,True,True,True,True], inplace=True)
    Results_H.reset_index(drop=True, inplace=True)

    Results_Hs.sort_values(['K','Q','U','D','M'], ascending=[True,True,True,True,True], inplace=True)
    Results_Hs.reset_index(drop=True, inplace=True)

    Results_Tp.sort_values(['K','Q','U','D','M'], ascending=[True,True,True,True,True], inplace=True)
    Results_Tp.reset_index(drop=True, inplace=True)

    Results_Tm.sort_values(['K','Q','U','D','M'], ascending=[True,True,True,True,True], inplace=True)
    Results_Tm.reset_index(drop=True, inplace=True)

    Results_dir.sort_values(['K','Q','U','D','M'], ascending=[True,True,True,True,True], inplace=True)
    Results_dir.reset_index(drop=True, inplace=True)
    
    HDRDidstart = 1
    
    ii = 0
    for LocId in locaties_traject['LocationID'].tolist():
        if ii % 5 == 0:
            print('{traject} locatie {i} van {N}'.format(traject=traject, i=ii, N=len(locaties_traject)))
        ii += 1
        
        Hydranaam = HRDLocations.loc[HRDLocations['HRDLocationId']==LocId, 'Name'].values[0]
        Waquanaam = locaties_traject.index[locaties_traject['Hydranaam']==Hydranaam].values[0]
        HDRDidstart = HDRDidstart+len(Results_H)


        #opnieuw zetten HydrodynamicResultdata:
        HRDids = np.arange(HDRDidstart,HDRDidstart+len(Results_H))
        Results_H['HydrodynamicdataId'] = HRDids
        
        HDRDidstart = HDRDidstart+len(Results_H)
        tmp = Results_H[['HydrodynamicdataId','ID_Res', Waquanaam]]
        tmp.columns = HDRDcolumns
        HydroDynamicResultData = pd.concat([HydroDynamicResultData, tmp])

        Results_Hs['HydrodynamicdataId'] = HRDids
        tmp = Results_Hs[['HydrodynamicdataId','ID_Res', Waquanaam]]
        tmp.columns = HDRDcolumns
        HydroDynamicResultData = pd.concat([HydroDynamicResultData, tmp])
            
        Results_Tp['HydrodynamicdataId'] = HRDids
        tmp = Results_Tp[['HydrodynamicdataId','ID_Res', Waquanaam]]
        tmp.columns = HDRDcolumns
        HydroDynamicResultData = pd.concat([HydroDynamicResultData, tmp])
            
        Results_Tm['HydrodynamicdataId'] = HRDids
        tmp = Results_Tm[['HydrodynamicdataId','ID_Res', Waquanaam]]
        tmp.columns = HDRDcolumns
        HydroDynamicResultData = pd.concat([HydroDynamicResultData, tmp])
            
        Results_dir['HydrodynamicdataId'] = HRDids
        tmp = Results_dir[['HydrodynamicdataId','ID_Res', Waquanaam]]
        tmp.columns = HDRDcolumns
        HydroDynamicResultData = pd.concat([HydroDynamicResultData, tmp])
            
        if wssysteem == 'IJsseldelta':
            tmp = Results_H[['HydrodynamicdataId','Q']]
            # insert kolom at position 1 with name 'ID_Q' and values 2
            tmp.insert(1, 'ID_Q', 2, True)
            tmp.columns = HDIDcolumns
            HydroDynamicInputData = pd.concat([HydroDynamicInputData,tmp])
            
        elif wssysteem == 'Vechtdelta':
            tmp = Results_H[['HydrodynamicdataId','Q']]
            tmp['ID_Q'] = 1
            tmp = tmp[['HydrodynamicdataId','ID_Q','Q']]
            for q in np.unique(tmp['Q']): 
                qnew = QIJssel2QVecht[q]
                tmp.loc[tmp['Q']==q,'Q'] = qnew
            tmp.columns = HDIDcolumns
            HydroDynamicInputData = pd.concat([HydroDynamicInputData,tmp])
            
        tmp = Results_H[['HydrodynamicdataId','U']]
        tmp.insert(1, 'ID_U', 3, True)
        tmp.columns = HDIDcolumns
        HydroDynamicInputData = pd.concat([HydroDynamicInputData,tmp])
        
        tmp = Results_H[['HydrodynamicdataId','M']]
        tmp.insert(1, 'ID_M', 4, True)
        tmp.columns = HDIDcolumns
        HydroDynamicInputData = pd.concat([HydroDynamicInputData,tmp])

        # HydroDynamicData
        tmp = Results_H[['HydrodynamicdataId', 'K', 'HRDWindDirectionId']]
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
    
    conn.close()

#%%
    
def schrijf_modelonzekerheid(HRDLocations, SWAN_locs, dstdb, onz_shp):
    """
    Onzekerheidsmodel factor toevoegen in sqlite 
    """ 
    conn = sqlite3.connect(dstdb)
    table = 'UncertaintyModelFactor'
    UncertaintyModelFactor = determine_uncertainty_df_v4(onz_shp, HRDLocations, conn, watersysteem, SWAN_locs)
    delete_all(table, conn)
    UncertaintyModelFactor.to_sql(table, conn, if_exists='append', index=False)
    conn.close()
    print("Modelonzekerheden toegevoegd")

#%%
    
def schrijf_correlatie_modelonzekerheid(HRDLocations, dstdb):
    """
    Correlatie voor de modelonzekerheid toevoegen in sqlite 
    """ 
    conn = sqlite3.connect(dstdb)
    ClosingSituations = pd.read_sql("SELECT * FROM ClosingSituations;", conn)

    UncertaintyCorrelationFactor = []
    for i, loc in HRDLocations.iterrows():
        
        if watersysteem == '07_IJsselmeer':
            listidx = [3, 8]
            #1 = waterstand, 2=golfhoogte 3=Tp, 8=Tm-1,0
        else: #IJVD
            #1 = waterstand, 2=golfhoogte 3=Tp, 4=Tm-1,0
            listidx = [3, 4]

        correlatie = [0, 0]
    
        for j, closure in ClosingSituations.iterrows():
            for k, idx in enumerate(listidx):
                new_row = [loc.HRDLocationId, closure.ClosingSituationId, 2, listidx[k], correlatie[k]]
                UncertaintyCorrelationFactor.append(new_row)


    UncertaintyCorrelationFactor = pd.DataFrame(UncertaintyCorrelationFactor, \
        columns=["HRDLocationId", "ClosingSituationId", "HRDResultColumnId", "HRDResultColumnId2", "Correlation"])
    
    table = 'UncertaintyCorrelationFactor'
    delete_all(table, conn)
    UncertaintyCorrelationFactor.to_sql(table, conn, if_exists='append', index=False)
    conn.close()
    print("Correlatie modelonzekerheid toegevoegd")

#%%

def schrijf_sluitscenarios(HRDWindDirectionIds, dstdb):
    """
    Closing scenarios toevoegen in sqlite 
    """
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
    print("ClosingScenarios toegevoegd")
    
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
    
# In golven_overzicht zit informatie van alle locaties in de Vecht-IJsseldelta
golven_overzicht = pd.read_csv(os.path.join(datafolder, "Golven_overzicht.csv"))
golven_overzicht.index = golven_overzicht.pop('Name')

normtrajecten = ['7-1', '8-4', '9-1', '9-2', '10-1', '10-2', '10-3', '11-1', '11-2', '52a-1', '52-3', '52-4', '53-2', '53-3', '202', '206', '225', '227']
normtrajecten = ['11-1']
    
for traject in normtrajecten:  
    locaties_traject = info_golven_SWAN_BRET(trajectfolder, traject, golven_overzicht, lim=0.1, perc_nat=0.4)

    print("start traject {}".format(traject))
    watersysteem, wssysteem, wsnummer = watersysteem_traject(traject)
    
    # Laden van resultaten 
    Results_H, Results_Hs, Results_Tp, Results_Tm, Results_dir = laden_resultaten(trajectfolder, traject, locaties_traject)
    
    # Schrijf alle data weg naar een sqlite
    dstdb = maak_database(wssysteem, traject, versie)
    HRDLocations = schrijf_locaties(locaties_traject, dstdb)
    WindDirection, HRDWindDirectionIds = lees_windrichtingen(dstdb)
    schrijf_hydrodynamica(locaties_traject, Results_H, Results_Hs, Results_Tp, Results_Tm, Results_dir, HRDLocations, WindDirection)
    schrijf_modelonzekerheid(HRDLocations, locaties_traject['Inmodel'], dstdb, onz_shp)
    schrijf_correlatie_modelonzekerheid(HRDLocations, dstdb)
    schrijf_sluitscenarios(HRDWindDirectionIds, dstdb)
    
    del Results_H
    del Results_Hs
    del Results_Tp
    del Results_Tm
    del Results_dir
    del locaties_traject
    
    print('klaar met traject {}'.format(traject))