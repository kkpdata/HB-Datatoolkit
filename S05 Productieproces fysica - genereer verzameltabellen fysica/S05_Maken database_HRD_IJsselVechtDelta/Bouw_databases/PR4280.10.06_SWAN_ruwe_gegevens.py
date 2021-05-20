# -*- coding: utf-8 -*-
"""
Created on Tue JUN 16 10:06:26 2020

@author: duits
"""

import os
import pandas as pd
import numpy as np
from tqdm import tqdm
import csv

#%%

# Bouwen van dataframe met alle oever- en backuplocaties van het traject
def info_locaties(trajectfolder, traject, golven_overzicht):
    # Uitvoer
    # Dataframe "locaties_traject" met met meerdere kolommen:
    #  1. Oeverlocatie met WAQUA-naam
    #  2. ID van de SWAN-golven.
    
    # Laden van bestand met koppeling locaties
    file = os.path.join(trajectfolder, "{}\Database_{}.xlsx".format(traject, traject))
    locaties = pd.read_excel(file)     
    locaties.index = locaties.pop('Name')
    print('Traject {} bevat {} locaties'.format(traject, len(locaties)))
    
    # Lijst van oeverlocaties en backuplocaties
    oeverlocaties = locaties.index.tolist()
    backuplocaties = locaties.naam_backup.tolist()
    # aslocaties worden niet gebruikt voor golven
    
    alle_locaties = oeverlocaties + backuplocaties
    alle_locaties = list(set(alle_locaties))
    
    locaties_traject = pd.DataFrame({'locatie' : alle_locaties})

    # Hier wordt gewerkt met een gedeeltelijke vervanging van de oeverlocaties
    info_locaties_traject = golven_overzicht.loc[alle_locaties]
    locaties_traject['SWAN_ID'] = info_locaties_traject['SWAN_ID'].tolist()
    
    locaties_traject.index = locaties_traject.pop('locatie')
    
    locaties_traject = locaties_traject.dropna() 
    
    locaties_traject = locaties_traject[locaties_traject['SWAN_ID'] > 0]
    
    return locaties_traject

#%%

def Lees_SWAN_Ksr (SWAN_ID):
    """
    Lees SWAN-resultaten
    
    SWAN_ID = ID van de locatie in de SWAN-bestanden
    """
    select_kolommen = ['Xp', 'Yp', 'Hsig', 'TPsmoo', 'Tm_10', 'Dir']

    foldersSWAN = os.listdir(SWAN_dir_Ksr)

    # Initieer combinaties    
    K = []
    M = []
    Q = []
    D = []
    U = []

    # Initialiseer lege lijsten met resultaten voor golfparameters
    SWAN_Hs = []
    SWAN_Tp = []
    SWAN_Tm = []
    SWAN_dir = []
    for folder in foldersSWAN:  
        if os.path.isdir(os.path.join(SWAN_dir_Ksr,folder)):

            # if float(folder[9:13]) == 500:
            #     break

            if (folder[1:3] == 'sr'): # sr = sluitregime
                K.append(1.0)
            else: # ao = altijd open
                K.append(2.0)
                
            if (folder[4:5] == 'n'): # n van negatief
                M.append(-1.0 * float(folder[5:8])/100)
            else:                    # p van positief
                M.append(float(folder[5:8])/100)
                
            Q.append(float(folder[9:13]))
            U.append(float(folder[14:16]))
            D.append(float(folder[17:20]))

            SWAN_bestand = os.listdir(os.path.join(SWAN_dir_Ksr,folder)) 
            
            filepath = os.path.join(SWAN_dir_Ksr,folder,SWAN_bestand[0])
            # lees headerregel
            with open(filepath, 'r') as f:
                for line in f.readlines():
                    if select_kolommen[0] in line:
                        header = line[1:].split()
                        break
            select_indices = [header.index(col) for col in select_kolommen]
            
            # lees file
            resultaat = pd.read_table(filepath, delim_whitespace=True, comment='%', header=None, 
                                      usecols=select_indices, names=select_kolommen)
            SWAN_Index = [ID-1 for ID in SWAN_ID]
            resultaat_traject = resultaat.loc[SWAN_Index]
            
            Hs  = resultaat_traject[select_kolommen[2]]
            Tp  = resultaat_traject[select_kolommen[3]]
            Tm  = resultaat_traject[select_kolommen[4]]
            dir = resultaat_traject[select_kolommen[5]]
            
            SWAN_Hs.append(Hs.tolist())
            SWAN_Tp.append(Tp.tolist())
            SWAN_Tm.append(Tm.tolist())
            SWAN_dir.append(dir.tolist())
            
    combinaties = pd.DataFrame(
        {'K': K, 'Q': Q, 'U': U, 'D': D, 'M': M})
     
    return combinaties, SWAN_Hs, SWAN_Tp, SWAN_Tm, SWAN_dir

#%%

def Lees_SWAN_Kao (SWAN_ID):
    """
    Lees SWAN-resultaten
    
    SWAN_ID = ID van de locatie in de SWAN-bestanden
    """
    select_kolommen = ['Xp', 'Yp', 'Hsig', 'TPsmoo', 'Tm_10', 'Dir']

    foldersSWAN = os.listdir(SWAN_dir_Kao)

    # Initieer combinaties    
    K = []
    H = []
    D = []
    U = []

    # Initialiseer lege lijsten met resultaten voor golfparameters
    SWAN_Hs = []
    SWAN_Tp = []
    SWAN_Tm = []
    SWAN_dir = []
    for SWAN_bestand in foldersSWAN:  
        # if float(SWAN_bestand[14:16]) == 16:
        #     break

        if (SWAN_bestand[1:3] == 'sr'): # sr = sluitregime
            K.append(1.0)
        else: # ao = altijd open
            K.append(2.0)
            
        if (SWAN_bestand[4:5] == 'n'): # n van negatief
            H.append(-1.0 * float(SWAN_bestand[5:8])/100)
        else:                          # p van positief
            H.append(float(SWAN_bestand[5:8])/100)
            
        U.append(float(SWAN_bestand[14:16]))
        D_SWAN = float(SWAN_bestand[17:20])
        if D_SWAN == 0.0:
            D_SWAN = 360.0
        D.append(D_SWAN)

        filepath = os.path.join(SWAN_dir_Kao,SWAN_bestand)
        # lees headerregel
        with open(filepath, 'r') as f:
            for line in f.readlines():
                if select_kolommen[0] in line:
                    header = line[1:].split()
                    break
        select_indices = [header.index(col) for col in select_kolommen]
        
        # lees file
        resultaat = pd.read_table(filepath, delim_whitespace=True, comment='%', header=None, 
                                  usecols=select_indices, names=select_kolommen)
        SWAN_Index = [ID-1 for ID in SWAN_ID]
        resultaat_traject = resultaat.loc[SWAN_Index]
        
        Hs  = resultaat_traject[select_kolommen[2]]
        Tp  = resultaat_traject[select_kolommen[3]]
        Tm  = resultaat_traject[select_kolommen[4]]
        dir = resultaat_traject[select_kolommen[5]]
        
        SWAN_Hs.append(Hs.tolist())
        SWAN_Tp.append(Tp.tolist())
        SWAN_Tm.append(Tm.tolist())
        SWAN_dir.append(dir.tolist())
            
    combinaties = pd.DataFrame(
        {'K': K, 'U': U, 'D': D, 'H': H})
     
    return combinaties, SWAN_Hs, SWAN_Tp, SWAN_Tm, SWAN_dir

#%%

def opslaan_golven(traject, golfparameter, oeverlocaties, combinaties, data, trajectfolder):
    
    Results = pd.concat([combinaties, pd.DataFrame(data = data, columns = oeverlocaties)], axis=1)
    
    print("Opslaan van dataframe als csv")
    
    # Sla de resultaten op
    header = Results.columns.tolist()
    data = Results.values
    
    savefolder = os.path.join(trajectfolder, "{}\SWAN_ruw_{}_{}.csv".format(traject, golfparameter, traject))

    with open(savefolder, "w", newline= "") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(data)    
        
#%%

trajectfolder = os.path.join('..', r'GIS_kaart\Normtrajectdata')
datafolder    = os.path.join('..', 'Hulpgegevens')
SWAN_dir_Ksr  = os.path.join('..', 'SWAN_Ksr')
SWAN_dir_Kao      = os.path.join('..', 'SWAN_Kao')
        
# In golven_overzicht zit informatie van alle locaties in de Vecht-IJsseldelta
golven_overzicht = pd.read_csv(os.path.join(datafolder, "Golven_overzicht.csv"))
golven_overzicht.index = golven_overzicht.pop('Name')

normtrajecten = ['7-1', '8-4', '9-2', '10-2', '10-3', '11-1', '11-2', '202', '225', '227']
    
for traject in normtrajecten:  
    # Uit onderstaande routine volgt een dataFrame met gegevens over de golven behorende bij de locaties
    # De golven uit SWAN kunnen er namelijk voor zorgen dat wordt overgestapt op de backup-locatie
    locaties_traject = info_locaties(trajectfolder, traject, golven_overzicht)

    print('SWAN-berekeningen verwerken met altijd open kering')
    combinaties, SWAN_Hs, SWAN_Tp, SWAN_Tm, SWAN_dir = Lees_SWAN_Kao(locaties_traject['SWAN_ID'])

    opslaan_golven(traject, 'Kao_Hs',  locaties_traject.index, combinaties, SWAN_Hs,  trajectfolder)
    opslaan_golven(traject, 'Kao_Tp',  locaties_traject.index, combinaties, SWAN_Tp,  trajectfolder)
    opslaan_golven(traject, 'Kao_Tm',  locaties_traject.index, combinaties, SWAN_Tm,  trajectfolder)
    opslaan_golven(traject, 'Kao_Dir', locaties_traject.index, combinaties, SWAN_dir, trajectfolder)


    if traject in ['8-4', '10-3', '11-1', '11-2', '225', '227']:
        print('SWAN-berekeningen verwerken met sluitregime')
        combinaties, SWAN_Hs, SWAN_Tp, SWAN_Tm, SWAN_dir = Lees_SWAN_Ksr(locaties_traject['SWAN_ID'])

        opslaan_golven(traject, 'Ksr_Hs',  locaties_traject.index, combinaties, SWAN_Hs,  trajectfolder)
        opslaan_golven(traject, 'Ksr_Tp',  locaties_traject.index, combinaties, SWAN_Tp,  trajectfolder)
        opslaan_golven(traject, 'Ksr_Tm',  locaties_traject.index, combinaties, SWAN_Tm,  trajectfolder)
        opslaan_golven(traject, 'Ksr_Dir', locaties_traject.index, combinaties, SWAN_dir, trajectfolder)
