# -*- coding: utf-8 -*-
"""
Created on Wed Oct 23 10:52:44 2019

@author: hove
"""

"""
Maak een csv bestand met daarin voor elke oeverlocaties:
    - ID
    - nieuwe naam
    - x, y coordinaten
    - normtraject
    - naam en ID van terugvallocatie en x, y coordinaten hiervan
    - naam en ID van aslocatie en x, y coordinaten hiervan
    - orientatie (dijknormaal) van oeverlocatie
    - bodemhoogte van oeverlocatie
"""

import os
import subprocess
import pandas as pd
import itertools

#%%

# lees csv bestand van één van de WAQUA resultaten. Hierin staan de bodemhoogtes. 
modelresultaten = pd.read_csv(os.path.join('..', 'tables_csv_complete', 'statdata_KaoMn010Q0100U00D360.csv'), sep=";") 

# gebruik de naam van de locaties als index
modelresultaten.index = modelresultaten.pop('Name')

#%%

# lijst van normtrajecten 
normtrajecten = ['10-2', '8-4', '9-1', '9-2', '10-2', '10-3' '11-1', '52-3', '52-4', '52a-1', '53-2', '53-3', '202', '206', '225', '227']
normtrajecten = ['225']

for nr in normtrajecten:
    
    print('normtraject: {}'.format(nr))
    
    ### Laad de data voor een normtraject ###
    
    # laad de csv waarin oeverlocatie is gekoppeld aan een backuplocatie en aslocatie
    string = "Locaties_{}_matched".format(nr)
    
    try:
        data = pd.read_csv(os.path.join('..', 'GIS_kaart', 'Normtrajectdata', '{}\{}.csv'.format(nr, string)))
    except:
        continue
    
    # lijst van oeverlocaties, terugvallocaties en aslocaties
    oeverlocaties = data[data['set'] == 0]['name'].tolist()
    backuplocaties = data[data['set'] == 1]['name'].tolist()
    aslocaties = data[data['set'] == 2]['name'].tolist()
    
    # selecteer uit de modelresultaten de oeverlocaties en verwijder onnodige kolommen
    df = modelresultaten.filter(oeverlocaties, axis=0)
    df.drop(['m', 'n', 'set', 'NANMAX', 'DROOGP', 'SEPMAX', 'INSTPK', 'max13', 'rolmean_max13', 'last25', 'maximum', 'nearestsection'], axis=1, inplace=True)
    # voeg een kolom met normtraject toe
    df['normtraject'] = nr
    
    ### Gebruik FETCH om de orientatie van de dijknormaal te verkrijgen ###
    
    fetch_dir = "..\Fetch"
        
    # locatie van input en output bestand voor fetch
    f_inp = os.path.join(fetch_dir, "invoer.inp")
    f_out = os.path.join(fetch_dir, "output.out")
    
    # verwijder huidig input bestand, als dit bestaat
    try:
        os.remove(f_inp)
    except OSError:
        pass
    
    # maak het invoer bestand voor fetch
    n_wind = 12 # aantal windsectoren
    dist = 100000 # maximum afstand tot oever
    loc_shp = r".\Achtergrondshapes\winterbedWBI2017.shp"
    
    with open(f_inp, "w") as f:
        f.write(loc_shp + "\n") # shp file
        f.write(str(n_wind) + "\n") # windsectoren
        f.write(str(dist) + "\n") # 
        for i, row in df.iterrows():
            f.write("{}     {} \n".format(row.x, row.y))        
        f.close()
    
    # run fetch.exe 
    print("start berekenen van fetch")
    subprocess.call("cd " + fetch_dir + r" & Fetch.exe < " + f_inp + " > " + f_out, shell=True)
    print("klaar met berekenen van fetch")
        
    # open de output file en lees de dijknormalen (orientatie)
    orientatie = []
    with open(f_out, "r") as f:
        count = 0
        for line in itertools.islice(f, 5, None, n_wind):
            count += 1
            clean_line = line.rstrip()
            orientatie.append(float(clean_line.rsplit(" ", 1)[1]))
    f.close()
        
    # voeg dijknormalen (orientatie) to aan df_oever
    df['orientatie'] = orientatie
    
    ### Voeg backup en as locaties toe aan het dataframe ###
    
    df.reset_index(level=0, inplace=True)
    
    # selecteer uit de modelresultaten de oeverlocaties en verwijder onnodige kolommen
    df_backup = modelresultaten.filter(backuplocaties, axis=0)
    # voeg kolommen met gegevens van backup locaties toe aan df
    df["naam_backup"] = df_backup.index
    df["stationid_backup"] = df_backup["stationid"].values
    df["x_backup"] = df_backup["x"].values
    df["y_backup"] = df_backup["y"].values
    
    # selecteer uit de modelresultaten de aslocaties en verwijder onnodige kolommen
    df_as = modelresultaten.filter(aslocaties, axis=0)
    # voeg kolommen met gegevens van as locaties toe aan df
    df["naam_as"] = df_as.index
    df["stationid_as"] = df_as["stationid"].values
    df["x_as"] = df_as["x"].values
    df["y_as"] = df_as["y"].values
    
    ### Opslaan van resultaten ###
    
    # opslaan in csv bestand
    df.to_csv(os.path.join('..', 'GIS_kaart', 'Normtrajectdata', '{}\Database_{}.csv'.format(nr, nr)), index=False)
    
    
    
