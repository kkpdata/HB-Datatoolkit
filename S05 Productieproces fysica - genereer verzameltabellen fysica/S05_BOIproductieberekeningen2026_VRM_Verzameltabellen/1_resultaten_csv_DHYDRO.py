# -*- coding: utf-8 -*-
"""
Created on  : 11-01-2022
Author      : Cees Oerlemans
Project     : PR4539.10 BOI Meren
Description : Gebaseerd op script van A. Hove en Roy Daggenvoorde voor PR4108.10 Vullen databases VIJD.
              Stroomschema voor filtering is aangepast voor betere resultaten van meersystemen.

Aanpassingen voor PR 5514, door Lieke Lokin (LL)
15-01-2026: aanpassen paden
"""

import os
from pathlib import Path # LL toevoegen Path om de parent directory te vinden
import pandas as pd
import numpy as np
import re
from tqdm import tqdm
import csv
import copy


#statdata omschrijven naar csv bestanden last25, maximum, max13 en nanmax
def DHYDRO_resultaten(datafolder, resultfolder):

    print("Laden van DHYDRO resultaten")

    # Lijst met bestandsnamen van DHYDRO resultaten
    simnames = os.listdir(datafolder)

    # Haal een lijst met bedlevels en locatienamen uit het eerste databestand
    data = pd.read_csv(os.path.join(datafolder, simnames[0]), sep=';', index_col=0, usecols=['stationid', 'bedlevel'])
    bedlevel = data.bedlevel.tolist()

    # Initialiseer lege lijsten
    results_max13 = []
    results_rolmean_max13 = []
    results_first = []
    results_last25 = []
    results_maximum = []
    results_minimum = []
    results_NANMAX = []

    # Lus door de bestanden met DHYDRO resultaten
    for ix, sim in enumerate(tqdm(simnames)):

        # get somid
        somid=sim.split('_')[-1]
        somid=somid.split('.')[0]

        # laad station data
        stationdata = pd.read_csv(os.path.join(datafolder, 'statdata_{}.csv'.format(somid)),sep=';')
        stationdata.rename({'index_left':'Name'},inplace = True,axis=1)
        stationdata.reset_index()
        stationdata.set_index('Name', inplace=True)

        locations = stationdata.index.tolist()

        # Haal uit de bestandsnaam de combinatie voor M: meerpeil, U: windsnelheid, D: windrichting
        [(M, U, D)] = re.findall('M(.+)U(.+)D(.+).csv', sim)

        #vervang stochasten door juiste meerpeilen en niet-afgeronde windrichtingen
        M = M.replace('p2','2.').replace('p0','0.').replace('p1','1.').replace('m0','-0.')
        D = D.replace('23', '22.5').replace('45', '45.0').replace('68', '67.5').replace('90', '90.0').replace('113', '112.5').replace('135', '135.0').replace('158', '157.5').replace('180', '180.0').replace('203', '202.5').replace('225', '225.0').replace('248', '247.5').replace('270', '270.0').replace('293', '292.5').replace('305', '305.0').replace('338', '337.5').replace('360', '360.0')

        # Dataframe met DHYDRO resultaten
        #data = pd.read_csv(os.path.join(datafolder, sim), sep=';', index_col=0, usecols=['stationid', 'NANMAX', 'max13', 'last25', 'maximum'])

        # Lijst waterstand gemiddelde over 13 maximum waardes
        max13 = stationdata['max13'].tolist()
        results_max13.append([float(U), float(D), float(M)] + max13)

        # Lijst waterstand met maximum lopend gemiddelde
        rolmean_max13 = stationdata['rolmean_max13'].tolist()
        results_rolmean_max13.append([float(U), float(D), float(M)] + rolmean_max13)

        # Lijst eerste waterstand uit reeks
        first = stationdata['first'].tolist()
        results_first.append([float(U), float(D), float(M)] + first)

        # Lijst waterstand gemiddelde over 25 laatste waardes in tijdreeks
        last25 = stationdata['last25'].tolist()
        results_last25.append([float(U), float(D), float(M)] + last25)

        # Lijst maximum waterstand
        maximum = stationdata['maximum'].tolist()
        results_maximum.append([float(U), float(D), float(M)] + maximum)

        # Lijst minimum waterstand
        minimum = stationdata['minimum'].tolist()
        results_minimum.append([float(U), float(D), float(M)] + minimum)

        # Lijst met NANMAX codes
        NANMAX = stationdata['NANMAX'].tolist()
        results_NANMAX.append([float(U), float(D), float(M)] + NANMAX)

    # Opslaan van resultaten
    print("Opslaan van DHYDRO resultaten in csv")

    savedir = os.path.join(resultfolder, "Brondata")
    if not os.path.exists(savedir):
        os.makedirs(savedir)

    # Schrijf database weg per Meer
    with open(os.path.join(resultfolder, "Brondata", "DHYDRO_results_max13.csv"), "w", newline= "") as f:
        writer = csv.writer(f)
        writer.writerow(['U','D','M'] + locations)
        writer.writerows(results_max13)

    with open(os.path.join(resultfolder, "Brondata", "DHYDRO_results_rolmean_max13.csv"), "w", newline= "") as f:
        writer = csv.writer(f)
        writer.writerow(['U','D','M'] + locations)
        writer.writerows(results_rolmean_max13)

    with open(os.path.join(resultfolder, "Brondata", "DHYDRO_results_first.csv"), "w", newline= "") as f:
        writer = csv.writer(f)
        writer.writerow(['U','D','M'] + locations)
        writer.writerows(results_first)

    with open(os.path.join(resultfolder, "Brondata", "DHYDRO_results_last25.csv"), "w", newline= "") as f:
        writer = csv.writer(f)
        writer.writerow(['U','D','M'] + locations)
        writer.writerows(results_last25)

    with open(os.path.join(resultfolder, "Brondata", "DHYDRO_results_maximum.csv"), "w", newline= "") as f:
        writer = csv.writer(f)
        writer.writerow(['U','D','M'] + locations)
        writer.writerows(results_maximum)

    with open(os.path.join(resultfolder, "Brondata", "DHYDRO_results_minimum.csv"), "w", newline= "") as f:
        writer = csv.writer(f)
        writer.writerow(['U','D','M'] + locations)
        writer.writerows(results_minimum)

    with open(os.path.join(resultfolder, "Brondata", "DHYDRO_results_NANMAX.csv"), "w", newline= "") as f:
        writer = csv.writer(f)
        writer.writerow(['U','D','M'] + locations)
        writer.writerows(results_NANMAX)


# Laden van dataframes met Brondata
def laden_DHYDRO_resultaten(resultfolder):
    results_max13 = pd.read_csv(os.path.join(resultfolder, "Brondata", "DHYDRO_results_max13.csv"))
    results_rolmean_max13 = pd.read_csv(os.path.join(resultfolder, "Brondata", "DHYDRO_results_rolmean_max13.csv"))
    results_first = pd.read_csv(os.path.join(resultfolder, "Brondata","DHYDRO_results_first.csv"))
    results_last25 = pd.read_csv(os.path.join(resultfolder, "Brondata","DHYDRO_results_last25.csv"))
    results_maximum = pd.read_csv(os.path.join(resultfolder, "Brondata","DHYDRO_results_maximum.csv"))
    results_minimum = pd.read_csv(os.path.join(resultfolder, "Brondata","DHYDRO_results_minimum.csv"))

    return results_max13, results_rolmean_max13, results_first, results_last25, results_maximum, results_minimum


# Waterstand resultaten voor een bepaald traject
def waterstand_resultaten(traject, results_max13, results_first, results_last25, results_maximum, results_minimum, lim_droogval=0.1, lim_opwaaiing=0.1, lim_afwaaiing=0.1):
    # Laden van locaties per traject
    locaties_meer = koptab
    locaties = locaties_meer.loc[locaties_meer['normtraject'] == traject]
    print('Traject {} bevat {} locaties'.format(traject, len(locaties)))

    # Lijst van basislocaties, backuplocaties en terugvallocaties
    basislocaties = locaties.Name.tolist()
    backuplocaties = locaties.naam_backup.tolist()
    terugvallocaties = locaties.naam_as.tolist()

    # Voorbereiden van dataframes
    basis_max13 = results_max13[basislocaties]
    basis_first = results_first[basislocaties]
    basis_last25 = results_last25[basislocaties]
    basis_maximum = results_maximum[basislocaties]
    basis_minimum = results_minimum[basislocaties]

    backup_max13 = results_max13[backuplocaties]
    backup_first = results_first[backuplocaties]
    backup_last25 = results_last25[backuplocaties]
    backup_maximum = results_maximum[backuplocaties]
    backup_minimum = results_minimum[backuplocaties]

    terugval_max13 = results_max13[terugvallocaties]
    bedlevel_basis = locaties['bedlevel'].to_list()

    #Lijst met True als U == 0 voor de verschillende combinaties, anders False
    # Lijst met True als (Q <= 2300 & U == 0) voor de verschillende combinaties, anders False
    U = results_max13['U'].values
    crit = [True if (U[i] == 0) else False for i in range(len(U))]

    # Initialiseer lege lijst met resultaten voor waterstanden en codering
    results_H = []
    results_code = []

    # Lus over de verschillende combinaties
    for i in tqdm(range(len(results_max13))):
        # Basisdata per belastingcombinatie
        basis_max13_val = basis_max13.iloc[i].values
        basis_first_val = basis_first.iloc[i].values
        basis_last25_val = basis_last25.iloc[i].values
        basis_maximum_val = basis_maximum.iloc[i].values
        basis_minimum_val = basis_minimum.iloc[i].values

        # Backupdata per belastingcombinatie
        backup_max13_val = backup_max13.iloc[i].values
        backup_first_val = backup_first.iloc[i].values
        backup_last25_val = backup_last25.iloc[i].values
        backup_maximum_val = backup_maximum.iloc[i].values
        backup_minimum_val = backup_minimum.iloc[i].values

        # Terugvaldata per belastingcombinatie
        terugval_max13_val = terugval_max13.iloc[i].values

        #droogval, opwaaiing, afwaaiing checks, csv wegschrijven voor check
        basis_droogval = [True if abs(basis_maximum_val[i] - basis_first_val[i]) <= lim_droogval and abs(basis_last25_val[i] - basis_maximum_val[i]) <= lim_droogval else False for i in range(len(basis_max13_val))]
        basis_opwaaiing = [True if abs(basis_max13_val[i] - basis_first_val[i]) >= lim_opwaaiing or abs(basis_max13_val[i] - basis_last25_val[i]) >= lim_opwaaiing else False for i in range(len(basis_max13_val))]
        basis_afwaaiing = [True if abs(basis_minimum_val[i] - basis_first_val[i]) >= lim_afwaaiing or abs(basis_minimum_val[i] - basis_last25_val[i]) >= lim_afwaaiing else False for i in range(len(basis_max13_val))]

        backup_droogval = [True if abs(backup_maximum_val[i]-backup_first_val[i]) <= lim_droogval and abs(backup_last25_val[i] - backup_maximum_val[i]) <= lim_droogval else False for i in range(len(backup_max13_val))]
        backup_opwaaiing = [True if abs(backup_max13_val[i] - backup_first_val[i]) >= lim_opwaaiing or abs(backup_max13_val[i] - backup_last25_val[i]) >= lim_opwaaiing else False for i in range(len(backup_max13_val))]
        backup_afwaaiing = [True if abs(backup_minimum_val[i] - backup_first_val[i]) >= lim_afwaaiing or abs(backup_minimum_val[i] - backup_last25_val[i]) >= lim_afwaaiing else False for i in range(len(backup_max13_val))]

        """Selecteer juiste waterstand voor oeverlocatie op basis van droogval, opwaaiing en afwaaiing checks voor basis/backup/terugval locaties"""

        results_H_tmp = []
        results_code_tmp = []

        # Lus over alle basislocaties in traject
        for j in range(len(basis_max13_val)):
            
            # Voor combinaties U == 0 m/s en initieel meerpeil hoger dan bodemhoogte
            if (crit[i] == True) and (basis_first_val[j] > (bedlevel_basis[j]+0.001)):
                results_code_tmp.append(21)
                results_H_tmp.append(basis_max13_val[j])
                continue
                
            # Optie 1: basislocaties
            if basis_droogval[j] == False and basis_opwaaiing[j] == True:
                results_code_tmp.append(10)
                results_H_tmp.append(basis_max13_val[j])
                continue
            if basis_droogval[j] == False and basis_opwaaiing[j] == False and basis_afwaaiing[j] == True:
                results_code_tmp.append(20)
                results_H_tmp.append(basis_first_val[j])
                continue

            # Optie 2: backuplocaties
            if backup_droogval[j] == False and backup_opwaaiing[j] == True:
                #Check of wordt teruggevallen terwijl locaties basis nat is
                if basis_max13_val[j] - bedlevel_basis[j] > lim_droogval:
                    results_code_tmp.append(32)
                    results_H_tmp.append(backup_max13_val[j])
                    continue
                #Selecteer min(backup, bodemhoogte basis)
                if backup_max13_val[j] <= bedlevel_basis[j]:
                    results_code_tmp.append(30)
                    results_H_tmp.append(backup_max13_val[j])
                else:
                    results_code_tmp.append(31)
                    results_H_tmp.append(bedlevel_basis[j])
                continue
                
            if backup_droogval[j] == False and backup_opwaaiing[j] == False and backup_afwaaiing[j] == True:
                #Check of wordt teruggevallen terwijl basislocatie nat is
                if basis_max13_val[j] - bedlevel_basis[j] > lim_droogval:
                    results_code_tmp.append(42)
                    results_H_tmp.append(backup_first_val[j])
                    continue
                #Selecteer min(backup, bodemhoogte basis)
                if backup_first_val[j] <= bedlevel_basis[j]:
                    results_code_tmp.append(40)
                    results_H_tmp.append(backup_first_val[j])
                else:
                    results_code_tmp.append(41)
                    results_H_tmp.append(bedlevel_basis[j])
                continue

            # Optie 3: terugvallocaties
            else:
                #Check of wordt teruggevallen terwijl locaties basis nat is
                if basis_max13_val[j] - bedlevel_basis[j] > lim_droogval:
                    results_code_tmp.append(52)
                    results_H_tmp.append(terugval_max13_val[j])
                    continue
                #Selecteer min(terugval, bodemhoogte basis)
                if terugval_max13_val[j] <= bedlevel_basis[j]:
                    results_code_tmp.append(50)
                    results_H_tmp.append(terugval_max13_val[j])
                else:
                    results_code_tmp.append(51)
                    results_H_tmp.append(bedlevel_basis[j])

        results_H.append([round(num, 3) for num in results_H_tmp])
        results_code.append(results_code_tmp)

    return basislocaties, results_H, results_code

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

    Results.set_index(np.arange(0,len(Results)), inplace=True, drop=True)

    return Results


def opslaan_waterstanden(traject, basislocaties, combinaties, data, trajectfolder, lim_grad=0, max_length=0, filtered=False):
    Results = pd.concat([combinaties, pd.DataFrame(data = data, columns = basislocaties)], axis=1)

    # # Doorkopieren van windrichtingen (gebruik functie)
    # Results = windrichtingen(Results_base)

    print("Opslaan van dataframe als csv")

    # Sla de resultaten op
    # header = Results.columns.tolist()
    # data = Results.values

    savedir = os.path.join(trajectfolder, traject)

    if not os.path.exists(savedir):
        os.makedirs(savedir)

    if filtered == True:
        savefolder = os.path.join(trajectfolder, "{}/Waterlevels_Database_grad{}_bakje{}_Filtered_{}.csv".format(traject, lim_grad, max_length, traject))
    else:
        savefolder = os.path.join(trajectfolder, "{}/Waterlevels_Database_{}.csv".format(traject, traject))
    
    Results.to_csv(savefolder, index=False)

    # with open(savefolder, "w", newline= "") as f:
    #     writer = csv.writer(f)
    #     writer.writerow(header)
    #     writer.writerows(data)


def opslaan_classificatie(traject, basislocaties, combinaties, data, trajectfolder):
    Results = pd.concat([combinaties, pd.DataFrame(data = data, columns = basislocaties)], axis=1)

    # # Doorkopieren van windrichtingen (gebruik functie)
    # Results = windrichtingen(Results_base)

    print("Opslaan van dataframe als csv")

    # Sla de resultaten op
    # header = Results.columns.tolist()
    # data = Results.values

    savefolder = os.path.join(trajectfolder, "{}/Waterlevels_Database_Code_{}.csv".format(traject, traject))
    Results.to_csv(savefolder, index=False)
    # with open(savefolder, "w", newline= "") as f:
    #     writer = csv.writer(f)
    #     writer.writerow(header)
    #     writer.writerows(data)


# Filteren van uitschieters/bakjes
def filter_waterstanden(data_ruw, code_ruw, lim=0.1, max_length=10, max_length_edge=5):

    data = data_ruw.copy()
    code = code_ruw.copy()

    results_H_filtered = []
    results_code_filtered = []

    for i in range(len(data)):

        H = data[i]
        c = code[i]

        # Gradienten
        left_gradient = [H[j+1]-H[j] for j in range(len(H)-1)] + [np.nan]
        right_gradient = [np.nan] + [H[j]-H[j-1] for j in range(1, len(H))]
        # True/False voor gradienten (groter dan limiet)
        left = [True if (left_gradient[j]<(-1*lim)) else False for j in range(len(left_gradient)-1)] + [np.nan]
        right = [np.nan] + [True if (right_gradient[j])>lim else False for j in range(1, len(right_gradient))]

        # Lus door de lijst van linkerzijdes
        fixlater = []
        for k in range(len(left)):
            # if k ==9:
            #     print(BBB)
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
                            #H[left_boundary] = np.nan
                            fixlater.append(l)
                            continue
                        else:
                            # Vervang de waterstanden voor NaN voor de range TUSSEN linkerzijde en rechterzijde
                            H[left_boundary+1:right_boundary] = np.full((right_boundary-left_boundary-1), np.nan).tolist()
                            break

        for l in fixlater:
            if l!=0 or l!=len(H):
                if (left[l] & right[l] &
                    ~np.isnan(H[l+1]) & ~np.isnan(H[l-1])):
                    H[l] = np.nan

        # Lus door de lijst van rechterzijdes
        if max_length < 3:
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
                                H[left_boundary+1:right_boundary] = np.full((right_boundary-left_boundary-1), np.nan).tolist()
                                break


        #Verwijderen van half bakje aan bovenzijde normtraject
        left_bc = [ii for ii in range(max_length_edge+1) if (left[ii]==True & ~np.isnan(H[ii]))]
        right_bc = [ii for ii in range(max_length_edge+1) if (right[ii]==True & ~np.isnan(H[ii]))]
        if (len(right_bc)!=0) and (len(left_bc)!=0):
            for bc in reversed(right_bc):
                if bc<=left_bc[0]:
                    H[:bc] = np.full(bc, np.nan).tolist()
                    break
        elif (len(right_bc)!=0) and (len(left_bc)==0):
        #            print('half bakje boven - row {}'.format(i))
            bc = right_bc[-1]
            H[:bc] = np.full(bc, np.nan).tolist()
        del left_bc, right_bc

        #       #Verwijderen van half bakje aan benedenzijde normtraject
        left_bc = [ii for ii in range(len(left)-max_length_edge, len(left)) if left[ii]==True]
        right_bc = [ii for ii in range(len(right)-max_length_edge, len(right)) if right[ii]==True]
        if (len(right_bc)!=0) and (len(left_bc)!=0):
            for bc in left_bc:
                if bc>=right_bc[-1]:
        #                    print('half bakje beneden - row {} - left {} - right {}'.format(i, bc, right_bc[-1]))
                    H[bc:] = np.full((len(left) - bc), np.nan).tolist()
                    break
        elif (len(right_bc)==0) and (len(left_bc)!=0):
        #            print('half bakje beneden - row {}'.format(i))
            bc = left_bc[0]
            H[bc:] = np.full((len(left) - bc), np.nan).tolist()
        del left_bc, right_bc

        c = [0 if np.isnan(H[j]) else c[j] for j in range(len(H))]

        results_H_filtered.append(H)
        results_code_filtered.append(c)

        del H, left, right

    return results_H_filtered, results_code_filtered

def interpoleren_waterstanden(data_filter, code_filter, lim=200):

    data = data_filter.copy()
    code = code_filter.copy()

    results_H_interp = []
    results_code_interp = []

    for i in range(len(data)):
        H_data = data[i]
        H = pd.Series(data[i])
        H.interpolate(method='linear', limit=lim, limit_direction='both', inplace=True)
        results_H_interp.append(H.tolist())

        code_tmp = code[i]
        code_tmp = [60 if (H[j] != H_data[j]) else code_tmp[j] for j in range(len(code_tmp))]
        results_code_interp.append(code_tmp)

    return results_H_interp, results_code_interp


# Keuze watersysteem
# ws           = 'grev'
ws           = 'vrm'
# ws           = 'vzm'
# ws           = 'mm'

# directory waar de NWM en Scripts mappen instaan
parent_dir = Path(__file__).resolve().parent.parent
work_dir = os.path.join(parent_dir, 'NWM')
print(f'we werken in {work_dir}')

# koppelen watersysteem aan mappen voor invoer en resultaten
if 'grev' in ws :
    tables_path  = os.path.join(work_dir,
                                'dflowfm2d-grevelingen-hr2023_6-v1a',
                                'computations/hr/hr2023/output_python/tables/grev_versie02_statdata_csv')
    trajecten= ['25-4','214','26-4','216', 'extra locaties Grevelingen']
    koptabfile = os.path.join(work_dir,
                                'database_figuren_meren/input_generalmodeldata',
                                'GREV/grev_koppeltabel_v2022_06_10.csv')
    len_filter = [2, 2, 2, 2, 0]
    lim_grad = [0.1, 0.1, 0.1, 0.1, 0]
elif 'vzm' in ws:
    tables_path  = os.path.join(work_dir,
                                'dflowfm2d-grevelingen-hr2023_6-v1a',
                                'computations/hr/hr2023/output_python/tables/vzm_versie03_statdata_csv')
    trajecten= ['215','25-3','216','217', '27-4', '27-3', '219', '31-3', '223', '33-1', '34-5', '34-4', '34-3']
    koptabfile = os.path.join(work_dir,
                                'database_figuren_meren/input_generalmodeldata',
                                'VZM/VZM_koppeltabel_v2022_06_10.csv')
    len_filter = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
    lim_grad = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
elif 'mm' in ws:
    tables_path  = os.path.join(work_dir,
                                'dflowfm2d-markermeer-hr2023_6-v1a/', 
                                'computations/hr/hr2023/output_python/tables/mm_versie01_statdata_csv')
    trajecten= ['13a-1', '13-7','13-8','13-9','13b-1', '46-1', '44-2', '45-2', '205', '8-1', '8-2', '8-3', '204a', 'hoge gronden Markermeer', 'extra locaties Markermeer', 'aslocaties Eem']
    trajecten = ['extra locaties Markermeer']
    koptabfile = os.path.join(work_dir,
                                'database_figuren_meren/input_generalmodeldata',
                                'MM/MM_koppeltabel_v2023_05_31.csv')
    len_filter = [5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0]
    len_filter = [0]
    lim_grad = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0, 0]
    lim_grad = [0]
elif 'vrm' in ws :
    tables_path  = os.path.join(work_dir,
                                'dflowfm2d-vrm-hr2023_6-v1b/',
                                'computations/hr/hr2023/output_python/tables/vrm_versie03_statdata_csv')
    # trajecten= ['227', '8-5', '8-6', '8-7', '205', '45-3', '11-3', 'hoge gronden Veluwerandmeren', 'extra locaties Veluwerandmeren']
    trajecten= ['hoge gronden Veluwerandmeren', 'extra locaties Veluwerandmeren']

    koptabfile = os.path.join(work_dir,
                                'database_figuren_meren/input_generalmodeldata',
                                'VRM/VRM_koppeltabel_v2026_04_20.csv')
    len_filter = [2, 0]#[2, 2, 2, 2, 2, 2, 2, 2, 0]
    lim_grad = [0.1, 0]#[0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0]
resultfolder = os.path.join(work_dir,
                            f'database_figuren_meren/DHYDRO_{ws}_results')
trajectfolder = os.path.join(resultfolder,
                            'Normtrajectdata')

print("start analyse")
koptab = pd.read_csv(koptabfile, sep=';')
datafolder = tables_path

# #aanmaken Brondata
# print("aanmaken Brondata")
# DHYDRO_resultaten(datafolder, resultfolder)

#laden Brondata
print("laden Brondata")
results_max13, results_rolmean_max13, results_first, results_last25, results_maximum, results_minimum = laden_DHYDRO_resultaten(resultfolder)

combinaties = results_max13[['U','D','M']]
dict_len = dict(zip(trajecten, len_filter))
dict_grad = dict(zip(trajecten, lim_grad))

for traject in trajecten:
    #Methode A van VIJD
    """keuze voor gebruik max13 ("max13") en maximum lopend gemiddelde ("rol_mean_max13")"""
    #basislocaties, results_H = waterstand_resultaten(traject, results_max13, results_last25, results_maximum, lim=0.1)
    basislocaties, results_H, results_code = waterstand_resultaten(traject, results_rolmean_max13, results_first, results_last25, results_maximum, results_minimum, lim_droogval=0.00011, lim_opwaaiing=0.005, lim_afwaaiing=-0.005)

    print('Aantal basislocaties: {}'.format(len(basislocaties)))
    opslaan_waterstanden(traject, basislocaties, combinaties, results_H, trajectfolder, filtered=False)
    #opslaan classificatie
    print('Opslaan classificatie')
    opslaan_classificatie(traject, basislocaties, combinaties, results_code, trajectfolder)

    # één locatie: bestanden niet filteren of interpoleren. Dezelfde data wordt opgeslagen als filtered
    if len(results_H[0]) == 1:
        opslaan_waterstanden(traject, basislocaties, combinaties, results_H.copy(), trajectfolder, filtered=True)
    else:
        if traject in trajecten:
            # waterstanden filteren
            results_H_filtered, results_code_filtered = filter_waterstanden(data_ruw=results_H.copy(), code_ruw=results_code.copy(), lim=dict_grad[traject], max_length=dict_len[traject], max_length_edge=3)
            # waterstanden interpoleren
            results_H_interp, results_code_interp = interpoleren_waterstanden(data_filter=results_H_filtered.copy(), code_filter=results_code_filtered.copy(), lim=200)
        else:
            # waterstanden interpoleren
            results_H_interp = interpoleren_waterstanden(data_filter=results_H.copy(), lim=200)
        opslaan_waterstanden(traject, 
                             basislocaties, 
                             combinaties, results_H_interp.copy(), 
                             trajectfolder, 
                             lim_grad=dict_grad[traject], 
                             max_length=dict_len[traject], 
                             filtered=True)

    Results_base = pd.concat([combinaties, pd.DataFrame(data = results_code_interp, columns = basislocaties)], axis=1)

    # Doorkopieren van windrichtingen (gebruik functie)
    Results = windrichtingen(Results_base)

    # Sla de resultaten op
    header = Results.columns.tolist()
    data = Results.values

    savefolder = os.path.join(trajectfolder, "{}/Waterlevels_Database_Code_Filtered_{}.csv".format(traject, traject))

    with open(savefolder, "w", newline= "") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(data)
