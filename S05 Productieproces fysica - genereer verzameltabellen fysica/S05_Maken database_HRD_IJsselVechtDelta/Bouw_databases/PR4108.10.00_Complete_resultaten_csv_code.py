# -*- coding: utf-8 -*-
"""
Created on Tue Oct 29 10:06:26 2019

@author: hove
"""

import os
import pandas as pd
import numpy as np
import re
from tqdm import tqdm
import csv
import copy

#%%

# locaties invoerbestanden

datafolder = os.path.join('..', r'tables_csv_complete')
resultfolder = os.path.join('..', r'WAQUA_results')
trajectfolder = os.path.join('..', r'GIS_kaart\Normtrajectdata')
    
#%%

# Laden van dataframes met resultaten        
def laden_WAQUA_resultaten(resultfolder):
        
    results_max13 = pd.read_csv(os.path.join(resultfolder, "WAQUA_results_max13.csv"))
    results_last25 = pd.read_csv(os.path.join(resultfolder, "WAQUA_results_last25.csv"))
    results_maximum = pd.read_csv(os.path.join(resultfolder, "WAQUA_results_maximum.csv"))
    
    return results_max13, results_last25, results_maximum

#%%

# Waterstand resultaten voor een bepaald traject
def waterstand_resultaten(traject, results_max13, results_last25, results_maximum, lim=0.1):

    # Laden van bestand met koppeling locaties
    file = os.path.join(trajectfolder, "{}\Database_{}.xlsx".format(traject, traject))
    locaties = pd.read_excel(file)     
    locaties.index = locaties.pop('Name')
    print('Traject {} bevat {} locaties'.format(traject, len(locaties)))
    
    # Lijst van oeverlocaties, backuplocaties en aslocaties
    oeverlocaties = locaties.index.tolist()
    backuplocaties = locaties.naam_backup.tolist()
    aslocaties = locaties.naam_as.tolist()
    
    # Voorbereiden van dataframes
    oever_max13 = results_max13[oeverlocaties]
    oever_last25 = results_last25[oeverlocaties]
    oever_maximum = results_maximum[oeverlocaties]
    
    backup_max13 = results_max13[backuplocaties]
    backup_last25 = results_last25[backuplocaties]
    backup_maximum = results_maximum[backuplocaties]
    
    as_max13 = results_max13[aslocaties]
    as_last25 = results_last25[aslocaties]
    as_maximum = results_maximum[aslocaties]
    
    # Lijst met True als (Q <= 2300 & U == 0) voor de verschillende combinaties, anders False
    U = results_max13['U'].values
    Q = results_max13['Q'].values
    crit = [True if (Q[i] <= 2300) and (U[i] == 0) else False for i in range(len(U))]
    
    # Initialiseer lege lijst met resultaten voor waterstanden
    results_H = []
    results_code = []
    
    # Lus over de verschillende combinaties
    for i in tqdm(range(len(results_max13))):
        
        # Optie 1: oeverlocaties
        max13 = oever_max13.iloc[i].values
        last25 = oever_last25.iloc[i].values
        maximum = oever_maximum.iloc[i].values
        val = [True if (np.sqrt((maximum[i]-last25[i])**2)<lim) else False for i in range(len(max13))]
        
        # Als (Q <= 2300 & U == 0), gebruik dan last25
        if crit[i] == True:
            H = last25     
            code = [2 for i in range(len(last25))]                       
        else:
            # Als max13 is NaN, vervang door last25 als absolute verschil tussen maximum en last25 < lim
            H = [last25[i] if (np.isnan(max13[i])) and (val[i]==True) else max13[i] for i in range(len(max13))]
            code = [2 if (np.isnan(max13[i])) and (val[i]==True) else 1 for i in range(len(max13))]            
    
        if np.isnan(H).any() is False:
            results_H.append(H)
            continue
        else:
            # Optie 2: backuplocaties
            max13 = backup_max13.iloc[i].values
            last25 = backup_last25.iloc[i].values
            maximum = backup_maximum.iloc[i].values
            val = [True if (np.sqrt((maximum[i]-last25[i])**2)<lim) else False for i in range(len(max13))]
            
            if crit[i] == False:
                code = [3 if (np.isnan(H[i])) else code[i] for i in range(len(H))]
                H = [max13[i] if (np.isnan(H[i])) else H[i] for i in range(len(H))]
            code = [4 if (np.isnan(H[i])) and (val[i]==True) else code[i] for i in range(len(H))]
            H = [last25[i] if (np.isnan(H[i])) and (val[i]==True) else H[i] for i in range(len(H))]
            
            
            if np.isnan(H).any() is False:
                results_H.append(H)
                continue
            else:
                # Optie 3: aslocaties
                max13 = as_max13.iloc[i].values
                last25 = as_last25.iloc[i].values
                maximum = as_maximum.iloc[i].values
                val = [True if (np.sqrt((maximum[i]-last25[i])**2)<lim) else False for i in range(len(max13))]
                
                if crit[i] == False:
                    code = [5 if (np.isnan(H[i])) else code[i] for i in range(len(H))]
                    H = [max13[i] if (np.isnan(H[i])) else H[i] for i in range(len(H))]
                code = [6 if (np.isnan(H[i])) and (val[i]==True) else code[i] for i in range(len(H))]    
                H = [last25[i] if (np.isnan(H[i])) and (val[i]==True) else H[i] for i in range(len(H))]
                
                code = [0 if np.isnan(H[i]) else code[i] for i in range(len(H))]
                
                results_H.append(H)
                results_code.append(code)
                
    return oeverlocaties, results_H, results_code

#%%

# Waterstand resultaten voor een bepaald traject waarbij alleen as locaties worden gebruikt
def waterstand_resultaten_as(traject, results_max13, results_last25, results_maximum, lim=0.1):

    # Laden van bestand met koppeling locaties
    file = os.path.join(trajectfolder, "{}\Database_{}.xlsx".format(traject, traject))
    locaties = pd.read_excel(file)     
    locaties.index = locaties.pop('Name')
    print('Traject {} bevat {} locaties'.format(traject, len(locaties)))
    
    # Lijst van oeverlocaties en aslocaties
    oeverlocaties = locaties.index.tolist()
    aslocaties = locaties.naam_as.tolist()
    
    # Voorbereiden van dataframes
    as_max13 = results_max13[aslocaties]
    as_last25 = results_last25[aslocaties]
    as_maximum = results_maximum[aslocaties]
    
    # Lijst met True als (Q <= 2300 & U == 0) voor de verschillende combinaties, anders False
    U = results_max13['U'].values
    Q = results_max13['Q'].values
    crit = [True if (Q[i] <= 2300) and (U[i] == 0) else False for i in range(len(U))]
    
    # Initialiseer lege lijst met resultaten voor waterstanden
    results_H = []
    results_code = []
    
    # Lus over de verschillende combinaties
    for i in tqdm(range(len(results_max13))):
        
        max13 = as_max13.iloc[i].values
        last25 = as_last25.iloc[i].values
        maximum = as_maximum.iloc[i].values
        val = [True if (np.sqrt((maximum[i]-last25[i])**2)<lim) else False for i in range(len(max13))]
                
        if crit[i] == True:
            H = last25 
            code = [6 for i in range(len(last25))]  
        else:
            H = [last25[i] if (np.isnan(max13[i])) and (val[i]==True) else max13[i] for i in range(len(max13))]
            code = [6 if (np.isnan(max13[i])) and (val[i]==True) else 5 for i in range(len(max13))]   
            
        code = [0 if np.isnan(H[i]) else code[i] for i in range(len(H))]
                
        results_H.append(H)
        results_code.append(code)
                
    return oeverlocaties, results_H, results_code

#%%
    
# Waterstand resultaten voor een bepaald traject
def waterstand_resultaten_knip(traject, results_max13, results_last25, results_maximum, lim=0.1):

    # Laden van bestand met koppeling locaties
    file = os.path.join(trajectfolder, "{}\Database_{}.xlsx".format(traject, traject))
    locaties = pd.read_excel(file)     
    locaties.index = locaties.pop('Name')
    print('Traject {} bevat {} locaties'.format(traject, len(locaties)))
    
    # Lijst van oeverlocaties, backuplocaties en aslocaties
    oeverlocaties = locaties.index.tolist()
    backuplocaties = locaties.naam_backup.tolist()
    aslocaties = locaties.naam_as.tolist()
    
    # Voorbereiden van dataframes
    oever_max13 = results_max13[oeverlocaties]
    oever_last25 = results_last25[oeverlocaties]
    oever_maximum = results_maximum[oeverlocaties]
    
    backup_max13 = results_max13[backuplocaties]
    backup_last25 = results_last25[backuplocaties]
    backup_maximum = results_maximum[backuplocaties]
    
    as_max13 = results_max13[aslocaties]
    as_last25 = results_last25[aslocaties]
    as_maximum = results_maximum[aslocaties]
    
    # Lijst met True als (Q <= 2300 & U == 0) voor de verschillende combinaties, anders False
    U = results_max13['U'].values
    Q = results_max13['Q'].values
    knip = [True if (Q[i] <= 2300) else False for i in range(len(U))]
    crit = [True if (Q[i] <= 2300) and (U[i] == 0) else False for i in range(len(U))]
    
    # Initialiseer lege lijst met resultaten voor waterstanden
    results_H = []
    results_code = []
    
    # Lus over de verschillende combinaties
    for i in tqdm(range(len(results_max13))):
        
        if knip[i] == True:
            max13 = as_max13.iloc[i].values
            last25 = as_last25.iloc[i].values
            maximum = as_maximum.iloc[i].values
            val = [True if (np.sqrt((maximum[i]-last25[i])**2)<lim) else False for i in range(len(max13))]
            
            if crit[i] == True:
                H = last25              
                code = [6 for i in range(len(last25))]  
            else:
                # Als max13 is NaN, vervang door last25 als absolute verschil tussen maximum en last25 < lim
                H = [last25[i] if (np.isnan(max13[i])) and (val[i]==True) else max13[i] for i in range(len(max13))]
                code = [6 if (np.isnan(max13[i])) and (val[i]==True) else 5 for i in range(len(max13))]   
            
        else:
            # Optie 1: oeverlocaties
            max13 = oever_max13.iloc[i].values
            last25 = oever_last25.iloc[i].values
            maximum = oever_maximum.iloc[i].values
            val = [True if (np.sqrt((maximum[i]-last25[i])**2)<lim) else False for i in range(len(max13))]
        
            # Als max13 is NaN, vervang door last25 als absolute verschil tussen maximum en last25 < lim
            H = [last25[i] if (np.isnan(max13[i])) and (val[i]==True) else max13[i] for i in range(len(max13))]
            code = [2 if (np.isnan(max13[i])) and (val[i]==True) else 1 for i in range(len(max13))]  
    
            if np.isnan(H).any() is False:
                results_H.append(H)
                continue
            else:
                # Optie 2: backuplocaties
                max13 = backup_max13.iloc[i].values
                last25 = backup_last25.iloc[i].values
                maximum = backup_maximum.iloc[i].values
                val = [True if (np.sqrt((maximum[i]-last25[i])**2)<lim) else False for i in range(len(max13))]
            
                code = [3 if (np.isnan(H[i])) else code[i] for i in range(len(H))]
                H = [max13[i] if (np.isnan(H[i])) else H[i] for i in range(len(H))]
                code = [4 if (np.isnan(H[i])) and (val[i]==True) else code[i] for i in range(len(H))]   
                H = [last25[i] if (np.isnan(H[i])) and (val[i]==True) else H[i] for i in range(len(H))]
            
                if np.isnan(H).any() is False:
                    results_H.append(H)
                    continue
                else:
                    # Optie 3: aslocaties
                    max13 = as_max13.iloc[i].values
                    last25 = as_last25.iloc[i].values
                    maximum = as_maximum.iloc[i].values
                    val = [True if (np.sqrt((maximum[i]-last25[i])**2)<lim) else False for i in range(len(max13))]
                
                    code = [5 if (np.isnan(H[i])) else code[i] for i in range(len(H))]
                    H = [max13[i] if (np.isnan(H[i])) else H[i] for i in range(len(H))]
                    code = [6 if (np.isnan(H[i])) and (val[i]==True) else code[i] for i in range(len(H))]   
                    H = [last25[i] if (np.isnan(H[i])) and (val[i]==True) else H[i] for i in range(len(H))]
         
        code = [0 if np.isnan(H[i]) else code[i] for i in range(len(H))]
            
        results_H.append(H)
        results_code.append(code)
                
    return oeverlocaties, results_H, results_code
            
#%%

def windrichtingen(Results):
    
    # Doorkopiëren van windrichtingen voor U=0 (in dataframe)
    print("Doorkopieren van windrichtingen voor U=0")  
    
    tmp1 = Results.loc[Results['U']!=0]
    U0 = Results.loc[Results['U']==0]
    for D in np.unique(Results['D'].tolist()):
        if D == 360:
            tmp = U0.copy()
        else:
            tmp = U0.copy()
            tmp['D'] = float(D)
        tmp1 = pd.concat([tmp1, tmp])
    Results = tmp1.copy()
    del tmp, tmp1, D, U0
    
    # Doorkopiëren van U=0 van D360 naar alle oostelijk windrichtingen voor alle U (in dataframe)
    print("Doorkopieren van oostelijke windrichtingen")
    
    tmp1 = Results.copy()
    U0D360 = Results.loc[(Results['U']==0) & (Results['D']==292)].copy()
    for D in [22, 45, 67, 90, 112, 135, 157, 180, 202]:
        for U in np.unique(Results['U']):
            tmp = U0D360.copy()
            tmp['D'] = float(D)
            tmp['U'] = float(U)
            tmp1 = pd.concat([tmp1,tmp])
    Results = tmp1.copy()
    del tmp, tmp1, U0D360, D, U

    # Zet de index weer netjes
    Results.set_index(np.arange(0,len(Results)), inplace=True, drop=True) 

    return Results       
        
#%%

"""
Deze functie filtert de waterstanden:
    - Pieken 
        - van één datapunt waarbij het punt links EN rechts meer dan opgegeven aantal cm lager liggen (input parameter 'lim')
    - Bakjes 
        - waarbij het verschil tussen twee datapunten aan de linkerzijde EN rechterzijde van het bakje meer is dan opgegeven aantal cm (input parameter 'lim')
        - de lengte van het bakje niet meer is dan aantal opgegeven datapunten (input parameter 'max_length')
    - Bakjes aan de rand van het traject 
        - waarbij het verschil tussen twee datapunten aan de linkerzijde (onderrand traject) OF rechterzijde (bovenrand traject) van het bakje meer is dan opgegeven aantal cm (input parameter 'lim')
        - de lengte van het bakje niet meer is dan aantal opgegeven datapunten (input parameter 'max_length_edge')
"""

# Filteren van uitschieters/bakjes
def filter_waterstanden(data_ruw, code_ruw, lim=0.1, max_length=10, max_length_edge=10):

    data = data_ruw.copy()
    code = code_ruw.copy()
    
    results_H_filtered = []
    results_code_filtered = []    
    
    for i in range(len(data)):
        
        H = data[i]
        c = code[i]
        
        # Gradienten
        left_gradient = [H[j+1]-H[j] for j in range(len(H)-1)] + [np.NaN]
        right_gradient = [np.NaN] + [H[j]-H[j-1] for j in range(1, len(H))]
        
        # True/False voor gradienten (groter dan limiet)
        left = [True if (left_gradient[j]<(-1*lim)) else False for j in range(len(left_gradient)-1)] + [np.NaN]
        right = [np.NaN] + [True if (right_gradient[j])>lim else False for j in range(1, len(right_gradient))]
        
        # Verwijderen van half bakje aan bovenzijde normtraject
        left_bc = [i for i in range(max_length_edge+1) if left[i]==True]
        right_bc = [i for i in range(max_length_edge+1) if right[i]==True]        
        if (len(right_bc)!=0) and (len(left_bc)!=0):
            for bc in reversed(right_bc):
                if bc<=left_bc[0]:
#                    print('half bakje boven - row {} - left {} - right {}'.format(i, left_bc[0], bc))
                    H[:bc] = np.full(bc, np.NaN).tolist()
                    break
        elif (len(right_bc)!=0) and (len(left_bc)==0):
#            print('half bakje boven - row {}'.format(i))
            bc = right_bc[-1]
            H[:bc] = np.full(bc, np.NaN).tolist()
        del left_bc, right_bc
            
        # Verwijderen van half bakje aan benedenzijde normtraject
        left_bc = [i for i in range(len(left)-max_length_edge, len(left)) if left[i]==True]
        right_bc = [i for i in range(len(right)-max_length_edge, len(right)) if right[i]==True]        
        if (len(right_bc)!=0) and (len(left_bc)!=0):
            for bc in left_bc:
                if bc>=right_bc[-1]:
#                    print('half bakje beneden - row {} - left {} - right {}'.format(i, bc, right_bc[-1]))
                    H[bc:] = np.full((len(left) - bc), np.NaN).tolist() 
                    break
        elif (len(right_bc)==0) and (len(left_bc)!=0):
#            print('half bakje beneden - row {}'.format(i))
            bc = left_bc[0]
            H[bc:] = np.full((len(left) - bc), np.NaN).tolist()
        del left_bc, right_bc
        
        # Pak bij linker en rechterzijdes waarbij de gradient door verschillende locaties loopt dan de buitenste
        left = [left[0]] + [True if (left[j]==True) and (left[j-1]==False) else False for j in range(1, len(left)-1)] + [np.NaN]
        right = [np.NaN] + [True if (right[j]==True) and (right[j+1]==False) else False for j in range(1, len(right)-1)] + [right[-1]]  
                
        # Lus door de lijst van linkerzijdes
        for k in range(len(left)):
            if left[k] == True:
                left_boundary = k
#                print('left to right - row {} - left boundary {}'.format(i, left_boundary))
                # Lus door de lijst van rechterzijdes voor range tussen positie linkerzijde en linkerzijde + max_length
                for l in range(k, min(k+max_length+1, len(right))):
                    if right[l] == True:
                        right_boundary = l
#                        print('left to right - row {} - right boundary {}'.format(i, right_boundary))
                        # Lokale pieken in waterstand (left_boundary == right_boundary) worden vervangen door NaN
                        if left_boundary == right_boundary:
                            H[left_boundary] = np.NaN
                        else:
                            # Vervang de waterstanden voor NaN voor de range TUSSEN linkerzijde en rechterzijde
                            H[left_boundary+1:right_boundary] = np.full((right_boundary-left_boundary-1), np.NaN).tolist()
                            break
                        
        # Lus door de lijst van rechterzijdes
        for l in range(len(right)-1, -1, -1):
            if right[l] == True:
                right_boundary = l
#                print('right to left - row {} - right boundary {}'.format(i, right_boundary))
                for k in range(l, max(-1, l-max_length-1), -1):
                    if left[k] == True:
                        left_boundary = k
#                        print('right to left - row {} - left boundary {}'.format(i, left_boundary))
                        if left_boundary == right_boundary:
                            continue
                        else:
                            H[left_boundary+1:right_boundary] = np.full((right_boundary-left_boundary-1), np.NaN).tolist()
                            break
                        
        c = [0 if np.isnan(H[j]) else c[j] for j in range(len(H))]
        
        results_H_filtered.append(H)
        results_code_filtered.append(c)
        
        del H, left, right, c
        
    return results_H_filtered, results_code_filtered     

#%%
    
# Interpoleren van waterstanden, vullen van gaten met maximaal aanntal aanliggende locaties 'lim'
def interpoleren_waterstanden(data_filter, code_filter, lim=200):
    
    data = data_filter.copy()
    code = code_filter.copy()
    
    results_H_interp = []
    results_code_interp = []
    
    for i in range(len(data)):
        
        H_data = data[i]
        H = pd.Series(data[i])
        H_interp = H.interpolate(method='linear', limit=lim, limit_direction='both')
        H_interp = H_interp.tolist()
        
        code_tmp = code[i]
        code_tmp = [7 if (H_interp[j] != H_data[j]) else code_tmp[j] for j in range(len(code_tmp))]
        
        results_H_interp.append(H.tolist())
        results_code_interp.append(code_tmp)
    
    return results_H_interp, results_code_interp
    
#%%

results_max13, results_last25, results_maximum = laden_WAQUA_resultaten(resultfolder)
combinaties = results_max13[['K','Q','U','D','M']]

trajecten_filter = ['8-4', '9-1', '9-2', '10-1', '10-3', '11-1', '11-2', '52-4', '53-2', '53-3', '225']
len_filter = [5, 15, 15, 20, 20, 25, 15, 10, 20, 15, 20]
dict_len = dict(zip(trajecten_filter, len_filter))

normtrajecten = ['7-1', '8-4', '9-1', '9-2', '10-1', '10-2', '10-3', '11-1', '11-2', '52a-1', '52-3', '52-4',  '53-2', '53-3', '202', '206', '225', '227']
for traject in normtrajecten:  
    # trajecten die as locaties gebruiken (in rapport: methode B)             
    if (traject == '10-2'):
        oeverlocaties, results_H, results_code = waterstand_resultaten_as(traject, results_max13, results_last25, results_maximum, lim=0.1)
    # trajecten met een knip (in rapport: methode C)
    elif (traject == '52a-1') or (traject == '52-3'):
        oeverlocaties, results_H, results_code = waterstand_resultaten_knip(traject, results_max13, results_last25, results_maximum, lim=0.1)
    # overige trajecten (in rapport: methode A)
    else: 
        oeverlocaties, results_H, results_code = waterstand_resultaten(traject, results_max13, results_last25, results_maximum, lim=0.1)
    
    print('Aantal oeverlocaties: {}'.format(len(oeverlocaties)))

    # één locatie: bestanden niet filteren of interpoleren. Dezelfde data wordt opgeslagen als filtered
    if len(results_H[0]) == 1:
        results_code_interp = results_code.copy()
    else:
        if traject in trajecten_filter:
            # waterstanden filteren
            results_H_filtered, results_code_filtered = filter_waterstanden(data_ruw=results_H.copy(), code_ruw=results_code.copy(), lim=0.1, max_length=dict_len[traject], max_length_edge=10)
            # waterstanden interpoleren
            results_H_interp, results_code_interp = interpoleren_waterstanden(data_filter=results_H_filtered.copy(), code_filter=results_code_filtered.copy(), lim=200)
        else:
            # waterstanden interpoleren
            results_H_interp, results_code_interp = interpoleren_waterstanden(data_filter=results_H.copy(), code_filter=results_code.copy(), lim=200)
    
    Results_base = pd.concat([combinaties, pd.DataFrame(data = results_code_interp, columns = oeverlocaties)], axis=1)
    
    # Doorkopieren van windrichtingen (gebruik functie)
    Results = windrichtingen(Results_base)

    print("Opslaan van dataframe als csv")
    
    # Sla de resultaten op
    header = Results.columns.tolist()
    data = Results.values
    
    savefolder = os.path.join(trajectfolder, "{}\Waterlevels_Database_Code_{}.csv".format(traject, traject))

    with open(savefolder, "w", newline= "") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(data)    
    
