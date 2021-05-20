# -*- coding: utf-8 -*-
"""
Created on Mon Jul 29 16:25:40 2019

Visualisatie Resultaten Hydra-NL 4014.10

@author: daggenvoorde
"""
#%% imports
import os
from hkvpy import spatial
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter
import pandas as pd
from shapely.geometry import box
import geopandas as gpd
import sqlite3
import tqdm

plt.ioff()
plt.close('all')
#%% functies
def belasting_bij_tijd(frequentielijn, terugkeertijd):
    """
    Bepaal het belastingniveau op basis van de frequentielijn
    frequentielijn in een pandas dataframe met de kolommen waarde en frequentie
    terugkeertijd bevat de terugkeertijd in jaren
    """
    belasting = np.interp(x=np.log(terugkeertijd),
                          xp=np.log(1./frequentielijn['frequentie']),
                          fp=frequentielijn['waarde'])
    return belasting

#%% instellingen
DEGREE = u'\N{DEGREE SIGN}'
WMBASE = os.path.join('..', 'Interne_controles_set2')
RISKEERDIR = os.path.join('..', '..', 'Riskeer')
NBPW = gpd.read_file(r'c:\Users\Public\Documents\WTI\Ringtoets\NBPW' +
                     '\\voorbeeldbestand_nationaalBestandPrimaireWaterkeringen.shp')


#TRAJECTEN = ['8-4'] #['52-4'] #['9-1', '206']
TRAJECTEN = [x for x in os.listdir(r'../../Riskeer') if x != 'Scripts']
#TRAJECTEN = [x.split('_')[2] for x in os.listdir(WMBASE) if x != 'Scripts']

for traject in TRAJECTEN:
    if not traject in ['225']:
        continue
    print(f'Traject {traject}')
    SAVELOC = os.path.join('..', 'Figuren', 'Frequentielijnen_HS', traject)
    if not os.path.exists(SAVELOC):
        os.makedirs(SAVELOC)
    db = [x for x in os.listdir(os.path.join(WMBASE)) if f'_{traject}_' in x][0]
    
    # Lees data -- Riskeer
    riskeerdb = os.path.join(RISKEERDIR, traject, f'Traject_{traject}.risk')
    conn = sqlite3.connect(riskeerdb)
    riskeerlocs = pd.read_sql('SELECT * FROM HydraulicLocationEntity', conn)
    output = pd.read_sql('SELECT * FROM HydraulicLocationOutputEntity', conn)
    locs2output = pd.read_sql('SELECT * FROM HydraulicLocationCalculationEntity', conn)
    conn.close()
    
    output = output.merge(locs2output, on='HydraulicLocationCalculationEntityId')
    output = output.merge(riskeerlocs, on='HydraulicLocationEntityId')
    
    output.set_index('Name', inplace=True)
    # selecteer de waterstandsuitvoer golven is 1 t/m 4
    output = output.loc[output.HydraulicLocationCalculationCollectionEntityId < 5]

    if len(output) == 0:
        print(f'Geen golfgegevens in Riskeer voor traject {traject}')
        continue
    langsdata = []
    
    for loc in tqdm.tqdm(os.listdir(os.path.join(WMBASE, db))):
        if loc.startswith('_') or loc.startswith('Copy'):
            continue
        if loc not in output.index:
            print(f'Geen golven beschikbaar voor locatie {loc}')
            continue
        fig, [ax, mapax] = plt.subplots(1, 2, figsize=(24/2.54, 12/2.54))
        
#        #lees data -- HYDRA-NL    
#        data = pd.read_csv(os.path.join(WMBASE, db, loc, 'Berekeningen',
#                                           f'WS_zonz', 'hfreq.txt'),
#                              delim_whitespace=True, names=['waarde', 'frequentie'],
#                              skiprows=1)
#        # plot data
#        ax.plot(1/data.frequentie, data.waarde, '--', color='blue',
#                label='Waterstanden Hydra-NL\nzonder modelonzekerheden',
#                linewidth=0.7, zorder=5)

        #lees data -- HYDRA-NL    
        data = pd.read_csv(os.path.join(WMBASE, db, loc, 'Berekeningen',
                                           f'HS_onz', 'hsfreq.txt'),
                              delim_whitespace=True, names=['waarde', 'frequentie'],
                              skiprows=1)
        # plot data
        ax.plot(1/data.frequentie, data.waarde, '-', color='blue',
                label='Golfhoogte Hydra-NL\nmet modelonzekerheden',
                linewidth=0.7, zorder=5)

        # plot -- Riskeerresultaat
        ttijd = 1/output.at[loc, 'TargetProbability']
        waarde = output.at[loc, 'Result']
        waarde_hydra = belasting_bij_tijd(data, ttijd)
        diff = waarde - waarde_hydra
        if type(ttijd) == np.ndarray:
            langsdata.append([loc, ttijd, waarde_hydra, waarde])
        else:
            langsdata.append([loc, ttijd, waarde_hydra, waarde])
        ax.scatter(ttijd, waarde, color='red', label='Golfhoogte Riskeer')
        if type(diff) == np.ndarray:
            for i, d in enumerate(diff):
                ax.text(ttijd[i]*1.1, waarde[i]*0.98, f'Riskeer - Hydra-NL = {d:0.2f}m')
        else:
            ax.text(ttijd*1.1, waarde*0.98, f'Riskeer - Hydra-NL = {diff:0.2f}m')
            
        # limits
        xmin = 10
        xmax = 10**np.ceil(np.log10(ttijd[-1]))
        ymin = np.floor(belasting_bij_tijd(data, xmin))
        ymax = np.ceil(belasting_bij_tijd(data, xmax))
        #formatting
        ax.set_xscale('log')
        ax.set_xlim([xmin, xmax])
        ax.set_ylim([ymin, ymax])
        ax.set_xlabel('Terugkeertijd [jaar]')
        ax.set_ylabel('Golfhoogte [m]')
        ax.yaxis.set_major_formatter(FormatStrFormatter('%.2f'))
        minor_ticks = np.arange(min(ax.get_yticks()), max(ax.get_yticks()), 0.05)
        ax.set_yticks(minor_ticks, minor=True)
        ax.grid(which='minor', alpha=0.4, color='lightgrey', linewidth=0.2)
        ax.grid(which='major', alpha=0.8, color='lightgrey', linewidth=0.4)
        ax.legend(fontsize=8)

        #locatiekaart
        with open(os.path.join(WMBASE, db, loc, 'Berekeningen',
                           f'WS_zonz', 'invoer.hyd'), 'r') as f:
            invoer = f.readlines()
        X = float(invoer[11].split('=')[-1])
        Y = float(invoer[12].split('=')[-1])
        ws = 1000
        bbox = (X - ws,
                Y - ws,
                X + ws,
                Y + ws)
        box1 = box(*bbox)
        kaart = spatial.get_topo_RD(bbox, 600)
        mapax.imshow(kaart, extent=spatial.mpl_bbox(box1.bounds), interpolation='lanczos')
        mapax.scatter(X, Y, s=30, marker='o', facecolor='yellow', color='black',
                      alpha=1, linewidth=0.7, label='Hydralocatie')
        mapax.get_xaxis().set_visible(False)
        mapax.get_yaxis().set_visible(False)
        NBPW.plot(ax=mapax, color='#dd1c77', linewidth=1.0, zorder=1)
    
        mapax.set_xlim([bbox[0], bbox[2]])
        mapax.set_ylim([bbox[1], bbox[3]])
        mapax.legend()
        mapax.set_title(f'{loc}')
        fig.tight_layout(pad=1.3)
        fig.savefig(os.path.join(SAVELOC, f'{loc}.png'))

        plt.close('all')
    plt.ion()

    #%% langsfiguur
    
    langsdata = pd.DataFrame(langsdata, columns=['Locatie', 'Terugkeertijd',
                                                 'Hydra-NL', 'Riskeer'])
    langsdata['vn'] = [float(s.split('_')[1]) for s in langsdata.Locatie]
    langsdata.to_excel(os.path.join(SAVELOC, f'Dataoverzicht_HS_225.xlsx'))
    print(BBB)    
    fig, ax = plt.subplots(figsize=(12, 4))
    if type(ttijd) == np.ndarray:
        for i, t in enumerate(ttijd):
            tt = int(round(t))
            hyd = [x[i] for x in langsdata['Hydra-NL']]
            ris = [x[i] for x in langsdata['Riskeer']]
            ax.plot(langsdata.vn, hyd, label=f'Golfhoogtes Hydra-NL T{tt}',
                    linewidth=2, linestyle='-.', color=f'C{i}')
            ax.plot(langsdata.vn, ris, label=f'Golfhoogtes Riskeer T{tt}' ,
                    linewidth=2, color=f'C{i}')

        ax.set_title(f'Golfhoogtes {traject} bij verschillende terugkeertijden')
    else:
        ax.plot(langsdata.vn, langsdata['Hydra-NL'], label='Golfhoogtes Hydra-NL',
                linewidth=2)
        ax.plot(langsdata.vn, langsdata['Riskeer'], label='Golfhoogtes Riskeer',
                linewidth=2)
        ax.set_title(f'Golfhoogtes {traject} bij terugkeertijd van {int(ttijd)} jaar')
    ax.set_ylabel('Golfhoogte [m]')
    ax.set_xlabel('Volgnummer [-]')
    ax.grid()
    ax.legend()
    fig.tight_layout()
    fig.savefig(os.path.join(SAVELOC, f'Langsfiguur_{traject}.png'))