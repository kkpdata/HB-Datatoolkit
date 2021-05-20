# -*- coding: utf-8 -*-
"""
Created on Tue Sep  5 09:00:56 2017

@author: daggenvoorde
"""

import sqlite3
import os
import shutil
import pandas as pd
import re
import numpy as np
import getpass

user = getpass.getuser()
if user == 'daggenvoorde':
    BasisDBdir = os.path.join('..','BasisDB')
    GevuldeDBdir = os.path.join('..','GevuldeDB')
    datafolder = os.path.join('..','..','tables_csv_complete')
    Locatiexlsx = os.path.join('..','..','Consistency_Checks','hulpbestanden','locaties.xlsx')
    Tussenresultatendir = 'Tussenresultaten'
elif user.startswith('mp'):
    BasisDBdir = r'/data/computations/python/MaakDb/BasisDB'
    GevuldeDBdir = r'/data/computations/python/MaakDb/GevuldeDB'
    datafolder = r'/data/computations/hr2017_wda/output/tables_csv_complete_n8892'
    Locatiexlsx =r'/data/computations/python/consistency_checks/hulpbestanden/locaties.xlsx'
    Tussenresultatendir = r'/data/computations/python/MaakDb/Tussenresultaten'

# geef aan welke db's je wil vervangen
replaceDB_05_ijsseldelta = False
replaceDB_06_vechtdelta = True
replaceDB_07_ijsselmeer = False
watersystemen = ['06_vechtdelta','07_ijsselmeer','05_ijsseldelta']

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

for watersysteem in watersystemen:
    print('watersysteem {}'.format(watersysteem))
    wssysteem = watersysteem.split('_')[1]
    wsnummer = watersysteem.split('_')[0]
    srcdb = os.path.join(BasisDBdir,'DEMO_{}.sqlite'.format(wssysteem))
    dstdb = os.path.join(GevuldeDBdir,'VIJD_SSC_{}_V01.sqlite'.format(watersysteem))
    if ( eval('replaceDB_{}'.format(watersysteem))  & (os.path.exists(dstdb))):
        #os.remove(dstdb)
        if user == 'daggenvoorde':
            shutil.copy2(srcdb,dstdb)
        elif user.startswith('mp'): #shutil had niet voldoende rechten op het modellenplatform dus andere kopieermethode
            print("os.system('cp {} {}'.format(srcdb,dstdb))")
    elif eval('replaceDB_{}'.format(watersysteem)): #DB bestaat nog niet ga hem maken
        if user == 'daggenvoorde':
            shutil.copy2(srcdb,dstdb)
        elif user.startswith('mp'):
            os.system('cp {} {}'.format(srcdb,dstdb))
    else: #DB niet vervangen dus ga naar volgende watersysteem...
        continue
        
    print('dstdb = {}'.format(dstdb))
#    print('conn = {}'.format(conn))
    

    locaties = pd.read_excel(Locatiexlsx)

    locaties = locaties[['idx','waquanaam','hydranaam','Watersysteem']]
    #selecteer de locaties in dit watersysteem:
    locaties = locaties.loc[locaties['Watersysteem']==watersysteem]
    print('watersysteem {} bevat {} locaties'.format(watersysteem,len(locaties)))
    
    locs_waq = locaties['waquanaam'].tolist()
    locs_hyd = locaties['hydranaam'].tolist()
    
    header = ['K','Q','U','D','M'] + locs_hyd
    simnames = os.listdir(datafolder)
    
    if os.path.exists(os.path.join(Tussenresultatendir,'Results_{}_zonder_kopieren.csv'.format(watersysteem))): #shortcut om uitlezen csv's over te slaan
        Results = pd.read_csv(os.path.join(Tussenresultatendir,'Results_{}_zonder_kopieren.csv'.format(watersysteem)),sep=';',index_col=0)
        sim = 'statdata_KsrMp150Q3800U47D360.csv' #om locatie x en y te bepalen
        print('data ingeladen')
    else:
        results = []
        print('start inladen data')
        N = len(simnames)
        for idx, sim in enumerate(simnames):
            if idx % 500 == 0:
                print('{}/{}'.format(idx,N))
            [(K, M, Q, U, D)] = re.findall('K(.+)M(.+)Q(.+)U(.+)D(.+).csv', sim)
            M = M.replace('p0','0.').replace('p1','1.').replace('n0','-0.')
            if K == 'ao':
                K = 1
            elif K == 'sr':
                K = 2
            else:
                raise ValueError('Sluitscenario : {} is onbekend'.format(K))
            data = pd.read_csv(os.path.join(datafolder,sim),sep=';',index_col=0,usecols=['Name','max13', 'last25','maximum','NANMAX'])
            data = data.loc[locs_waq]
            
            #selecteer de juiste waardes uit de csv's max13, last25 of maximum
            if ((float(Q) <= 2300) & (float(U) == 0)): #als er constante afvoer is en geen wind pak de last25-waarde
                if any(pd.isnull(data['last25'])):
                    raise ValueError('De "last25" van deze simulatie {} bevat een NaN-waarde'.format(sim))
                results.append([K, float(Q), float(U), float(D), float(M)] + data['last25'].tolist())
            else:   #afvoergolf of wind aanwezig? dan werken met max13
                datatmp = []
                for idx, row in data.iterrows():
                    if ((row['NANMAX'] == 5) & (float(U) !=0 ) & (row.name.split('_')[0] in ['YM','KM','ZM'])): # nanmax=5 = afwaaiing, geen max13, neem maximum, geldt alleen op meren (IJsselmeer [YM], Ketelmeer [KM] of Zwartemeer [ZM]) en wanneer er wind is
                        datatmp.append(row['maximum'])
                    elif pd.isnull(row['max13']): #als geen afwaaiing en toch nan de nan-waardes in de reeksen voor het maximum neem maximum onderscheidt met bovenstaande wordt gemaakt voor de figuren.
                         datatmp.append(row['maximum'])
                    else:
                        datatmp.append(row['max13'])
                    if any(pd.isnull(datatmp)):
                        raise ValueError('NaN-waarde')
                results.append([K, float(Q), float(U), float(D), float(M)] + datatmp)
        Results = pd.DataFrame(results, columns = header)
        print('data ingeladen')
        Results.to_csv(os.path.join(Tussenresultatendir,'Results_{}_zonder_kopieren.csv'.format(watersysteem)),sep=';')
        
    #get locatie X en Y op basis van laatste simulatie
    data = pd.read_csv(os.path.join(datafolder,sim),sep=';',index_col=0,usecols=['Name','x', 'y'])
    locaties = locaties.merge(data,left_on='waquanaam',right_index=True)
    locaties.set_index('waquanaam',drop=True,inplace=True)
    
    #%% HRDLocations
    HRDLocations = []
    #nog kijken naar locationtypeID
    for i, row in locaties.iterrows():
        HRDLocations.append([row['idx'], 2, row['hydranaam'],row['x'],row['y'],0])
    
    HRDLocations = pd.DataFrame(HRDLocations,columns=['HRDLocationId','LocationTypeId','Name','XCoordinate','YCoordinate','WaterLevelCorrection'])
    conn = sqlite3.connect(dstdb)
    HRDLocations.to_sql('HRDLocations',conn, if_exists='replace',index=False)
    print('HRDLocations toegevoegd')
    
    #%% Doorkopiëren in windrichtingen voor U = 0
    
    query= "SELECT * FROM HRDWindDirections"
    WindDirection = pd.read_sql(query,conn)
    TMP = Results.loc[Results['U']!=0]
    U0 = Results.loc[Results['U']==0]
    for D in np.unique(Results['D'].tolist()):
        if D == 360:
            tmp = U0.copy()
        else:
            tmp = U0.copy()
            tmp['D'] = float(D)
        TMP = pd.concat([TMP,tmp])
    Results = TMP.copy()
    del tmp, TMP

    #%% doorkopiëren van U=0 en Koa van D360 naar alle Oostelijk windrichtingen voor alle U en alle K
    print('Doorkopieren oostelijke windrichtingen')
    TMP = Results.copy()
    U0koaD360 = Results.loc[(Results['U']==0) & (Results['K']==1) & (Results['D']==360)].copy()
    for D in [22, 45, 67, 90, 112, 135, 157, 180, 202]:
        for U in np.unique(Results['U']):
            for K in np.unique(Results['K']):
                tmp = U0koaD360.copy()
                tmp['D'] = float(D)
                tmp['U'] = float(U)
                tmp['K'] = float(K)
                TMP = pd.concat([TMP,tmp])
    Results = TMP.copy()
    del tmp, TMP
    
    if wssysteem == 'ijsselmeer':
        MQ_koppeling = [(-0.4 , 100),
                        (-0.1 , 950),
                        (0.4  , 1400),
                        (0.9  , 2750),
                        (1.3  , 3400),
                        (1.5  , 4000)]
        Results_TMP = pd.DataFrame(columns=Results.columns)
        for M, Q in MQ_koppeling:
            Results_tmp = Results.loc[((Results['Q']==Q) & (Results['M']==M) & (Results['K'] == 2))].copy()
            Results_TMP = pd.concat([Results_TMP,Results_tmp])
        Results_TMP['K'] = 1 #goedzetten van de kering 1 staat voor regular in de IJsselmeerdatabase.
        Results = Results_tmp.copy()
        del Results_tmp, MQ_koppeling
        
    #%% HydroDynamicData
    HydrodynamicdataId = 1
    ClosingSituationIds = [1, 2]
    HRDWindDirectionIds = WindDirection['HRDWindDirectionId'].tolist()
    HydroDynamicData = []
    HydroDynamicInputData = []
    HydroDynamicResultData = []
    Nlocs = len(locaties)
    Nresu = len(Results)
    ii=0
    for LocId in locaties['idx'].tolist():
        i = 0
        ii+=1
        for n, row in Results.iterrows():
            if i % 5000 == 0:
                print('Locatie {a}/{b} - Voortgang {c}/{d}'.format(a=ii,b=Nlocs,c=i,d=Nresu))
            i+=1
            #zorg dat D matched met de waarde die ook in de database zit.
            if row['D'] in [22, 67, 112, 157, 202, 247, 292, 337]:
                D = row['D']+0.5
            else:
                D = row['D']
            HRDWindDirectionId = WindDirection.loc[WindDirection['Direction'] == D]['HRDWindDirectionId'].values[0]
            HydroDynamicData.append([HydrodynamicdataId,LocId,row['K'],HRDWindDirectionId])
            if wssysteem == 'ijsseldelta':
                HydroDynamicInputData.append([HydrodynamicdataId,2,row['Q']]) #de twee staat voor IJsselafvoer
                HydroDynamicInputData.append([HydrodynamicdataId,3,row['U']])
                HydroDynamicInputData.append([HydrodynamicdataId,4,row['M']])
            elif wssysteem == 'vechtdelta':
                HydroDynamicInputData.append([HydrodynamicdataId,1,QIJssel2QVecht[row['Q']]]) #de één staat voor vechtafvoer
                HydroDynamicInputData.append([HydrodynamicdataId,3,row['U']])
                HydroDynamicInputData.append([HydrodynamicdataId,4,row['M']])
            elif wssysteem == 'ijsselmeer':
                HydroDynamicInputData.append([HydrodynamicdataId,1,row['U']])
                HydroDynamicInputData.append([HydrodynamicdataId,3,row['M']])
            naam =HRDLocations.loc[HRDLocations['HRDLocationId']==LocId, 'Name'].values[0]
            HydroDynamicResultData.append([HydrodynamicdataId,1,float(row[naam])])
            HydrodynamicdataId += 1
    HydroDynamicData = pd.DataFrame(HydroDynamicData,columns=['HydroDynamicDataId','HRDLocationId','ClosingSituationId','HRDWindDirectionId'])
    HydroDynamicData.to_sql('HydroDynamicData',conn, if_exists='replace',index=False)
#    hrd.add_to_table('HydroDynamicData', HydroDynamicData.round(3), conn)
    print('HydroDynamicData toegevoegd')
    del HydroDynamicData
    HydroDynamicInputData = pd.DataFrame(HydroDynamicInputData,columns=['HydroDynamicDataId','HRDInputColumnId','Value'])
    HydroDynamicInputData.to_sql('HydroDynamicInputData',conn, if_exists='replace',index=False)
#    hrd.add_to_table('HydroDynamicInputData', HydroDynamicInputData.round(3), conn)
    print('HydroDynamicInputData toegevoegd')
    del HydroDynamicInputData
    HydroDynamicResultData = pd.DataFrame(HydroDynamicResultData,columns = ['HydroDynamicDataId','HRDResultColumnId','Value'])
    HydroDynamicResultData.to_sql('HydroDynamicResultData',conn, if_exists='replace',index=False)
#    hrd.add_to_table('HydroDynamicResultData', HydroDynamicResultData.round(3), conn)
    print('HydroDynamicResultData toegevoegd')
    del HydroDynamicResultData
    #%% Uncertainty model factor
    
    UncertaintyModelFactor = []
    for Locid in locaties['idx'].tolist():
        for ClosingSituationId in ClosingSituationIds:
            UncertaintyModelFactor.append([Locid, ClosingSituationId, 1, 0 , 0.2])
            
    UncertaintyModelFactor = pd.DataFrame(UncertaintyModelFactor,columns=['HRDLocationId','ClosingSituationId','HRDResultColumnId','Mean','Standarddeviation'])
    UncertaintyModelFactor.to_sql('UncertaintyModelFactor',conn, if_exists='replace',index=False)  
#    hrd.add_to_table('UncertaintyModelFactor', UncertaintyModelFactor.round(3), conn)
    
    #%% ClosingScenarios
    # WAT MOET DIT ZIJN? NU KANS VAN 0.01 AANGENOMEN Doet er niet toe volgens Mattijs Duits
    if not wssysteem == 'ijsselmeer':
        ClosingScenarioId = 1
        Kans_Failing_Closing = 0.01 # deze waarde varieren tussen 0 en 1 om de faalkansen van de kering te beïnvloeden.
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
        ClosingScenarios.to_sql('ClosingScenarios',conn, if_exists='replace',index=False)      
    
    #%% vacuum and commit
    conn.isolation_level = None
    conn.execute('VACUUM')
    conn.isolation_level = '' # <- note that this is the default value of isolation_level
    conn.commit()
    conn.close()
    print('klaar met watersysteem {}'.format(watersysteem))
