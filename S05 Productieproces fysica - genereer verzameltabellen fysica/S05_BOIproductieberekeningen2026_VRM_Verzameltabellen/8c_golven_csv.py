# -*- coding: utf-8 -*-
"""
Created on  : 17-02-2022
Author      : Cees Oerlemans
Project     : PR4539.10 BOI Meren
Description : SWAN resultaten valkke waterspiegels vertalen naar lokale waterstanden DHYDRO. Gebaseerd op script van Matthijs Duits voor PR4492.10
"""

import os
from sys import exit
import pandas as pd
from pathlib import Path
pd.options.mode.chained_assignment = None
import numpy as np
from shutil import copyfile
# from hkvpy.hrd import bretschneider
from hrd import bretschneider
#from Golven_info import info_golven_SWAN_BRET
from tqdm import tqdm
import csv

parent_dir = Path(__file__).resolve().parent.parent
print(f'we werken in {parent_dir}')
workdir = os.path.join(parent_dir,'NWM')


# Bouwen van dataframe met informatie over golfparameters (SWAN/Bretschneider) voor een bepaald traject
def info_locaties(golfkoptabfile, traject):
    # Laden koppeling DHYDRO en SWAN-locaties
    golfkoptab = pd.read_csv(golfkoptabfile, sep=',')
    golfkoptab = golfkoptab.loc[golfkoptab['TrackCode'] == traject]
    oeverlocaties = golfkoptab['BaseLineName'].to_list()
    swan_locaties = golfkoptab.loc[golfkoptab['SWAN'] == True]
    bret_locaties = golfkoptab.loc[golfkoptab['Bretschneider'] == True]
    
    return oeverlocaties, swan_locaties, bret_locaties

#%%

def swan_golven(trajectfolder, brondata, filter_ws, traject, swan_locaties):
    """
    Bepaal uit de SWAN-resultaten de golfparameters voor de gewenste locaties en waterstanden
    
    """
    # Initialiseer lege lijsten met resultaten voor golfparameters
    SWAN_Hs = []
    SWAN_Tp = []
    SWAN_Tm = []
    SWAN_dir = []

    # Lees de waterstanden
    Results_H = pd.read_csv(os.path.join(trajectfolder, f"Waterlevels_Database_{filter_ws}_Filtered_{traject}.csv"))
    
    # vervang niet-afgeronde windsnelheden door afgeronde windsnelheden
    # Results_H['D'] = Results_H['D'].replace(22.5, 23).replace(67.5, 68).replace(112.5, 113).replace(157.5, 158).replace(202.5, 203).replace(247.5, 248).replace(292.5, 293).replace(337.5, 338)
    Results_H['D'] = Results_H['D'].replace({22.5:23,
                                             67.5:68,
                                             112.5:113, 
                                             157.5:158, 
                                             202.5:203, 
                                             247.5:248, 
                                             292.5:293, 
                                             337.5:338}).infer_objects(copy=False)
    # print(Results_H)

    # Eerst de selectie maken van de locaties waar de golven uit SWAN komen
    columns = ['U','D','M']+swan_locaties['BaseLineName'].to_list()
    Results_H = Results_H[columns]
    
    # lees stochastcombinaties
    combinaties = pd.DataFrame(index=range(len(Results_H)),columns=range(3))
    combinaties.columns ={'U', 'D', 'M'}
    
    # lees de ruwe golfparameters uit
    Results_Hs  = pd.read_csv(os.path.join(brondata, f"SWAN_ruw_Hs_{traject}.csv"))
    U_SWAN = Results_Hs['U'].tolist()
    D_SWAN = Results_Hs['D'].tolist()
    H_SWAN = Results_Hs['H'].tolist()
    
    #check of de combinaties in de verschillende golfparameterbestanden gelijk zijn
    Results_Tp  = pd.read_csv(os.path.join(brondata, f"SWAN_ruw_Tp_{traject}.csv"))
    if (Results_Tp['U'].tolist() != U_SWAN) or \
       (Results_Tp['D'].tolist() != D_SWAN) or \
       (Results_Tp['H'].tolist() != H_SWAN):
           exit('Combinaties voor golfparameters niet gelijk in de vier bestanden voor golfparameters. Los dit eerst op')

    Results_Tm  = pd.read_csv(os.path.join(brondata, f"SWAN_ruw_Tm_{traject}.csv"))
    if (Results_Tm['U'].tolist() != U_SWAN) or \
       (Results_Tm['D'].tolist() != D_SWAN) or \
       (Results_Tm['H'].tolist() != H_SWAN):
           exit('Combinaties voor golfparameters niet gelijk in de vier bestanden voor golfparameters. Los dit eerst op')

    Results_dir = pd.read_csv(os.path.join(brondata, f"SWAN_ruw_Dir_{traject}.csv"))
    if (Results_dir['U'].tolist() != U_SWAN) or \
       (Results_dir['D'].tolist() != D_SWAN) or \
       (Results_dir['H'].tolist() != H_SWAN):
           exit('Combinaties voor golfparameters niet gelijk in de vier bestanden voor golfparameters. Los dit eerst op')

    # Bepaal het aantal unieke windrichtingen en windsnelheden in de waterstanden DataFrame
    D_wst = Results_H['D'].tolist()
    U_wst = Results_H['U'].tolist()
    
    D_unique = sorted(set(D_wst))
    U_unique = sorted(set(U_wst))

    teller = 0
    
    # koppeling tussen opgelegde windrichting en windrichting in naamgeving
    for D in tqdm(D_unique):
        if D in [23.0, 68.0, 113.0, 158.0, 203.0, 248.0, 294.0, 338.0]:
            R = D - 0.5
        else:
            R = D
        
        for U in U_unique:
            #print('Richting: ', D, ' graden en snelheid ',  U, ' m/s')
            

            index_D = [True if (D_wst[i] == D) else False for i in range(len(D_wst))] 
            index_U = [True if (U_wst[i] == U) else False for i in range(len(U_wst))] 
            

            index_DU =[a and b for a,b in zip(index_D,index_U)]
            
            Results_H_UD = Results_H[index_DU].copy()
            Hs  = Results_H_UD.copy()
            Tp  = Results_H_UD.copy()
            Tm  = Results_H_UD.copy()
            DIR = Results_H_UD.copy()

            if teller >= 0:
                # als windsnelheid 0 geen golven
                if U == 0:
                    for col in Hs.columns:
                        Hs[col].values[:] = 0
                        Tp[col].values[:] = 0
                        Tm[col].values[:] = 0
                        DIR[col].values[:] = R
                else:          
                    #lus door locaties
                    for locatie in swan_locaties['BaseLineName'].to_list():
                        # golfparamater per locatie
                        Hs_locatie  = Results_Hs[locatie].copy()
                        Tp_locatie  = Results_Tp[locatie].copy()
                        Tm_locatie  = Results_Tm[locatie].copy()
                        dir_locatie = Results_dir[locatie].copy()
                        
                        indx_D  = [True if (D_SWAN[j] == int(D)) else False for j in range(len(D_SWAN))]
                        indx_U  = [True if (U_SWAN[j] == U) else False for j in range(len(U_SWAN))]
                        indx_DU = [a and b for a,b in zip(indx_D,indx_U)]
                        
                        # dataframe met golven
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
                
                            # berekenen gewicht omliggende golfresultaten
                            H1 = golven['H'][indx_H-1]
                            H2 = golven['H'][indx_H]
                            #print('interpoleren tussen', H1, 'en', H2)
                            factor = (H-H1)/(H2-H1)
                            
                            # berekenen golfparameters op locatie op basis van omliggende SWAN resultaten
                            Hs.loc[index, locatie] = max(golven['Hs'][indx_H-1]*(1-factor) + golven['Hs'][indx_H]*factor, 0.0)
                            Tp.loc[index, locatie] = max(golven['Tp'][indx_H-1]*(1-factor) + golven['Tp'][indx_H]*factor, 0.0)
                            Tm.loc[index, locatie] = max(golven['Tm'][indx_H-1]*(1-factor) + golven['Tm'][indx_H]*factor, 0.0)

                            # Hs[locatie][index] = max(golven['Hs'][indx_H-1]*(1-factor) + golven['Hs'][indx_H]*factor, 0.0)
                            # Tp[locatie][index] = max(golven['Tp'][indx_H-1]*(1-factor) + golven['Tp'][indx_H]*factor, 0.0)
                            # Tm[locatie][index] = max(golven['Tm'][indx_H-1]*(1-factor) + golven['Tm'][indx_H]*factor, 0.0)
                            
                            #print('geïnterpoleerde golfhoogte', Hs[locatie][index])
                            #print('geïnterpoleerde golfperiode', Tp[locatie][index])
                            #print('geïnterpoleerde spectrale golfhoogte', Tm[locatie][index])
                            
                            # berekenen golfrichting op locatie op basis van omliggende SWAN resultaten
                            sindir = np.sin((np.pi/180) * golven['dir'][indx_H-1])*(1-factor) + \
                                     np.sin((np.pi/180) * golven['dir'][indx_H])*factor
                            
                            cosdir = np.cos((np.pi/180) * golven['dir'][indx_H-1])*(1-factor) + \
                                     np.cos((np.pi/180) * golven['dir'][indx_H])*factor
                            
                            theta = np.arctan2(sindir, cosdir)
                            theta = (theta / np.pi) * 180.0
                            if (theta < 0.0):
                               theta = theta + 360.0
                            # DIR[locatie_ws][index] = theta
                            DIR.loc[index, locatie] = theta
            
            #print(Results_H_UD.index)
            for index in Results_H_UD.index:
                #print(round(Hs.loc[index][3:],4).tolist()[1])
                Hs_list = round(Hs.loc[index][3:],3).tolist()
                Hs_list = [f"{num:.3f}" for num in Hs_list]
                SWAN_Hs.append(Hs_list)
                Tp_list = round(Tp.loc[index][3:],3).tolist()
                Tp_list = [f"{num:.3f}" for num in Tp_list]
                SWAN_Tp.append(Tp_list)
                Tm_list = round(Tm.loc[index][3:],3).tolist()
                Tm_list = [f"{num:.3f}" for num in Tm_list]
                SWAN_Tm.append(Tm_list)
                dir_list = round(DIR.loc[index][3:],1).tolist()
                dir_list = [f"{num:.1f}" for num in dir_list]
                SWAN_dir.append(dir_list)
                combinaties.loc[teller,'U'] = Results_H_UD['U'][index]
                combinaties.loc[teller,'D'] = Results_H_UD['D'][index]
                combinaties.loc[teller,'M'] = Results_H_UD['M'][index]
                #  combinaties['U'][teller] = Results_H_UD['U'][index]
                # combinaties['D'][teller] = Results_H_UD['D'][index]
                # combinaties['M'][teller] = Results_H_UD['M'][index]
                teller = teller + 1
            
            #vervang afgeronde windrichtingen door niet-afgeronde windrichtingen
            # combinaties['D'] = combinaties['D'].replace(23.0, 22.5).replace(68.0, 67.5).replace(113.0, 112.5).replace(158.0, 157.5).replace(203.0, 202.5).replace(248.0, 247.5).replace(293.0, 292.5).replace(338.0, 337.5)
            combinaties['D'] = combinaties['D'].replace({23.0: 22.5,
                                                        68.0: 67.5,
                                                        113.0: 112.5,
                                                        158.0: 157.5,
                                                        203.0: 202.5,
                                                        248.0: 247.5,
                                                        293.0: 292.5,
                                                        338.0: 337.5}
                                                        ).infer_objects(copy=False)
            combinaties.reindex(columns=['U', 'D', 'M'])    

    return combinaties, SWAN_Hs, SWAN_Tp, SWAN_Tm, SWAN_dir

#%%

def bretschneider_golven(trajectfolder, locaties_traject, geometrie, Up2U10):
    
    # Selecteer Bretschneider locaties, locatie die buiten het SWAN-model liggen
    locaties_Bret = locaties_traject[locaties_traject['Inmodel']==False].index.tolist()

    # Lees waterstanden uit
    waterstanden = pd.read_csv(os.path.join(
        trajectfolder, 
        f"Waterlevels_Database_{filter_ws}_Filtered_{traject}.csv"
        ))

    # Initieer lege lijsten
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

    # koppeling tussen opgelegde windsnelheid en windsnelheid in naamgeving
    for d in np.unique(waterstanden['D']):
        if d in [23, 68, 113, 158, 203, 248, 293, 338]:
            richting = d-0.5
        else:
            richting = d
        waterstanden.loc[waterstanden['D']==d,'RICHTING'] = richting

    # Koppeling potentiële windsnelheden naar bretschneider windsnelheden
    for u in np.unique(waterstanden['U']):
        waterstanden.loc[waterstanden['U']==u,'U10'] = Up2U10.loc[Up2U10['Up']==u,'U10'].values[0]

    for idum, locatie in enumerate(locaties_Bret):
        locatie_geometrie = geometrie[geometrie['OBJECTID']==locaties_traject.loc[locatie]['Bretschneider_ID']]
        
        for richting in np.unique(waterstanden['RICHTING']): 
            waterstanden.loc[waterstanden['RICHTING']==richting,'Bodem'] = \
                locatie_geometrie.loc[locatie_geometrie['RICHTING']==richting,'B'].values[0]
            waterstanden.loc[waterstanden['RICHTING']==richting,'FE'] = \
                locatie_geometrie.loc[locatie_geometrie['RICHTING']==richting,'FE'].values[0]
        
        Hydranaam = locaties_traject[locaties_traject.index == locatie]['Hydranaam'].values[0]
        
        Hs_arr['locatie'], Tp_arr['locatie'] = \
            bretschneider (waterstanden[Hydranaam] - waterstanden['Bodem'], waterstanden['FE'], waterstanden['U10'])
        
        Hs_arr[waterstanden[Hydranaam]<=locaties_traject.loc[locatie]['bedlevel']]=0
        Tp_arr[waterstanden[Hydranaam]<=locaties_traject.loc[locatie]['bedlevel']]=0

        if locaties_traject.loc[locatie]['Geul'] == 1:
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
        
    combinaties = waterstanden[['U','D','M']]
        
    return combinaties, Bret_Hs, Bret_Tp, Bret_Tm, Bret_dir

#%%

def comb_golven(trajectfolder, locaties_Comb, golfparameter):

    Results_Bret = pd.read_csv(os.path.join(trajectfolder, f"Golfparameter_Bret_{golfparameter}_v3.csv"))
    Results_Bret.sort_values(['U','D','M'], ascending=[True,True,True], inplace=True)
    Results_Bret.reset_index(drop=True, inplace=True)
    columns_Bret = Results_Bret.columns[3:].tolist()

    Results_SWAN = pd.read_csv(os.path.join(trajectfolder, f"Golfparameter_SWAN_{golfparameter}_v3.csv" ))
    Results_SWAN.sort_values(['U','D','M'], ascending=[True,True,True], inplace=True)
    Results_SWAN.reset_index(drop=True, inplace=True)
    columns_SWAN = Results_SWAN.columns[3:].tolist()

    Results_Comb = pd.concat([Results_SWAN[columns_SWAN], Results_Bret[columns_Bret]], axis=1)[locaties_Comb]
   
    Comb_golfparameter = []
    for i in range(len(Results_Comb)):
        Comb_golfparameter.append(Results_Comb.loc[i].tolist())

    combinaties = Results_SWAN[['U','D','M']]
        
    opslaan_golven(f'Comb_{golfparameter}', locaties_Comb, combinaties, Comb_golfparameter, trajectfolder, traject)
        
#%%

def opslaan_golven(golfparameter, oeverlocaties, combinaties, data, trajectfolder, traject):
    
    Results = pd.concat([combinaties, pd.DataFrame(data = data, columns = oeverlocaties)], axis=1)
    
    print("Opslaan van dataframe als csv")
    
    # Sla de resultaten op
    header = Results.columns.tolist()
    data = Results.values

    savefolder = os.path.join(trajectfolder, f"Golfparameter_{golfparameter}_{traject}.csv")

    with open(savefolder, "w", newline= "") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(data)    
        
#%%
ws = 'vrm'
dir_generalmodeldata = os.path.join(workdir,
                                     f'database_figuren_meren/input_generalmodeldata/{ws.upper()}')
normtrajectdata = os.path.join(workdir,
                           f'database_figuren_meren/DHYDRO_{ws}_results/Normtrajectdata')
#locatie ruwe SWAN-resultaten
brondata = os.path.join(workdir,
                            f'database_figuren_meren/DHYDRO_{ws}_results/Brondata')
#koppeling tussen basis-, backup- en terugvallocaties DHYDRO
golfkoptabfile = os.path.join(dir_generalmodeldata,
                              f'{ws}_DHYDRO_SWAN_koppeling_v1.csv')
#koppeling tussen DHYDRO- en SWAN-locaties
wskoptabfile = os.path.join(dir_generalmodeldata,
                            f'{ws.upper()}_koppeltabel_v2022_06_10.csv')
filter_ws = 'grad0.1_bakje2'

if 'grev' in ws:
    trajecten= ['25-4','214','26-4','216']
elif 'vrm' in ws: 
    # trajecten = ['227', '8-5', '8-6', '8-7', '205', '45-3', '11-3']
    trajecten = ['227', '8-5', '8-6', '8-7', '205', '45-3', '11-3', 'hoge gronden Veluwerandmeren']
elif 'vzm' in ws: 
    trajecten= ['215','25-3','216','217', '27-4', '27-3', '219', '31-3', '223', '33-1', '34-5', '34-4', '34-3']
elif 'mm' in ws: 
    trajecten= ['13-7','13-8','13-9','13b-1', '46-1', '44-2', '45-2', '205', '8-1', '8-2', '8-3', '204a']
    
Up2U10file = os.path.join(workdir,
                            'database_figuren_meren/input_generalmodeldata/golven/Upot2U10cor.xlsx')
        

# select_kolommen = ['Up', 'U10']
# Up2U10 = pd.read_excel(Up2U10file, sheet_name="Upot2U10cor", \
#                    comment='%', header=0, usecols=select_kolommen, names=select_kolommen)

for traject in trajecten:
    trajectfolder = os.path.join(normtrajectdata, traject)
    brondatatraject = os.path.join(brondata, traject)

    # Uit onderstaande routine volgt een dataFrame met gegevens over de golven behorende bij de locaties
    # De golven uit SWAN kunnen er namelijk voor zorgen dat wordt overgestapt op de backup-locatie
    oeverlocaties, swan_locaties, bret_locaties  = info_locaties(golfkoptabfile, traject)
    print('Golfparameters uit SWAN voor traject ', traject)
    combinaties, SWAN_Hs, SWAN_Tp, SWAN_Tm, SWAN_dir = swan_golven(trajectfolder, brondatatraject, filter_ws, traject, swan_locaties)
    
    opslaan_golven('SWAN_Hs',  swan_locaties['BaseLineName'].to_list(), combinaties, SWAN_Hs,  trajectfolder, traject)
    opslaan_golven('SWAN_Tp',  swan_locaties['BaseLineName'].to_list(), combinaties, SWAN_Tp,  trajectfolder, traject)
    opslaan_golven('SWAN_Tm',  swan_locaties['BaseLineName'].to_list(), combinaties, SWAN_Tm,  trajectfolder, traject)
    opslaan_golven('SWAN_Dir', swan_locaties['BaseLineName'].to_list(), combinaties, SWAN_dir, trajectfolder, traject)
    
    # Golven met Bretschneider
    #print('Golfparameters berekenen met Bretschneider voor traject ', traject)
    #combinaties, Bret_Hs, Bret_Tp, Bret_Tm, Bret_dir = bretschneider_golven(trajectfolder, locaties_traject, geometrie, Up2U10)
    
    # locaties_Bret = locaties_traject[locaties_traject['Inmodel']==False].index.tolist()    
    # locaties_Hydra_Bret = []
    # for i in range(len(locaties_Bret)):
    #     locaties_Hydra_Bret.append(locaties_traject.loc[locaties_traject.index==locaties_Bret[i]]['Hydranaam'][0])
    # opslaan_golven('Bret_Hs',  locaties_Hydra_Bret, combinaties, Bret_Hs,  trajectfolder, traject)
    # opslaan_golven('Bret_Tp',  locaties_Hydra_Bret, combinaties, Bret_Tp,  trajectfolder, traject)
    # opslaan_golven('Bret_Tm',  locaties_Hydra_Bret, combinaties, Bret_Tm,  trajectfolder, traject)
    # opslaan_golven('Bret_Dir', locaties_Hydra_Bret, combinaties, Bret_dir, trajectfolder, traject)
        
    # Golven van SWAN en Bretscheider combineren 
    # EenRijWaterstanden = pd.read_csv(os.path.join(trajectfolder, "Waterlevels_Database_Filtered.csv"), nrows=1)
    # locaties_Comb = EenRijWaterstanden.columns[3:].tolist()
    
    #print('Golfparameters van Bretschneider en SWAN combinerenvoor traject', traject)
    #Comb_golven(trajectfolder, locaties_Comb, 'Hs')
    #Comb_golven(trajectfolder, locaties_Comb, 'Tp')
    #Comb_golven(trajectfolder, locaties_Comb, 'Tm')
    #Comb_golven(trajectfolder, locaties_Comb, 'dir')
