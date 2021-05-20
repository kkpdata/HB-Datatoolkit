# -*- coding: utf-8 -*-
"""
Created on Wed Jul  8 14:09:27 2020

Schrijf hier waarvoor deze module is geschreven

@author: daggenvoorde
"""

import os
import pandas as pd
import geopandas as gpd
from shapely.geometry import LineString, Point
from fiona.crs import from_epsg
from hkvpy.hydra.profielen import V3_to_V4
import tqdm

#%% defs

def cut(line, distance):
    # Cuts a line in two at a distance from its starting point
    if distance <= 0.0 or distance >= line.length:
        return [LineString(line)]
    coords = list(line.coords)
    for i, p in enumerate(coords):
        part = line.project(Point(p))
        if part == distance:
            return [
                LineString(coords[:i+1]),
                LineString(coords[i:])]
        if part > distance:
            cp = line.interpolate(distance)
            return [
                LineString(coords[:i] + [(cp.x, cp.y)]),
                LineString([(cp.x, cp.y)] + coords[i:])]

def get_chainage(line, locaties):
    chainage = [line.project(Point(p)) for p in zip(locaties.x, locaties.y)]
    profpunten = [line.interpolate(punt) for punt in chainage]
    return chainage, profpunten

def interpolate_nonincreasing(reeks):
    
    diffs = [i - j for i, j in zip(reeks[:-1], reeks[1:])]
    idx = next(x[0] for x in enumerate(diffs) if x[1] > 0)
    
    # onderstaande regel gaat nog mis als de eerste of laatste waarde nonincreasing is
    reeks[idx] = (reeks[idx+1] + reeks[idx-1]) / 2
    
    return reeks

def maakvakindeling(line, locaties, namecol='Locatie', rel_dist=0.5):
    
    flip = False
    if len(locaties) == 1:
        lines = [line]
        chainage, profpunten = get_chainage(line, locaties)
    else:
        # De snijpunten van de vakken liggen precies midden tussen de bekende profielen.
        chainage, profpunten = get_chainage(line, locaties)
        snijpunten = [i+(j-i)*rel_dist for i, j in zip(chainage[:-1], chainage[1:])]      
        
        #check of de laagste chainge bovenaan staat
        if snijpunten[-1] < snijpunten[0]:
            #omdraaien
            snijpunten = snijpunten[::-1]
            flip = True
        # controleren of alle snijpunten oplopen
        increasing = all(i < j for i, j in zip(snijpunten, snijpunten[1:])) 
        counter = 0
        while not increasing:
            counter +=1
            snijpunten = interpolate_nonincreasing(snijpunten)
            increasing = all(i < j for i, j in zip(snijpunten, snijpunten[1:])) 
        print(f'Lijst met snijpunten {counter} keer aangepast voor monotoon toenemende reeks')
            
        lines = []
        for i, snijpunt in tqdm.tqdm(enumerate(snijpunten[::-1]), total=len(snijpunten)):
            delen = cut(line, snijpunt)
            lines.append(delen[1])
            line = delen[0]
            #als de laatste keer geknipt is ook het overgebleven lijndeel toevoegen aan de shape
            if i+1 == len(snijpunten):
                lines.append(line)
            
    vakindeling = gpd.GeoDataFrame(lines, columns=['geometry'])
    if flip:
        vakindeling['Vaknaam'] = locaties[namecol].tolist()[::-1]
    else:
        vakindeling['Vaknaam'] = locaties[namecol].tolist()
    vakindeling.crs = from_epsg(28992) # zet het coordinatensysteem naar RD-new
    
    dijkprofielen = gpd.GeoDataFrame(profpunten, columns=['geometry'])
    dijkprofielen['ID'] = locaties[namecol].str.replace('_', '').values
    dijkprofielen['ID'] = dijkprofielen['ID'].str.replace('-', '').values
    dijkprofielen['X0'] = 0
    dijkprofielen['Naam'] = locaties[namecol].values
    
    return vakindeling, dijkprofielen

#%% input

NBPW = gpd.read_file(r'c:\Users\Public\Documents\WTI\Ringtoets\NBPW' +
                     '\\voorbeeldbestand_nationaalBestandPrimaireWaterkeringen.shp')

hydrawm = os.path.join('..', '..', 'Hydra-NL', 'Interne_controles_set2')
                       
#%% maak input

for traject in tqdm.tqdm(os.listdir('..')):
    print(traject)
    if traject == 'Scripts':
        continue
    if traject not in ['11-1']:
        continue

    locaties = os.path.join('..', '..', 'Controle_databases', 'GIS_kaart',
                        'Normtrajectdata', traject, f'Database_{traject}.xlsx')
    locaties = pd.read_excel(locaties)

    reflijn = NBPW.loc[NBPW['TRAJECT_ID'] == traject].copy()
    line = LineString([xy[0:2] for xy in list(reflijn.geometry.values[0].coords)]) 
    vakindeling, dijkprofielen = maakvakindeling(line,
                                                 locaties,
                                                 namecol='Hydranaam')

    vakindeling.to_file(os.path.join('..', traject,
                                     f'vakindeling_{traject}.shp'))
    dijkprofielen.to_file(os.path.join('..', traject,
                                     f'profielen_{traject}.shp'))
    # copy paste profielen
    for loc in locaties.Hydranaam:
        dbnaam = [x for x in os.listdir(hydrawm) if f'_{traject}_' in x][0]
        bron = os.path.join(hydrawm,
                            dbnaam,
                            loc, 'Profielen', '1op3.prfl')
        profnew = V3_to_V4(bron, loc.replace('_', '').replace('-', ''))
        with open(os.path.join('..', traject, f'{loc}.prfl'), 'w') as f:
            f.write(profnew)
 