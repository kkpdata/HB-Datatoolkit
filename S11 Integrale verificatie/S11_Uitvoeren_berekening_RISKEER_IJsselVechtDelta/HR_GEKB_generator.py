# -*- coding: utf-8 -*-
"""
Onderwerp: Koppeling HR uitvoerpunten met prfl bestanden (maakt aparte berekingen aan per combinatie)
Author: lente (kopie van Martijn Huis in 't Veld)
"""

#Import libraries
from pandas import read_table
from pandas import read_sql_table
from pandas import DataFrame
from pandas import concat
from pandas import read_csv
from pandas import isna
from pandas import merge

import sqlalchemy


loc = r'd:\Users\lente\Documents\Projecten\PR4202.10\toetssporen\GEKB\berekeningen\versie2.0\GEKB_35-1_ringtoets_18.1.1.3.rtd'

#Inladen database (2x vanwege tekortkomingen sqlite-libraries)
conn2 = sqlalchemy.create_engine('sqlite:///{0}'.format(loc))


# creeren cursor
cursor2 = conn2.connect()



try:
    # stap 1: verkrijgen HR-tabel met locaties
    table = 'HydraulicLocationEntity'
    df_GEKB_HR = read_sql_table(table, conn2)
    # stap 2a: Verkrijgen dijkprofielen met locaties:
    table = 'DikeProfileEntity'
    df_GEKB_location = read_sql_table(table, conn2)
    
    
    #stap 2b: berekeningen GEKB inladen
    table = 'GrassCoverErosionInwardsCalculationEntity'
    df_GEKB_calc = read_sql_table(table, conn2)
    
    
    #stap 2c: samenvoegen
    df_GEKB = merge(df_GEKB_calc, df_GEKB_location, on='DikeProfileEntityId')
    
    #stap 3: zoeken naar dichtbijzijnde koppeling HR aan berekening
    GEKB_nearest = []
    for n in range(len(df_GEKB)):
    
        #GEKB profiel locatie
        loc_GEKB = [df_GEKB.at[n,'X'], df_GEKB.at[n,'Y']]
        
        dist = []
        for m in range(len(df_GEKB_HR)):
            loc_HR = [df_GEKB_HR.at[m,'LocationX'], df_GEKB_HR.at[m,'LocationY']]
            dist.append(((abs(loc_GEKB[0] - loc_HR[0]))**2+(abs(loc_GEKB[1] - loc_HR[1]))**2)**(0.5))
        GEKB_nearest.append(df_GEKB_HR.at[dist.index(min(dist)),'HydraulicLocationEntityId'])
    
    df_GEKB_nearest = DataFrame(GEKB_nearest, columns=['HydraulicLocationEntityId'])
    df_GEKB = concat([df_GEKB, df_GEKB_nearest], axis=1)
    df_GEKB = df_GEKB.loc[:, ~df_GEKB.columns.duplicated(keep='last')]
    df_GEKB = df_GEKB.merge(df_GEKB_HR, on='HydraulicLocationEntityId')
    df_GEKB = df_GEKB.set_index('GrassCoverErosionInwardsCalculationEntityId', drop=False)
    df_GEKB = df_GEKB.sort_index(axis=0)
    
    #stap 4: schrijven naar sqlite
    cursor = conn2.connect()
    t_list=[]
    for m in range(1,len(df_GEKB)+1):
        t = [int(df_GEKB.at[m,'HydraulicLocationEntityId']),m]
        t_list.append(t)
        
    print("")
    print("")
    try:
        cursor.execute('UPDATE `GrassCoverErosionInwardsCalculationEntity` SET `HydraulicLocationEntityId`=? WHERE `GrassCoverErosionInwardsCalculationEntityId`= (?);', t_list)
    except:
        print('Let op: koppeling niet geslaagd!! Zijn alle profielen ingeladen? Heb je de berekeningen aangemaakt? Is de HR-database gekoppeld?')
    
except:
    print("Let op: Koppeling niet geslaagd!! Waarschijnlijk klopt de naam of locatie van het inputbestand niet. De tool heeft nu wel een bestand aangemaakt, te herkennen aan een grootte van 0 KB (deze kan verwijderd worden)")


print("")
close_cmd = input("ENTER om af te sluiten")