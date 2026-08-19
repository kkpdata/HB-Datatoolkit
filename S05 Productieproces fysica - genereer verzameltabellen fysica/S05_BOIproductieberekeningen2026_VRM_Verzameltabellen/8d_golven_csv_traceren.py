# -*- coding: utf-8 -*-
"""
Created on Mon May 16 14:45:12 2022

@author: oerlemans
"""

import numpy as np
import pandas as pd
import os

# stochastcombinatie ruwe golfparameters
U = 27
D_swan = 225
D_csv = 225
H = 250
M = 1.6

# locatie
traject = '11-3'
location = '011-03_0030_VE_dp0101_HRbasis60m'


#grevelingen
# path_swan = r'p:\PR\4539.10\Werkmap\NWM\swan-grev-hr2023\grevU{}D{}Mp{}Va\results\grevU{}D{}Mp{}Va_p4_boi.tab'.format(U, D_swan, H, U, D_swan, H)
# path_csv = r'p:\PR\4539.10\Werkmap\NWM\database_figuren_meren\DHYDRO_grev_results\Normtrajectdata'
# path_koppeling = r'p:\PR\4539.10\Werkmap\NWM\database_figuren_meren\input_generalmodeldata\GREV\grev_DHYDRO_SWAN_koppeling_v1_backup.csv'

# #veluwerandmeren
# path_swan = r'p:\PR\4539.10\Werkmap\NWM\swan-vrm_hr2023\vrmU{}D{}Mp{}Va\results\vrmU{}D{}Mp{}Va_p4_boi.tab'.format(U, D_swan, H, U, D_swan, H)
# path_csv = r'p:\PR\4539.10\Werkmap\NWM\database_figuren_meren\DHYDRO_vrm_results\Normtrajectdata'
# path_koppeling = r'p:\PR\4539.10\Werkmap\NWM\database_figuren_meren\input_generalmodeldata\VRM\vrm_DHYDRO_SWAN_koppeling_v1_backup.csv'

#grevelingen
path_swan = r'p:\PR\4539.10\Werkmap\NWM\swan-mm-hr2023\mmU{}D{}Mp{}Va\results\grevU{}D{}Mp{}Va_p4_boi.tab'.format(U, D_swan, H, U, D_swan, H)
path_csv = r'p:\PR\4539.10\Werkmap\NWM\database_figuren_meren\DHYDRO_mm_results\Normtrajectdata'
path_koppeling = r'p:\PR\4539.10\Werkmap\NWM\database_figuren_meren\input_generalmodeldata\MM\mm_DHYDRO_SWAN_koppeling_v1_backup.csv'

#uitlezen koppeling X, Y
df_koppel = pd.read_csv(path_koppeling)
X = df_koppel['XCoordinate'].loc[df_koppel['BaseLineName_basis'] == location].to_list()[0]
Y = df_koppel['YCoordinate'].loc[df_koppel['BaseLineName_basis'] == location].to_list()[0]

print(location, X, Y)
def lees_swan_parameters(path_swan, X, Y): 
        # lees headerregel
        select_kolommen = ['Xp', 'Yp', 'Hsig', 'TPsmoo', 'Tm_10', 'Dir']
        with open(path_swan, 'r') as f:
            for line in f.readlines():
                if select_kolommen[0] in line:
                    header = line[1:].split()
                    break
        select_indices = [header.index(col) for col in select_kolommen]
        
        resultaat = pd.read_table(path_swan, delim_whitespace=True, comment='%', header=None, 
                          usecols=select_indices, names=select_kolommen)
        
        resultaat_locatie = resultaat.loc[resultaat['Xp'] == X]
        resultaat_locatie = resultaat_locatie.loc[resultaat_locatie['Yp'] == Y]
        
        print('Hs =', resultaat_locatie['Hsig'].to_list()[0])
        print('Tp =', resultaat_locatie['TPsmoo'].to_list()[0])
        print('Tm =', resultaat_locatie['Tm_10'].to_list()[0])
        print('Dir =', resultaat_locatie['Dir'].to_list()[0])
        
        return resultaat_locatie
    
def lees_csv_parameters(path_csv, location, U, D_csv, M):
    Hs_csv = pd.read_csv(os.path.join(path_csv, traject, 'Golfparameter_SWAN_Hs_{}_backup.csv'.format(traject)))
    Tp_csv = pd.read_csv(os.path.join(path_csv, traject, 'Golfparameter_SWAN_Tp_{}_backup.csv'.format(traject)))
    Tm_csv = pd.read_csv(os.path.join(path_csv, traject, 'Golfparameter_SWAN_Tm_{}_backup.csv'.format(traject)))
    Dir_csv = pd.read_csv(os.path.join(path_csv, traject, 'Golfparameter_SWAN_Dir_{}_backup.csv'.format(traject)))
    
    h_csv = pd.read_csv(os.path.join(path_csv, traject, 'Waterlevels_Database_grad0.1_bakje2_Filtered_{}.csv'.format(traject)))

    Hs_location = Hs_csv[location].loc[(Hs_csv['U'] == U) & (Hs_csv['D'] == D_csv) & (Hs_csv['M'] == M)].to_list()[0]
    Tp_location = Tp_csv[location].loc[(Tp_csv['U'] == U) & (Tp_csv['D'] == D_csv) & (Tp_csv['M'] == M)].to_list()[0]
    Tm_location = Tm_csv[location].loc[(Tm_csv['U'] == U) & (Tm_csv['D'] == D_csv) & (Tm_csv['M'] == M)].to_list()[0]
    Dir_location = Dir_csv[location].loc[(Dir_csv['U'] == U) & (Dir_csv['D'] == D_csv) & (Dir_csv['M'] == M)].to_list()[0]
    
    h_location = h_csv[location].loc[(h_csv['U'] == U) & (h_csv['D'] == D_csv) & (h_csv['M'] == M)].to_list()[0]
    
    print('Hs =', Hs_location)
    print('Tp =', Tp_location)
    print('Tm =', Tm_location)
    print('Dir =', Dir_location)
    print('Lokale waterstand =', h_location, ' m+NAP')
    
    return(Hs_location)

print('parameters ruwe swan bestanden')        
resultaat_locatie = lees_swan_parameters(path_swan, X, Y)
print('parameters .csv bestanden') 
lees_csv_parameters(path_csv, location, U, D_csv, M)
print('Vlakke waterspiegel = ', H/100, ' m+NAP')




