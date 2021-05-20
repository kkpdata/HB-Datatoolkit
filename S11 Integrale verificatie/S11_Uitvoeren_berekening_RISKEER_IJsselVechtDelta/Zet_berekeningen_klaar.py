# -*- coding: utf-8 -*-
"""
Created on Wed Jul  8 15:35:25 2020

Schrijf hier waarvoor deze module is geschreven

@author: daggenvoorde
"""

import os
import pandas as pd
import sqlite3
import numpy as np

def closest_node(node, nodes):
    """functie om het dichtsbijzijnde punt uit een lijst van punten
    node    : tuple (X, Y)
    nodes   : list of tuples [(X, Y)]

    output  : index van het punt de kortste afstand in nodes
    """
    nodes = np.asarray(nodes)
    dist_2 = np.sum((nodes - node)**2, axis=1)
    return np.argmin(dist_2)

   #%% pas riskeer database aan
for traject in os.listdir('..'):
    if traject != '10-1':
        continue
    dbpath = os.path.join('..', traject, f'Traject_{traject}.risk')
    locaties = os.path.join('..', '..', 'Controle_databases', 'GIS_kaart',
                        'Normtrajectdata', traject, f'Database_{traject}.xlsx')
    locaties = pd.read_excel(locaties)    
    locaties['location'] = locaties.Hydranaam
    locaties['traject'] = locaties.normtraject
    locaties['Trajectid'] = locaties.normtraject
    qmean = 0.1
    qdev = 0.12
    
    conn = sqlite3.connect(dbpath)

    #GEKB calculations
    query = 'SELECT * FROM GrassCoverErosionInwardsCalculationEntity'
    calculations = pd.read_sql(query, conn)
    #HRDLocations
    query = 'SELECT * FROM HydraulicLocationEntity'
    HRDlocations = pd.read_sql(query, conn)
    #normtrajecten
    query = 'SELECT AssessmentSectionEntityId, Id FROM AssessmentSectionEntity'
    normtrajecten = pd.read_sql(query, conn)
    #dijkprofielen
    query = 'SELECT * FROM DikeProfileEntity'
    dijkprofielen = pd.read_sql(query, conn)

    calculations.CriticalFlowRateMean = qmean
    calculations.CriticalFlowRateStandardDeviation = qdev
    
    # vind de korste afstand
    HRDloclist = []
    for _, row in calculations.iterrows():
        # bepaal assessment_section
        Trajectid = locaties.loc[locaties['location'] == row['Name'], 'Trajectid'].values[0]
        normtrajectId = normtrajecten.loc[normtrajecten['Id'] == str(Trajectid), 'AssessmentSectionEntityId'].values[0]

        HRDLocations_points = tuple(zip(HRDlocations.loc[HRDlocations['AssessmentSectionEntityId'] == normtrajectId, 'LocationX'].tolist(), HRDlocations.loc[HRDlocations['AssessmentSectionEntityId'] == normtrajectId, 'LocationY'].tolist()))

        dijkprofielXY = tuple(dijkprofielen.loc[dijkprofielen['DikeProfileEntityId'] == row['DikeProfileEntityId'], ['X', 'Y']].iloc[0].tolist())
        X, Y = HRDLocations_points[closest_node(dijkprofielXY, HRDLocations_points)]
        HRDloclist.append(HRDlocations.loc[((HRDlocations['LocationX'] == X) & (HRDlocations['LocationY'] == Y)), 'HydraulicLocationEntityId'].values[0])
    calculations['HydraulicLocationEntityId'] = HRDloclist    
    
    if True: # HBN berekening meenemen
        calculations['DikeHeightCalculationType'] = 3

    #calculations terug naar de sql
    calculations.to_sql('GrassCoverErosionInwardsCalculationEntity', conn, if_exists='replace', index=False)

    conn.close()
