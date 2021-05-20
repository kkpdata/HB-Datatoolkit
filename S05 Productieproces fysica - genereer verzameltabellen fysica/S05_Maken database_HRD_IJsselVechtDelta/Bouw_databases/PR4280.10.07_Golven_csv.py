# -*- coding: utf-8 -*-
"""
Created on Tue JUN 16 10:06:26 2020

@author: duits
"""

import os
from sys import exit
import pandas as pd
import numpy as np
from shutil import copyfile
from hkvpy.hrd import bretschneider
from Golven_info import info_golven_SWAN_BRET
from tqdm import tqdm
import csv

#%%

def SWAN_Golven_AltijdOpen (trajectfolder, traject, locaties_traject):
    """
    Bepaal uit de SWAN-resultaten de golfparameters voor de gewenste locaties en waterstanden
    
    locaties_traject = structure met gegevens voor de oeverlocaties. Hierin staat bijvoorbeeld of 
                       de backup locatie gebruikt moet worden voor de golven.
    """
    # Initialiseer lege lijsten met resultaten voor golfparameters
    SWAN_Hs = []
    SWAN_Tp = []
    SWAN_Tm = []
    SWAN_dir = []

    # Lees de waterstanden
    Results_H = pd.read_csv(os.path.join(trajectfolder, "{}\Waterlevels_Database_Filtered_{}.csv".format(traject, traject)))
    locaties_SWAN = locaties_traject[locaties_traject['Inmodel']==True].index.tolist()
    columns = Results_H.columns[0:5].tolist() + locaties_SWAN
    Results_H = Results_H[columns]
    
    combinaties = pd.DataFrame(
        {'K': Results_H['K'], 'Q': Results_H['Q'], 'U': Results_H['U'], 'D': Results_H['D'], 'M': Results_H['M']})

    Results_Hs  = pd.read_csv(os.path.join(trajectfolder, "{}\SWAN_ruw_Kao_Hs_{}.csv".format(traject, traject)))
    K_SWAN = Results_Hs['K'].tolist()
    U_SWAN = Results_Hs['U'].tolist()
    D_SWAN = Results_Hs['D'].tolist()
    H_SWAN = Results_Hs['H'].tolist()
    
    Results_Tp  = pd.read_csv(os.path.join(trajectfolder, "{}\SWAN_ruw_Kao_Tp_{}.csv".format(traject, traject)))
    if (Results_Tp['K'].tolist() != K_SWAN) or \
       (Results_Tp['U'].tolist() != U_SWAN) or \
       (Results_Tp['D'].tolist() != D_SWAN) or \
       (Results_Tp['H'].tolist() != H_SWAN):
           exit('Combinaties voor golfparameters niet gelijk in de vier bestanden voor golfparameters. Los dit eerst op')

    Results_Tm  = pd.read_csv(os.path.join(trajectfolder, "{}\SWAN_ruw_Kao_Tm_{}.csv".format(traject, traject)))
    if (Results_Tm['K'].tolist() != K_SWAN) or \
       (Results_Tm['U'].tolist() != U_SWAN) or \
       (Results_Tm['D'].tolist() != D_SWAN) or \
       (Results_Tm['H'].tolist() != H_SWAN):
           exit('Combinaties voor golfparameters niet gelijk in de vier bestanden voor golfparameters. Los dit eerst op')

    Results_dir = pd.read_csv(os.path.join(trajectfolder, "{}\SWAN_ruw_Kao_dir_{}.csv".format(traject, traject)))
    if (Results_dir['K'].tolist() != K_SWAN) or \
       (Results_dir['U'].tolist() != U_SWAN) or \
       (Results_dir['D'].tolist() != D_SWAN) or \
       (Results_dir['H'].tolist() != H_SWAN):
           exit('Combinaties voor golfparameters niet gelijk in de vier bestanden voor golfparameters. Los dit eerst op')

    # Bepaal het aantal unieke windrichtingen en windsnelheden in de waterstanden DataFrame
    D_wst = Results_H['D'].tolist()
    U_wst = Results_H['U'].tolist()
    
    D_unique = sorted(set(D_wst))
    U_unique = sorted(set(U_wst))

    teller = 0
    for D in D_unique:
        if D in [22, 67, 112, 157, 202, 247, 292, 337]:
            R = D + 0.5
        else:
            R = D
        
        for U in U_unique:
            print('Richting: ', D, ' graden en snelheid ',  U, ' m/s')
    
            index_D = [True if (D_wst[i] == D) else False for i in range(len(D_wst))] 
            index_U = [True if (U_wst[i] == U) else False for i in range(len(U_wst))] 
            
            index_DU =[a and b for a,b in zip(index_D,index_U)]
            
            Results_H_UD = Results_H[index_DU]
            Hs  = Results_H_UD.copy()
            Tp  = Results_H_UD.copy()
            Tm  = Results_H_UD.copy()
            dir = Results_H_UD.copy()

            if teller >= 0:
                if U == 0:
                    for col in Hs.columns:
                        Hs[col].values[:] = 0
                        Tp[col].values[:] = 0
                        Tm[col].values[:] = 0
                        dir[col].values[:] = R
                else:          
                    for locatie in locaties_SWAN:
                        
                        WAQUA_naam_Databaselocatie = locaties_traject.loc[locaties_traject.index==locatie]['WAQUA_naam_Databaselocatie'][0]
                
                        Hs_locatie  = Results_Hs[WAQUA_naam_Databaselocatie]
                        Tp_locatie  = Results_Tp[WAQUA_naam_Databaselocatie]
                        Tm_locatie  = Results_Tm[WAQUA_naam_Databaselocatie]
                        dir_locatie = Results_dir[WAQUA_naam_Databaselocatie]
            
                        indx_D  = [True if (D_SWAN[j] == D) else False for j in range(len(D_SWAN))]
                        indx_U  = [True if (U_SWAN[j] == U) else False for j in range(len(U_SWAN))]
                        indx_DU = [a and b for a,b in zip(indx_D,indx_U)]
                        
                        golven = pd.DataFrame(
                            {'H': Results_Hs['H'][indx_DU], 'Hs': Hs_locatie[indx_DU], 'Tp': Tp_locatie[indx_DU], 
                             'Tm': Tm_locatie[indx_DU],'dir': dir_locatie[indx_DU]})
         
                        golven.sort_values(by=['H'], axis=0, ascending=True, inplace=True)
                        golven.reset_index(drop=True, inplace=True)                
                        golven.loc[golven['Hs'] < 0,'Hs'] = 0
                        golven.loc[golven['Tp'] < 0,'Tp'] = 0
                        golven.loc[golven['Tm'] < 0,'Tm'] = 0
                        golven.loc[golven['dir'] <-99,'dir'] = R
        
                        length_H = golven.shape[0]
        
                        for index in Results_H_UD.index:
            
                            H = Results_H_UD[locatie][index]
                            Hogere_H = golven.index[golven['H'] >= H]
                            if Hogere_H.shape[0] == 0:
                                indx_H = length_H-1
                            else:
                                indx_H = min(Hogere_H)
                                if indx_H == 0:
                                    indx_H = indx_H + 1
                
                            H1 = golven['H'][indx_H-1]
                            H2 = golven['H'][indx_H]
                            factor = (H-H1)/(H2-H1)
                            
                            Hs[locatie][index] = max(golven['Hs'][indx_H-1]*(1-factor) + golven['Hs'][indx_H]*factor, 0.0)
                            Tp[locatie][index] = max(golven['Tp'][indx_H-1]*(1-factor) + golven['Tp'][indx_H]*factor, 0.0)
                            Tm[locatie][index] = max(golven['Tm'][indx_H-1]*(1-factor) + golven['Tm'][indx_H]*factor, 0.0)
                            
                            sindir = np.sin((np.pi/180) * golven['dir'][indx_H-1])*(1-factor) + \
                                     np.sin((np.pi/180) * golven['dir'][indx_H])*factor
                            
                            cosdir = np.cos((np.pi/180) * golven['dir'][indx_H-1])*(1-factor) + \
                                     np.cos((np.pi/180) * golven['dir'][indx_H])*factor
                            
                            theta = np.arctan2(sindir, cosdir)
                            theta = (theta / np.pi) * 180.0
                            if (theta < 0.0):
                               theta = theta + 360.0
                            dir[locatie][index] = theta
                
            for index in Results_H_UD.index:
                SWAN_Hs.append(Hs.loc[index][5:].tolist())
                SWAN_Tp.append(Tp.loc[index][5:].tolist())
                SWAN_Tm.append(Tm.loc[index][5:].tolist())
                SWAN_dir.append(dir.loc[index][5:].tolist())
                combinaties['K'][teller] = Results_H_UD['K'][index]
                combinaties['Q'][teller] = Results_H_UD['Q'][index]
                combinaties['U'][teller] = Results_H_UD['U'][index]
                combinaties['D'][teller] = Results_H_UD['D'][index]
                combinaties['M'][teller] = Results_H_UD['M'][index]
                teller = teller + 1
     
    return combinaties, SWAN_Hs, SWAN_Tp, SWAN_Tm, SWAN_dir

#%%

def SWAN_Golven_sluitregime (trajectfolder, traject, locaties_traject):
    """
    Bepaal uit de SWAN-resultaten de golfparameters voor de gewenste locaties
    
    locaties_traject = structure met gegevens voor de oeverlocaties. Hierin staat bijvoorbeeld of 
                       de backup locatie gebruikt moet worden voor de golven.

    De SWAN-sommen zijn gemaakt voor de stochastcombinaties bij alleen het sluitregime en de westelijke windrichtingen 
    en windsnelheden groter dan 0 m/s.
    De golfparameters worden gebruikt voor zowel de situatie van het sluitregime als die voor de openstaande kering.
    Ook worden de golfparameters uitgebreid met windsnelheden 0 m/s. De oostelijke windrichtingen worden NIET toegevoegd.
    """
    # Initialiseer lege lijsten met resultaten voor golfparameters
    SWAN_Hs = []
    SWAN_Tp = []
    SWAN_Tm = []
    SWAN_dir = []

    WAQUA_naam_Oeverlocatie    = []
    WAQUA_naam_Databaselocatie = []
    locaties_SWAN = locaties_traject[locaties_traject['Inmodel']==True].index.tolist()
    for locatie in locaties_SWAN:
        WAQUA_naam_Oeverlocatie.append(locatie)
        WAQUA_naam_Databaselocatie.append(locaties_traject.loc[locaties_traject.index==locatie]['WAQUA_naam_Databaselocatie'][0])
    Nloc = len(WAQUA_naam_Databaselocatie)

    Results_Hs  = pd.read_csv(os.path.join(trajectfolder, "{}\SWAN_ruw_Ksr_Hs_{}.csv".format(traject, traject)))
    columns = Results_Hs.columns[0:5].tolist() + WAQUA_naam_Databaselocatie
    Results_Hs = Results_Hs[columns]
    K_SWAN = Results_Hs['K'].tolist()
    Q_SWAN = Results_Hs['Q'].tolist()
    U_SWAN = Results_Hs['U'].tolist()
    D_SWAN = Results_Hs['D'].tolist()
    M_SWAN = Results_Hs['M'].tolist()
    
    Results_Tp  = pd.read_csv(os.path.join(trajectfolder, "{}\SWAN_ruw_Ksr_Tp_{}.csv".format(traject, traject)))
    Results_Tp = Results_Tp[columns]
    if (Results_Tp['K'].tolist() != K_SWAN) or \
       (Results_Tp['Q'].tolist() != Q_SWAN) or \
       (Results_Tp['U'].tolist() != U_SWAN) or \
       (Results_Tp['D'].tolist() != D_SWAN) or \
       (Results_Tp['M'].tolist() != M_SWAN):
           exit('Combinaties voor golfparameters niet gelijk in de vier bestanden voor golfparameters. Los dit eerst op')

    Results_Tm  = pd.read_csv(os.path.join(trajectfolder, "{}\SWAN_ruw_Ksr_Tm_{}.csv".format(traject, traject)))
    Results_Tm = Results_Tm[columns]
    if (Results_Tm['K'].tolist() != K_SWAN) or \
       (Results_Tm['Q'].tolist() != Q_SWAN) or \
       (Results_Tm['U'].tolist() != U_SWAN) or \
       (Results_Tm['D'].tolist() != D_SWAN) or \
       (Results_Tm['M'].tolist() != M_SWAN):
           exit('Combinaties voor golfparameters niet gelijk in de vier bestanden voor golfparameters. Los dit eerst op')

    Results_dir = pd.read_csv(os.path.join(trajectfolder, "{}\SWAN_ruw_Ksr_dir_{}.csv".format(traject, traject)))
    Results_dir = Results_dir[columns]
    if (Results_dir['K'].tolist() != K_SWAN) or \
       (Results_dir['Q'].tolist() != Q_SWAN) or \
       (Results_dir['U'].tolist() != U_SWAN) or \
       (Results_dir['D'].tolist() != D_SWAN) or \
       (Results_dir['M'].tolist() != M_SWAN):
           exit('Combinaties voor golfparameters niet gelijk in de vier bestanden voor golfparameters. Los dit eerst op')

    # Kolomnamen gelijkstellen aan de namen van de oeverlocaties
    columns = Results_Hs.columns[0:5].tolist() + WAQUA_naam_Oeverlocatie
    Results_Hs.columns = columns
    Results_Tp.columns = columns
    Results_Tm.columns = columns
    Results_dir.columns = columns

    # Voor de stochastcombinaties zijn alleen sluitregime sommen gemaakt bij de westelijke windrichtingen in de IJsseldelta.
    # Deze berekeningen worden uitgebreid met de altijd open situaties en windsnelheid 0 m/s. (Oost wordt niet toegevoegd)
    # Bepaal het aantal unieke windrichtingen, afvoeren, meerpeilen en windsnelheden van de SWAN-sommen.
    Q_Hs = Results_Hs['Q'].tolist()
    D_Hs = Results_Hs['D'].tolist()
    M_Hs = Results_Hs['M'].tolist()
    U_Hs = Results_Hs['U'].tolist()
    
    Q_unique = sorted(set(Q_Hs))
    D_unique = sorted(set(D_Hs))
    M_unique = sorted(set(M_Hs))
    U_unique = sorted(set(U_Hs))

    # Creëer een dataframe met de juiste afmetingen voor de stochastcombinaties.
    # Dit betekent uitbreiding met de altijd open situatie van de Ramspolkering en windsnelheid 0 m/s.
    N = len(Q_unique) * len(D_unique) * len(M_unique) * (len(U_unique)+1) * 2
    combinaties = pd.DataFrame(
        {'K': [None] * N, 'Q': [None] * N, 'U': [None] * N, 'D': [None] * N, 'M':[None] * N})


    teller = 0
    for D in D_unique:
        print('Richting: ', D, ' graden')
        if D in [22, 67, 112, 157, 202, 247, 292, 337]:
            R = D + 0.5
        else:
            R = D
        
        for Q in Q_unique:
            for M in M_unique:
                index_D = [True if (D_Hs[i] == D) else False for i in range(len(D_Hs))] 
                index_Q = [True if (Q_Hs[i] == Q) else False for i in range(len(Q_Hs))] 
                index_M = [True if (M_Hs[i] == M) else False for i in range(len(M_Hs))] 
                
                index_DQM =[a and b and c for a,b,c in zip(index_D,index_Q,index_M)]
                Results_Hs_DQM = Results_Hs[index_DQM]
                Results_Tp_DQM = Results_Tp[index_DQM]
                Results_Tm_DQM = Results_Tm[index_DQM]
                Results_dir_DQM = Results_dir[index_DQM]

                for locatie in WAQUA_naam_Oeverlocatie:
                    Results_Hs_DQM.loc[(Results_Hs_DQM[locatie] < 0),locatie] = 0
                    Results_Tp_DQM.loc[(Results_Tp_DQM[locatie] < 0),locatie] = 0
                    Results_Tm_DQM.loc[(Results_Tm_DQM[locatie] < 0),locatie] = 0
                    Results_dir_DQM.loc[(Results_dir_DQM[locatie] < -99),locatie] = R
                
                # Windsnelheid 0 m/s toevoegen bij sluitregime
                SWAN_Hs.append([0] * Nloc)
                SWAN_Tp.append([0] * Nloc)
                SWAN_Tm.append([0] * Nloc)
                SWAN_dir.append([R] * Nloc)
                combinaties['K'][teller] = 1
                combinaties['Q'][teller] = Q
                combinaties['U'][teller] = 0.0
                combinaties['D'][teller] = D
                combinaties['M'][teller] = M
                teller = teller + 1

                # Positieve windsnelheden bij het sluitregime
                for index in Results_Hs_DQM.index:
                    SWAN_Hs.append(Results_Hs_DQM.loc[index][5:].tolist())
                    SWAN_Tp.append(Results_Tp_DQM.loc[index][5:].tolist())
                    SWAN_Tm.append(Results_Tm_DQM.loc[index][5:].tolist())
                    SWAN_dir.append(Results_dir_DQM.loc[index][5:].tolist())
                    combinaties['K'][teller] = 1
                    combinaties['Q'][teller] = Results_Hs_DQM['Q'][index]
                    combinaties['U'][teller] = Results_Hs_DQM['U'][index]
                    combinaties['D'][teller] = Results_Hs_DQM['D'][index]
                    combinaties['M'][teller] = Results_Hs_DQM['M'][index]
                    teller = teller + 1

                # Windsnelheid 0 m/s toevoegen bij altijd open kering
                SWAN_Hs.append([0] * Nloc)
                SWAN_Tp.append([0] * Nloc)
                SWAN_Tm.append([0] * Nloc)
                SWAN_dir.append([R] * Nloc)
                combinaties['K'][teller] = 2
                combinaties['Q'][teller] = Q
                combinaties['U'][teller] = 0.0
                combinaties['D'][teller] = D
                combinaties['M'][teller] = M
                teller = teller + 1

                # Positieve windsnelheden bij de altijd openstaande Ramspolkering
                for index in Results_Hs_DQM.index:
                    SWAN_Hs.append(Results_Hs_DQM.loc[index][5:].tolist())
                    SWAN_Tp.append(Results_Tp_DQM.loc[index][5:].tolist())
                    SWAN_Tm.append(Results_Tm_DQM.loc[index][5:].tolist())
                    SWAN_dir.append(Results_dir_DQM.loc[index][5:].tolist())
                    combinaties['K'][teller] = 2
                    combinaties['Q'][teller] = Results_Hs_DQM['Q'][index]
                    combinaties['U'][teller] = Results_Hs_DQM['U'][index]
                    combinaties['D'][teller] = Results_Hs_DQM['D'][index]
                    combinaties['M'][teller] = Results_Hs_DQM['M'][index]
                    teller = teller + 1
     
    return combinaties, SWAN_Hs, SWAN_Tp, SWAN_Tm, SWAN_dir

#%%

def Golven_Bretschneider (traject, trajectfolder, locaties_traject, geometrie, Up2U10):

    locaties_Bret = locaties_traject[locaties_traject['Inmodel']==False].index.tolist()

    waterstanden = pd.read_csv(os.path.join(trajectfolder, traject, "Waterlevels_Database_Filtered_{}.csv".format(traject)))

    Bret_Hs  = []
    Bret_Tp  = []
    Bret_Tm  = []
    Bret_dir = []

    Hs_arr = pd.DataFrame({'locatie' : []})
    Tp_arr = pd.DataFrame({'locatie' : []})

    df_Hs  = pd.DataFrame({'A' : []})
    df_Tp  = pd.DataFrame({'A' : []})
    df_Tm  = pd.DataFrame({'A' : []})
    df_dir = pd.DataFrame({'A' : []})

    for d in np.unique(waterstanden['D']):
        if d in [22, 67, 112, 157, 202, 247, 292, 337]:
            richting = d+0.5
        else:
            richting = d
        waterstanden.loc[waterstanden['D']==d,'RICHTING'] = richting

    for u in np.unique(waterstanden['U']):
        waterstanden.loc[waterstanden['U']==u,'U10'] = Up2U10.loc[Up2U10['Up']==u,'U10'].values[0]

    for i, locatie in enumerate(locaties_Bret):
        locatie_geometrie = geometrie[geometrie['OBJECTID']==locaties_traject['Bretschneider_ID'][i]]
        
        for richting in np.unique(waterstanden['RICHTING']): 
            waterstanden.loc[waterstanden['RICHTING']==richting,'Bodem'] = \
                locatie_geometrie.loc[locatie_geometrie['RICHTING']==richting,'B'].values[0]
            waterstanden.loc[waterstanden['RICHTING']==richting,'FE'] = \
                locatie_geometrie.loc[locatie_geometrie['RICHTING']==richting,'FE'].values[0]
        
        Hs_arr['locatie'], Tp_arr['locatie'] = \
            bretschneider (waterstanden[locatie] - waterstanden['Bodem'], waterstanden['FE'], waterstanden['U10'])
        
        Hs_arr[waterstanden[locatie]<=locaties_traject['bedlevel'][i]]=0
        Tp_arr[waterstanden[locatie]<=locaties_traject['bedlevel'][i]]=0

        if locaties_traject['Geul'][i] == 1:
            Hs_arr[waterstanden['Q']<=2300] = 0
            Tp_arr[waterstanden['Q']<=2300] = 0

        df_Hs[locatie]  = round(Hs_arr['locatie'], 4)
        df_Tp[locatie]  = round(Tp_arr['locatie'], 4)
        df_Tm[locatie]  = round(Tp_arr['locatie'] / 1.1, 4)
        df_dir[locatie] = waterstanden['RICHTING']
    
    del df_Hs['A']
    del df_Tp['A']
    del df_Tm['A']
    del df_dir['A']

    for i in range(len(df_Hs)):
        Bret_Hs.append(df_Hs.loc[i].tolist())
        Bret_Tp.append(df_Tp.loc[i].tolist())
        Bret_Tm.append(df_Tm.loc[i].tolist())
        Bret_dir.append(df_dir.loc[i].tolist())
        
    combinaties = waterstanden[['K','Q','U','D','M']]
        
    return combinaties, Bret_Hs, Bret_Tp, Bret_Tm, Bret_dir

#%%

def Golven_combinatie_IJsseldelta (traject, trajectfolder, golfparameter):

    src_file = os.path.join(trajectfolder, "{}\Golfparameter_SWAN_{}_{}.csv".format(traject, golfparameter, traject))
    dst_file = os.path.join(trajectfolder, "{}\Golfparameter_SWAN_Oost_{}_{}.csv".format(traject, golfparameter, traject))
    copyfile(src_file, dst_file)        

    Results_SWAN_Oost = pd.read_csv(src_file)

    src_file = os.path.join(trajectfolder, "{}\Golfparameter_SWAN_West_{}_{}.csv".format(traject, golfparameter, traject))
    Results_SWAN_West = pd.read_csv(src_file)

    Results_Comb = pd.concat([Results_SWAN_West, Results_SWAN_Oost[Results_SWAN_Oost['D']<225]])
    Results_Comb.reset_index(drop=True, inplace=True)

    
    Comb_golfparameter = []
    for i in range(len(Results_Comb)):
        Comb_golfparameter.append(Results_Comb.loc[i][5:].tolist())

    combinaties = Results_Comb[['K','Q','U','D','M']]
        
    opslaan_golven(traject, 'SWAN_{}'.format(golfparameter), Results_Comb.columns[5:].tolist(), combinaties, Comb_golfparameter, trajectfolder)
        
#%%

def Golven_combinatie_SWAN_Bret (traject, trajectfolder, locaties_Comb, golfparameter):

    Results_Bret = pd.read_csv(os.path.join(trajectfolder, "{}\Golfparameter_Bret_{}_{}.csv".format(traject, golfparameter, traject)))
    Results_Bret.sort_values(['K','Q','U','D','M'], ascending=[True,True,True,True,True], inplace=True)
    Results_Bret.reset_index(drop=True, inplace=True)
    columns_Bret = Results_Bret.columns[5:].tolist()
    
    Results_SWAN = pd.read_csv(os.path.join(trajectfolder, "{}\Golfparameter_SWAN_{}_{}.csv".format(traject, golfparameter, traject)))
    Results_SWAN.sort_values(['K','Q','U','D','M'], ascending=[True,True,True,True,True], inplace=True)
    Results_SWAN.reset_index(drop=True, inplace=True)
    columns_SWAN = Results_SWAN.columns[5:].tolist()

    Results_Comb = pd.concat([Results_SWAN[columns_SWAN], Results_Bret[columns_Bret]], axis=1)[locaties_Comb]
    
    
    Comb_golfparameter = []
    for i in range(len(Results_Comb)):
        Comb_golfparameter.append(Results_Comb.loc[i].tolist())

    combinaties = Results_SWAN[['K','Q','U','D','M']]
        
    opslaan_golven(traject, 'Comb_{}'.format(golfparameter), locaties_Comb, combinaties, Comb_golfparameter, trajectfolder)
        
#%%

def opslaan_golven(traject, golfparameter, oeverlocaties, combinaties, data, trajectfolder):
    
    Results = pd.concat([combinaties, pd.DataFrame(data = data, columns = oeverlocaties)], axis=1)
    
    print("Opslaan van dataframe als csv")
    
    # Sla de resultaten op
    header = Results.columns.tolist()
    data = Results.values
    
    savefolder = os.path.join(trajectfolder, "{}\Golfparameter_{}_{}.csv".format(traject, golfparameter, traject))

    with open(savefolder, "w", newline= "") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(data)    
        
#%%

trajectfolder = os.path.join('..', r'GIS_kaart\Normtrajectdata')
datafolder    = os.path.join('..', 'Hulpgegevens')
SWANdir       = os.path.join('..', 'SWAN_Ksr')
        
# In golven_overzicht zit informatie van alle locaties in de Vecht-IJsseldelta
golven_overzicht = pd.read_csv(os.path.join(datafolder, "Golven_overzicht.csv"))
golven_overzicht.index = golven_overzicht.pop('Name')
geometrie        = pd.read_csv(os.path.join(datafolder, "bh_sl.csv"))
geometrie.loc[geometrie['RICHTING']==0.0,'RICHTING'] = 360.0

select_kolommen = ['Up', 'U10']
Up2U10 = pd.read_excel(os.path.join(datafolder, "Upot2U10cor.xlsx"), sheet_name="Upot2U10cor", delim_whitespace=True, 
                       comment='%', header=0, usecols=select_kolommen, names=select_kolommen)

normtrajecten = ['7-1', '8-4', '9-1', '9-2', '10-1', '10-2', '10-3', '11-1', '11-2', '52a-1', '52-3', '52-4', '53-2', '53-3', '202', '206', '225', '227']
normtrajecten = ['10-3', '11-1']
    
for traject in normtrajecten:  
    # Uit onderstaande routine volgt een dataFrame met gegevens over de golven behorende bij de locaties
    # De golven uit SWAN kunnen er namelijk voor zorgen dat wordt overgestapt op de backup-locatie
    locaties_traject = info_golven_SWAN_BRET(trajectfolder, traject, golven_overzicht, lim=0.1, perc_nat=0.4)

    # Golven uit SWAN met een altijd openstaande Ramspolkering. Dit zijn in de Vechtdelta de enige SWAN sommen die er zijn.
    # Voor de IJsseldelta zijn er twee sets SWAN-sommen, waaronder deze sommen met de openstaande Ramspolkering.
    if traject in ['7-1', '8-4', '9-2', '10-2', '10-3', '11-1', '11-2', '202', '225', '227']:
        print('Golfparametrs uit SWAN bepalen bij de altijd geopende Ramspolkering')
        combinaties, SWAN_Hs, SWAN_Tp, SWAN_Tm, SWAN_dir = SWAN_Golven_AltijdOpen (trajectfolder, traject, locaties_traject)

        locaties_SWAN = locaties_traject[locaties_traject['Inmodel']==True].index.tolist()
        opslaan_golven(traject, 'SWAN_Hs',  locaties_SWAN, combinaties, SWAN_Hs,  trajectfolder)
        opslaan_golven(traject, 'SWAN_Tp',  locaties_SWAN, combinaties, SWAN_Tp,  trajectfolder)
        opslaan_golven(traject, 'SWAN_Tm',  locaties_SWAN, combinaties, SWAN_Tm,  trajectfolder)
        opslaan_golven(traject, 'SWAN_Dir', locaties_SWAN, combinaties, SWAN_dir, trajectfolder)

    # Golven uit SWAN met het sluitregime van de Ramspolkering. Alleen in de IJsseldelta worden deze SWAN-sommen gebruikt
    if traject in ['8-4', '10-3', '11-1', '11-2', '225', '227']:
        print('Golfparametrs uit SWAN bepalen bij het sluitregime van de Ramspolkering')
        combinaties, SWAN_Hs, SWAN_Tp, SWAN_Tm, SWAN_dir = SWAN_Golven_sluitregime (trajectfolder, traject, locaties_traject)

        locaties_SWAN = locaties_traject[locaties_traject['Inmodel']==True].index.tolist()
        opslaan_golven(traject, 'SWAN_West_Hs',  locaties_SWAN, combinaties, SWAN_Hs,  trajectfolder)
        opslaan_golven(traject, 'SWAN_West_Tp',  locaties_SWAN, combinaties, SWAN_Tp,  trajectfolder)
        opslaan_golven(traject, 'SWAN_West_Tm',  locaties_SWAN, combinaties, SWAN_Tm,  trajectfolder)
        opslaan_golven(traject, 'SWAN_West_Dir', locaties_SWAN, combinaties, SWAN_dir, trajectfolder)
        
        # In onderstaande routines zit een minder fraaie oplossing: de de bestanden 'SWAN_..' worden gekopieerd naar 
        # 'SWAN_Oost_Hs' en vervolgens wordt een nieuw bestand 'SWAN_..' geschreven. Zodoende blijven de resultaten uit de 
        # vorige stap behouden. Wel kan dit voor verwarring leiden, omdat de inhoud van de bestanden 'SWAN_..' niet meer 
        # past bij de routine SWAN_Golven_AltijdOpen.
        print('Combineren van de golfparametrs uit SWAN bij het sluitregime en de altijd geopende Ramspolkering')
        Golven_combinatie_IJsseldelta (traject, trajectfolder, 'Hs')
        Golven_combinatie_IJsseldelta (traject, trajectfolder, 'Tp')
        Golven_combinatie_IJsseldelta (traject, trajectfolder, 'Tm')
        Golven_combinatie_IJsseldelta (traject, trajectfolder, 'dir')
    
    # # Golven met Bretschneider
    if traject in ['9-1', '9-2', '10-1', '10-2', '10-3', '11-1', '52a-1', '52-3', '52-4', '53-2', '53-3', '206']:
        print('Golfparametrs berekenen met Bretschneider')
        combinaties, Bret_Hs, Bret_Tp, Bret_Tm, Bret_dir = \
            Golven_Bretschneider (traject, trajectfolder, locaties_traject, geometrie, Up2U10)

        locaties_Bret = locaties_traject[locaties_traject['Inmodel']==False].index.tolist()    
        opslaan_golven(traject, 'Bret_Hs',  locaties_Bret, combinaties, Bret_Hs,  trajectfolder)
        opslaan_golven(traject, 'Bret_Tp',  locaties_Bret, combinaties, Bret_Tp,  trajectfolder)
        opslaan_golven(traject, 'Bret_Tm',  locaties_Bret, combinaties, Bret_Tm,  trajectfolder)
        opslaan_golven(traject, 'Bret_Dir', locaties_Bret, combinaties, Bret_dir, trajectfolder)
        
    # Golven van SWAN en Bretscheider combineren voor trajecten waar dat van toepassing is
    if traject in ['9-2', '10-2', '10-3', '11-1']:
        locaties_Comb = locaties_traject.index.tolist()    

        print('Golfparametrs van Bretschneider en SWAN combineren')
        Golven_combinatie_SWAN_Bret (traject, trajectfolder, locaties_Comb, 'Hs')
        Golven_combinatie_SWAN_Bret (traject, trajectfolder, locaties_Comb, 'Tp')
        Golven_combinatie_SWAN_Bret (traject, trajectfolder, locaties_Comb, 'Tm')
        Golven_combinatie_SWAN_Bret (traject, trajectfolder, locaties_Comb, 'dir')
        
