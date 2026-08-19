# -*- coding: utf-8 -*-
"""
Created on  : 17-02-2022
Author      : Cees Oerlemans
Project     : PR4539.10 BOI Meren
Description : Omzetten van SWAN resultaten naar .csv bestanden die gebruikt worden voor het vullen van databases. Gebaseerd op script van Matthijs Duits voor PR4492.10
"""

import os
import pandas as pd
from pathlib import Path
import numpy as np
from tqdm import tqdm
import csv

parent_dir = Path(__file__).resolve().parent.parent
print(f'we werken in {parent_dir}')
workdir = os.path.join(parent_dir,'NWM')


# locaties inlezen per traject en onderscheid maken tussen alle locaties en swan_locaties
def info_locaties(golfkoptabfile, traject):
    # Laden koppeling DHYDRO en SWAN-locaties
    golfkoptab = pd.read_csv(golfkoptabfile, sep=',')
    golfkoptab = golfkoptab.loc[golfkoptab['TrackCode'] == traject]
    oeverlocaties = golfkoptab['BaseLineName'].to_list()
    swan_locaties = golfkoptab['BaseLineName'].loc[golfkoptab['SWAN'] == True].to_list()
    
    return oeverlocaties, swan_locaties

#%%
def lees_SWAN(swan_locaties, golfkoptabfile, ws, traject):
    """
    Lees SWAN-resultaten
    """
    select_kolommen = ['Xp', 'Yp', 'Hsig', 'TPsmoo', 'Tm_10', 'Dir']

    foldersSWAN = os.listdir(SWAN_map)
    
    # Initieer lege lijsten stochasten 
    H = []
    D = []
    U = []

    # Initialiseer lege lijsten met resultaten voor golfparameters
    SWAN_Hs = []
    SWAN_Tp = []
    SWAN_Tm = []
    SWAN_DIR = []

    print(f'aantal swan locaties is {len(swan_locaties)}')

    # maak lijst van coordinaten swan locaties
    golfkoptab = pd.read_csv(golfkoptabfile, sep=",")
    swan_golven = golfkoptab.set_index('BaseLineName')
    swan_golven = swan_golven.loc[swan_locaties]
    swan_golven = swan_golven.loc[swan_golven['TrackCode']==traject]
    x = swan_golven['XCoordinate'].to_list()
    y = swan_golven['YCoordinate'].to_list()
    print("aantal locaties in swan_golven: ", len(x))
    
    #lus over golfbestanden om resultaten te verzamelen
    for SWAN_bestand in tqdm(foldersSWAN):  
        #haal waarde stochasten uit naam
        if ws == 'grev':
            if (SWAN_bestand[12:13] == 'm'): # n van negatief
                H.append(-1.0 * float(SWAN_bestand[13:16])/100)
            else:                          # p van positief
                H.append(float(SWAN_bestand[13:16])/100)
                
            U.append(float(SWAN_bestand[5:7]))
            D_SWAN = float(SWAN_bestand[8:11])

        elif ws == 'vrm':
            if (SWAN_bestand[11:12] == 'm'): # m van minus
                H.append(-1.0 * float(SWAN_bestand[12:15])/100)
            else:                          # p van positief
                H.append(float(SWAN_bestand[12:15])/100)
                
            U.append(float(SWAN_bestand[4:6]))
            D_SWAN = float(SWAN_bestand[7:10])
        elif ws == 'mm':
            if (SWAN_bestand[10:11] == 'm'): # m van minus
                H.append(-1.0 * float(SWAN_bestand[11:14])/100)
            else:                          # p van positief
                H.append(float(SWAN_bestand[11:14])/100)
                
            U.append(float(SWAN_bestand[3:5]))
            D_SWAN = float(SWAN_bestand[6:9])
        elif ws == 'vzm':
            if (SWAN_bestand[11:12] == 'm'): # m van minus
                H.append(-1.0 * float(SWAN_bestand[12:15])/100)
            else:                          # p van positief
                H.append(float(SWAN_bestand[12:15])/100)
                
            U.append(float(SWAN_bestand[4:6]))
            D_SWAN = float(SWAN_bestand[7:10])
        else:
            raise ValueError(f"Onbekend watersysteem: {ws}")
        
        if D_SWAN == 0.0:
            D_SWAN = 360.0
        D.append(D_SWAN)
        
        #pad naar golfbestand
        filepath = os.path.join(SWAN_map, SWAN_bestand, 'results', SWAN_bestand + '_p4_boi.tab')
        # lees headerregel
        with open(filepath, 'r') as f:
            for line in f.readlines():
                if select_kolommen[0] in line:
                    header = line[1:].split()
                    break
        select_indices = [header.index(col) for col in select_kolommen]
        
        # lees golfbestand uit
        resultaat = pd.read_table(filepath, sep='\s+', comment='%', header=None, 
                                  usecols=select_indices, names=select_kolommen)
        
        SWAN_Hs_tmp = []
        SWAN_Tp_tmp = []
        SWAN_Tm_tmp = []
        SWAN_DIR_tmp = []

      
        for i in range(len(x)):
            # controle of coordinaten van koppeltabel in SWAN bestand aanwezig zijn
            if x[i] not in resultaat['Xp'].to_list():
                print('x-coordinaat ', x[i],  'niet in SWAN bestand')
            if y[i] not in resultaat['Yp'].to_list():
                print('y-coordinaat ', y[i], ' niet in SWAN bestand')

            
            resultaat_traject = resultaat.loc[resultaat['Xp'] == x[i]]
            resultaat_traject = resultaat_traject.loc[resultaat_traject['Yp'] == y[i]]

            Hs  = resultaat_traject[select_kolommen[2]].to_list()
            Tp  = resultaat_traject[select_kolommen[3]].to_list()
            Tm  = resultaat_traject[select_kolommen[4]].to_list()
            DIR = resultaat_traject[select_kolommen[5]].to_list()
            
            SWAN_Hs_tmp.append(Hs[0])
            SWAN_Tp_tmp.append(Tp[0])
            SWAN_Tm_tmp.append(Tm[0])
            SWAN_DIR_tmp.append(DIR[0])
        
        SWAN_Hs.append(SWAN_Hs_tmp)
        SWAN_Tp.append(SWAN_Tp_tmp)
        SWAN_Tm.append(SWAN_Tm_tmp)
        SWAN_DIR.append(SWAN_DIR_tmp)      
            
    combinaties = pd.DataFrame(
        {'U': U, 'D': D, 'H': H})
     
    return combinaties, SWAN_Hs, SWAN_Tp, SWAN_Tm, SWAN_DIR

#%%

def opslaan_golven(golfparameter, oeverlocaties, combinaties, data, resultfolder):
    Results = pd.concat([combinaties, pd.DataFrame(data = data, columns = oeverlocaties)], axis=1)
    
    print("Opslaan Golfparameter {}".format(golfparameter))
    
    # Sla de resultaten op
    header = Results.columns.tolist()
    data = Results.values
    
    if not os.path.exists(resultfolder): 
        os.makedirs(resultfolder) 
    
    savefolder = os.path.join(resultfolder, "SWAN_ruw_{}_{}.csv".format(golfparameter, traject))
    print(f"gegevens opslaan in {savefolder}")
    with open(savefolder, "w", newline= "") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(data)    
        
#%%
ws = 'vrm'
# aanpassing LL: paden uit de if-els structuur halen ivm leesbaarhed

SWAN_map = os.path.join(workdir,
                        f'swan-{ws}_hr2023')
trajectdata = os.path.join(workdir,
                           f'database_figuren_meren/DHYDRO_{ws}_results/Normtrajectdata')
resultfolder = os.path.join(workdir,
                            f'database_figuren_meren/DHYDRO_{ws}_results/Brondata')
dir_generalmodeldata = os.path.join(workdir,
                                     f'database_figuren_meren/input_generalmodeldata/{ws.upper()}')
# aanpassing LL: koppeling met _v1 en niet met _backup, want backup gaat in 8b
golfkoptabfile = os.path.join(dir_generalmodeldata,
                              f'{ws}_DHYDRO_SWAN_koppeling_v1.csv')
                            #   f'{ws}_DHYDRO_SWAN_koppeling_backup.csv')
wskoptabfile = os.path.join(dir_generalmodeldata,
                            f'{ws.upper()}_koppeltabel_v2022_06_10.csv')

if 'grev' in ws:
    trajecten= ['25-4','214','26-4','216']
elif 'vrm' in ws: 
    trajecten= ['hoge gronden Veluwerandmeren', '8-5', '8-6', '8-7', '205', '11-3', '227', '45-3']
    # trajecten = ['45-3','hoge gronden Veluwerandmeren']  # tijdelijk voor testen
elif 'vzm' in ws: 
    trajecten= ['215','25-3','216','217', '27-4', '27-3', '219', '31-3', '223', '33-1', '34-5', '34-4', '34-3']
elif 'mm' in ws: 
    trajecten= ['13-7','13-8','13-9','13b-1', '46-1', '44-2', '45-2', '205', '8-1', '8-2', '8-3', '204a']

    
for traject in trajecten: 
    trajectfolder = os.path.join(trajectdata, traject)
    resultfoldertraject = os.path.join(resultfolder, traject)
    os.makedirs(resultfoldertraject, exist_ok=True)
    oeverlocaties, swan_locaties = info_locaties(golfkoptabfile, traject)
    
    
    print('SWAN-berekeningen .tab format omschrijven naar .csv per traject voor traject {}'.format(traject))
    
    #lus over locaties
    combinaties, SWAN_Hs, SWAN_Tp, SWAN_Tm, SWAN_dir = lees_SWAN(oeverlocaties, golfkoptabfile, ws, traject)
    
    print(f'traject: {traject}, aantal oeverlocaties: {len(oeverlocaties)}')
    print(f'traject: {traject}, aantal swanlocaties: {len(swan_locaties)}')
    print(f'traject: {traject}, aantal resultaten: {np.array(SWAN_Hs).shape}')
    # aanpassing LL, oeverlocaties bij hoge gronden Veluwerandmeren heeft len 200
    # en de SWAN ouput shape (1664,303), hierop aanpassen. obv volgnummers in script 3
    # if traject == 'hoge gronden Veluwerandmeren':
    #     SWAN_Hs = np.array(SWAN_Hs)[:,:len(oeverlocaties)]
    #     SWAN_Tp = np.array(SWAN_Tp)[:,:len(oeverlocaties)]
    #     SWAN_Tm = np.array(SWAN_Tm)[:,:len(oeverlocaties)]
    #     SWAN_dir = np.array(SWAN_dir)[:,:len(oeverlocaties)]

    print('Opslaan SWAN_ruw.csv bestanden')
    opslaan_golven('Hs',  oeverlocaties, combinaties, SWAN_Hs,  resultfoldertraject)
    opslaan_golven('Tp',  oeverlocaties, combinaties, SWAN_Tp,  resultfoldertraject)
    opslaan_golven('Tm',  oeverlocaties, combinaties, SWAN_Tm,  resultfoldertraject)
    opslaan_golven('Dir', oeverlocaties, combinaties, SWAN_dir, resultfoldertraject)
