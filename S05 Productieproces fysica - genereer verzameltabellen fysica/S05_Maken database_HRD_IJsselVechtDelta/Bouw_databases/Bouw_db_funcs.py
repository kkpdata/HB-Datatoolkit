# -*- coding: utf-8 -*-
"""
Created on Fri Jul 19 08:04:20 2019

Functies die worden gebruikt om databases te maken met databases script

@author: daggenvoorde
"""

import pandas as pd
import geopandas as gpd
from shapely.geometry import Point
import inspect
import numpy as np
import matplotlib.pyplot as plt

def determine_uncertainty_df(onzekerhedenshape_loc, HRDLocations, conn, watersysteem):
    """functie voor het bepalen van de modelonzekerheden per locatie van voor 4-10-2018
    Op 4 oktober hebben we na overleg met Jan Stijnen en Matthijs Duits besloten om de modelonzekerheden te updaten.
    Dit is gedaan door een nieuwe functie toe te passen : determine_uncertainty_df_v2"""
    ClosingSituations = pd.read_sql("SELECT * FROM ClosingSituations;", conn)

    # Lees shapefile in met modelonzekerheden
    geomodelonzekerheden = gpd.read_file(onzekerhedenshape_loc)
    
    # Bepaal voor elke locatie binnen welke 'onzekerheidsvlak' deze valt
    UncertaintyModelFactor = []
    for i, loc in HRDLocations.iterrows():
        index = geomodelonzekerheden.loc[geomodelonzekerheden.intersects(Point(loc.XCoordinate, loc.YCoordinate))].index
        unc = geomodelonzekerheden.loc[index, ["mu", "sigma"]]
        
        if watersysteem == '07_ijsselmeer':
            listidx = [1, 2, 3, 8]
            listmu  = [unc["mu"].tolist()[0], 0.99, 0.96, 0.96]
            liststd = [unc["sigma"].tolist()[0], 0.19, 0.11, 0.11] 
        else: #IJVD
            listidx = [1.0, 2.0, 3.0, 4.0]
            listmu  = [unc["mu"].tolist()[0], 0.96, 1.03, 1.03]
            liststd = [unc["sigma"].tolist()[0], 0.27, 0.13, 0.13]   
    
        for j, closure in ClosingSituations.iterrows():
            for k, mu, std in zip(listidx, listmu, liststd):
                new_row = [loc.HRDLocationId, closure.ClosingSituationId, int(k), mu, std]
                UncertaintyModelFactor.append(new_row)
    UncertaintyModelFactor = pd.DataFrame(UncertaintyModelFactor, columns=["HRDLocationId", "ClosingSituationId", "HRDResultColumnId", "Mean", "Standarddeviation"])

    return UncertaintyModelFactor
    
def determine_uncertainty_df_v2(onzekerhedenshape_loc, HRDLocations, conn, watersysteem, bretschneiderlocs):
    """functie voor het bepalen van modelonzekerheden, dit is een update van 4 oktober. Nieuwe modelonzekerheden zijn toegepast.
    
    Op locaties waar SWAN wordt gebruikt zijn de modelonzekerheden overgenomen uit hoofdsysteem 2:
        Hs :     mu=-0.06, sigma = 0.15
        Tm-1,0 : mu=-0.11, sigma = 0.04
        Tp     : mu=-0.01, sigma = 0.07
    Op bretschneider locaties hoofdsysteem 3:
        Hs :     mu=-0.04, sigma = 0.27
        Tm-1,0 : mu=0.03, sigma = 0.13
        Tp     : mu=0.03, sigma = 0.13
    De onzekerheden worden in de database gezet met de volgende functie:
        f_bias_corr = 1 / ( 1 + mu)
    """
    ClosingSituations = pd.read_sql("SELECT * FROM ClosingSituations;", conn)

    # Lees shapefile in met modelonzekerheden
    geomodelonzekerheden = gpd.read_file(onzekerhedenshape_loc)
    
    # Bepaal voor elke locatie binnen welke 'onzekerheidsvlak' deze valt
    UncertaintyModelFactor = []
    for i, loc in HRDLocations.iterrows():
        index = geomodelonzekerheden.loc[geomodelonzekerheden.intersects(Point(loc.XCoordinate, loc.YCoordinate))].index
        unc = geomodelonzekerheden.loc[index, ["mu", "sigma"]]
        
        if watersysteem == '07_ijsselmeer':
            listidx = [1, 2, 3, 8]
            listmu  = [unc["mu"].tolist()[0], 0.99, 0.96, 0.96]
            liststd = [unc["sigma"].tolist()[0], 0.19, 0.11, 0.11] 
        else: #IJVD
            listidx = [1.0, 2.0, 3.0, 4.0]
            #1 = waterstand, 2=golfhoogte 3=Tp, 4=Tm-1,0
            if loc['Name'] in bretschneiderlocs: #hoofdsysteem 3        
                listmu  = [unc["mu"].tolist()[0], round(1 / ( 1 - 0.04),2), round(1 / ( 1 + 0.03),2), round(1 / ( 1 + 0.03),2)]
                liststd = [unc["sigma"].tolist()[0], 0.27, 0.13, 0.13]   
            else: # hoofdsysteem 2
                listmu  = [unc["mu"].tolist()[0], round(1 / ( 1 - 0.06),2) , round(1 / ( 1 - 0.01),2), round(1 / ( 1 - 0.11),2)]
                liststd = [unc["sigma"].tolist()[0], 0.15, 0.07, 0.04]   
    
        for j, closure in ClosingSituations.iterrows():
            for k, mu, std in zip(listidx, listmu, liststd):
                new_row = [loc.HRDLocationId, closure.ClosingSituationId, int(k), mu, std]
                UncertaintyModelFactor.append(new_row)
    UncertaintyModelFactor = pd.DataFrame(UncertaintyModelFactor, columns=["HRDLocationId", "ClosingSituationId", "HRDResultColumnId", "Mean", "Standarddeviation"])

    return UncertaintyModelFactor

def determine_uncertainty_df_v3(onzekerhedenshape_loc, HRDLocations, conn, watersysteem, bretschneiderlocs):
    """functie voor het bepalen van modelonzekerheden, dit is een update van 16 oktober. Na overleg met RWS (Robert Slomp) is besloten de correctie
    op de mu's niet door te voeren.
    
    Op locaties waar SWAN wordt gebruikt zijn de modelonzekerheden overgenomen uit hoofdsysteem 2:
        Hs :     mu=-0.06, sigma = 0.15
        Tm-1,0 : mu=-0.11, sigma = 0.04
        Tp     : mu=-0.01, sigma = 0.07
    Op bretschneider locaties hoofdsysteem 3:
        Hs :     mu=-0.04, sigma = 0.27
        Tm-1,0 : mu=0.03, sigma = 0.13
        Tp     : mu=0.03, sigma = 0.13
    De onzekerheden worden in de database gezet met de volgende functie:
        f_bias_corr =  1 + mu
    """
    ClosingSituations = pd.read_sql("SELECT * FROM ClosingSituations;", conn)

    # Lees shapefile in met modelonzekerheden
    geomodelonzekerheden = gpd.read_file(onzekerhedenshape_loc)
    
    # Bepaal voor elke locatie binnen welke 'onzekerheidsvlak' deze valt
    UncertaintyModelFactor = []
    for i, loc in HRDLocations.iterrows():
        index = geomodelonzekerheden.loc[geomodelonzekerheden.intersects(Point(loc.XCoordinate, loc.YCoordinate))].index
        unc = geomodelonzekerheden.loc[index, ["mu", "sigma"]]
        
        if watersysteem == '07_ijsselmeer':
            listidx = [1, 2, 3, 8]
            listmu  = [unc["mu"].tolist()[0], 0.99, 0.96, 0.96]
            liststd = [unc["sigma"].tolist()[0], 0.19, 0.11, 0.11] 
        else: #IJVD
            listidx = [1.0, 2.0, 3.0, 4.0]
            #1 = waterstand, 2=golfhoogte 3=Tp, 4=Tm-1,0
            if loc['Name'] in bretschneiderlocs: #hoofdsysteem 3        
                listmu  = [unc["mu"].tolist()[0], 0.96, 1.03, 1.03]
                liststd = [unc["sigma"].tolist()[0], 0.27, 0.13, 0.13]   
            else: # hoofdsysteem 2
                listmu  = [unc["mu"].tolist()[0], 0.94 , 0.99, 0.89]
                liststd = [unc["sigma"].tolist()[0], 0.15, 0.07, 0.04]   
    
        for j, closure in ClosingSituations.iterrows():
            for k, mu, std in zip(listidx, listmu, liststd):
                new_row = [loc.HRDLocationId, closure.ClosingSituationId, int(k), mu, std]
                UncertaintyModelFactor.append(new_row)
    UncertaintyModelFactor = pd.DataFrame(UncertaintyModelFactor, columns=["HRDLocationId", "ClosingSituationId", "HRDResultColumnId", "Mean", "Standarddeviation"])

    return UncertaintyModelFactor

def determine_uncertainty_df_v4(onzekerhedenshape_loc, HRDLocations, conn, watersysteem, SWAN_locs):
    """functie voor het bepalen van modelonzekerheden. Dit is een update van 26 juni 2020 conform het uitgangspuntenrapport.
    op de mu's niet door te voeren.
    
    Voor hoofdsysteem 1 zijn golven berekend met SWAN en luiden de modelonzekerheden:
        Hs     : mu=-0.01, sigma = 0.19
        Tp     : mu=-0.04, sigma = 0.11
        Tm-1,0 : mu=-0.04, sigma = 0.11
    Op locaties waar SWAN wordt gebruikt zijn de modelonzekerheden overgenomen uit hoofdsysteem 2:
        Hs     : mu=-0.06, sigma = 0.15
        Tp     : mu=-0.01, sigma = 0.07
        Tm-1,0 : mu=-0.11, sigma = 0.04
    Op bretschneider locaties hoofdsysteem 3:
        Hs     : mu=-0.04, sigma = 0.27
        Tp     : mu= 0.03, sigma = 0.13
        Tm-1,0 : mu= 0.03, sigma = 0.13
    De onzekerheden worden in de database gezet met de volgende functie:
        f_bias_corr = 1/(1+mu) en afgerond op 2 decimalen
    """
    ClosingSituations = pd.read_sql("SELECT * FROM ClosingSituations;", conn)

    # Lees shapefile in met modelonzekerheden
    geomodelonzekerheden = gpd.read_file(onzekerhedenshape_loc)
    
    # Bepaal voor elke locatie binnen welke 'onzekerheidsvlak' deze valt
    UncertaintyModelFactor = []
    for i, loc in HRDLocations.iterrows():
        index = geomodelonzekerheden.loc[geomodelonzekerheden.intersects(Point(loc.XCoordinate, loc.YCoordinate))].index
        unc = geomodelonzekerheden.loc[index, ["mu", "sigma"]]
        
        if watersysteem == '07_ijsselmeer':
            listidx = [1, 2, 3, 8]
            listmu  = [unc["mu"].tolist()[0], 1.01, 1.04, 1.04]
            liststd = [unc["sigma"].tolist()[0], 0.19, 0.11, 0.11] 
        else: #IJVD
            listidx = [1.0, 2.0, 3.0, 4.0]
            #1 = waterstand, 2=golfhoogte 3=Tp, 4=Tm-1,0
            if SWAN_locs[i]: #hoofdsysteem 2
                listmu  = [unc["mu"].tolist()[0], 1.06, 1.01, 1.12]
                liststd = [unc["sigma"].tolist()[0], 0.15, 0.07, 0.04]   
            else:            # hoofdsysteem 3
                listmu  = [unc["mu"].tolist()[0], 1.04, 0.97, 0.97]
                liststd = [unc["sigma"].tolist()[0], 0.27, 0.13, 0.13]   
    
        for j, closure in ClosingSituations.iterrows():
            for k, mu, std in zip(listidx, listmu, liststd):
                new_row = [loc.HRDLocationId, closure.ClosingSituationId, int(k), mu, std]
                UncertaintyModelFactor.append(new_row)
    UncertaintyModelFactor = pd.DataFrame(UncertaintyModelFactor, columns=["HRDLocationId", "ClosingSituationId", "HRDResultColumnId", "Mean", "Standarddeviation"])

    return UncertaintyModelFactor


def lineno():
    """Returns the current line number in our program."""
    return inspect.currentframe().f_back.f_lineno

def delete_all(table, conn):
    """
    Delete all rows in the tasks table
    :param conn: Connection to the SQLite database
    :return:
    """
    sql = 'DELETE FROM {}'.format(table)
    cur = conn.cursor()
    cur.execute(sql)

def bepaal_windfactor(X, Y, makeplot=False):
    """
    Bepaal de windfactor uit het windveld
    """
    
    #inladen windveld
    xx = r'p:\PR\4014.10\Werk\Windvelden\Reproductie_3871.10\wind_SDS_rv\xx.npy'
    yy = r'p:\PR\4014.10\Werk\Windvelden\Reproductie_3871.10\wind_SDS_rv\yy.npy'
    grid_z = r'p:\PR\4014.10\Werk\Windvelden\Reproductie_3871.10\wind_SDS_rv\grid_z.npy'
    
    xx = np.load(xx)
    yy = np.load(yy)
    grid_z = np.load(grid_z)
    xx_coords = list(xx[0])
    yy_coords = [y_arr[0] for y_arr in yy]
    
        
    # dit werkt nog niet
    Xi = next(x[0] for x in enumerate(xx_coords) if x[1] > X)
    Yi = next(y[0] for y in enumerate(yy_coords) if y[1] > Y)
    wf = round(grid_z[Yi, Xi],2)
    if makeplot:
        fig, ax = plt.subplots(figsize = (25/2.54,25/2.54))
        cmap = plt.get_cmap('RdYlGn_r')
        im = ax.pcolormesh(xx,yy,grid_z,cmap=cmap,alpha=0.3)
        fig.colorbar(im, ax=ax)
        ax.scatter(X, Y, color='blue')
        CS = ax.contour(xx_coords,yy_coords,grid_z,np.arange(0.7,1.3,0.05),linestyles='dashed',colors='grey',linewidths=0.5)
        CS.levels = [round(val,2) for val in CS.levels]
        # Label levels with specially formatted floats
        if plt.rcParams["text.usetex"]:
            fmt = r'%r \%%'
        else:
            fmt = '%r'
        ax.clabel(CS, CS.levels, inline=True, fmt=fmt, fontsize=10)
        ax.text(X, Y, str(wf), color='blue')
    return wf