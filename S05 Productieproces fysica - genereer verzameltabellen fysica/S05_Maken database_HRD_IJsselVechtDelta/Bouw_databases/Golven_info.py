# -*- coding: utf-8 -*-
"""
Created on Thu Jun 25 16:57:38 2020

@author: duits
"""

import os
import pandas as pd
import numpy as np

#%%

# Bouwen van dataframe met informatie over golfparameters (SWAN/Bretschneider) voor het bepaald traject
def info_golven_SWAN_BRET(trajectfolder, traject, golven_overzicht, lim=0.1, perc_nat=0.4):
    # Uitvoer
    # Dataframe "locaties_traject" met met meerdere kolommen:
    #  1. Oeverlocatie met WAQUA-naam
    #  2. Vlag of golven uit SWAN komen
    #  3. Vlag of de SWAN-golfparameters van de oeverlocatie voldoen als de golven uit SWAN komen.
    #     Als geen golven vanuit SWAN beschikbaar zijn, dan worden de golven met Bretschneider berekend en
    #     wordt WEL de oeverlocatie gebruikt
    #  4. De naam van de gebruikte locatie in WAQUA
    #  5. ID van de SWAN-golven.
    #     Dit is het ID van de oeverlocatie als de SWAN-golven van oeverlocatie goed genoeg zijn.
    #     Dit is het ID van de backuplocatie als de SWAN-golven van de oeverlocatie niet voldoen.
    #     Het ID van de SWAN-golven is NaN als de golven door Bretschneider berekend moeten worden.
    #  6. Hydra-naam
    #  7. LocationID
    #  8. X-coördinaat locatie voor database
    #     Dit is de x-coördinaat van de oeverlocatie als de SWAN-golven voldoen of als de golven uit Bretschneider komen.
    #     Dit is de x-coördinaat van de backuplocatie als de SWAN-golven van de oeverlocatie niet voldoen. 
    #  9. Y-coördinaat locatie voor database
    #     Dit is de y-coördinaat van de oeverlocatie als de SWAN-golven voldoen of als de golven uit Bretschneider komen.
    #     Dit is de y-coördinaat van de backuplocatie als de SWAN-golven van de oeverlocatie niet voldoen.
    # 10. BedLevel
    # 11. Bretschneider ID van de oeverlocatie
    #     Dit kan voor situaties met golven uit SWAN een NaN zijn.
    # 12. Vlag of de locatie zich in een hoogwatergeul bevindt.
    
    # Laden van bestand met koppeling locaties
    file = os.path.join(trajectfolder, "{}\Database_{}.xlsx".format(traject, traject))
    locaties = pd.read_excel(file)     
    locaties.index = locaties.pop('Name')
    print('Traject {} bevat {} locaties'.format(traject, len(locaties)))
    
    # Lijst van oeverlocaties en backuplocaties
    oeverlocaties = locaties.index.tolist()
    backuplocaties = locaties.naam_backup.tolist()
    
    # Hier wordt gewerkt met de oeverlocaties van het traject (gegevens voor de oeverlocaties staan dus in de DataFrame "golven_traject")
    golven_traject = golven_overzicht.loc[locaties.index]
    
    # Uitvoer nummers 1 en 2
    locaties_traject = pd.DataFrame({'Oeverlocatie' : oeverlocaties, 'Inmodel': golven_traject.Inmodel})
    
    Oeverlocatie_SWAN_betrouwbaar = [True if golven_traject.QUALITY[i] == ('EXCEL' or 'GOOD') else False for i in range(len(locaties))]
    Voldoende_nat = [True if golven_traject.Perc_nat[i] >= perc_nat else False for i in range(len(locaties))]
    
    Oeverlocatie_SWAN = np.logical_and(Oeverlocatie_SWAN_betrouwbaar, Voldoende_nat)
    
    # Als geen golven vanuit SWAN beschikbaar zijn, dan worden de golven met Bretschneider berekend en
    # wordt WEL de oeverlocatie gebruikt
    Oeverlocatie_gebruiken = [Oeverlocatie_SWAN[i] if golven_traject.Inmodel[i] else True for i in range(len(locaties_traject))]

    # Uitvoer nummers 3
    locaties_traject['Oeverlocatie_gebruiken'] = Oeverlocatie_gebruiken
    
    # Uitvoer nummers 4
    # Naam van de WAQUA-waterstandslocatie waarvan de coördinaten uiteindelijk in de database terecht komen
    WAQUA_naam_Databaselocatie = [oeverlocaties[i] if Oeverlocatie_gebruiken[i] else backuplocaties[i] for i in range(len(locaties_traject))]
    locaties_traject['WAQUA_naam_Databaselocatie'] = WAQUA_naam_Databaselocatie
    
    # Een tijdelijke dataFrame
    loc_traject = [oeverlocaties[i] if Oeverlocatie_gebruiken[i] else backuplocaties[i] for i in range(len(locaties))]

    # Hier wordt gewerkt met een gedeeltelijke vervanging van de oeverlocaties
    info_locaties_traject = golven_overzicht.loc[loc_traject]
    
    # Uitvoer nummers 5
    locaties_traject['SWAN_ID'] = info_locaties_traject['SWAN_ID'].tolist()
  
    # Uitvoer nummers 6, 7, 8, 9 en 10
    locaties_traject['Hydranaam'] = locaties['Hydranaam']
    locaties_traject['LocationID'] = locaties['HRDLocationID']
    x_loc = [locaties['x'][i] if Oeverlocatie_gebruiken[i] else locaties['x_backup'][i] for i in range(len(locaties))]
    y_loc = [locaties['y'][i] if Oeverlocatie_gebruiken[i] else locaties['y_backup'][i] for i in range(len(locaties))]
    locaties_traject['x'] = x_loc
    locaties_traject['y'] = y_loc
    locaties_traject['bedlevel'] = locaties['bedlevel']
    
    # Uitvoer nummers 11
    # Dit veld is van toepassing voor golven vanuit Bretschneider
    # Bij golven vanuit Bretscheider wordt altijd gewerkt met de oeverlocaties (dus niet met backup- of aslocaties)
    info_locaties_traject = golven_overzicht.loc[oeverlocaties]
    locaties_traject['Bretschneider_ID'] = info_locaties_traject['bret_id']
    
    # Uitvoer nummers 12
    # Bepaal of de locatie zich in een hoogwatergeul bevindt
    if 'Geul' in locaties:
        locaties_traject['Geul'] = locaties['Geul']
    else:
        locaties_traject['Geul'] = 0

    locaties_traject.index = locaties_traject.pop('Oeverlocatie')
    
    return locaties_traject
