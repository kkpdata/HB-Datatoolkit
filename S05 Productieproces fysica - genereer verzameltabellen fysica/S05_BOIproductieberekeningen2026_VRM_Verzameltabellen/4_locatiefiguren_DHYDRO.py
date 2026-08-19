# -*- coding: utf-8 -*-
"""
Created on  : 11-01-2022
Author      : Cees Oerlemans
Project     : PR4539.10 BOI Meren
Description : Gebaseerd op script van Andries Paarlberg voor PR3638.10 Oosterschelde scripts

"""

import matplotlib
import os
from pathlib import Path
import platform
platf = platform.system()
if platf != 'Windows' :
    matplotlib.use('Agg')
# import imp
import geopandas as gpd
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
# from hkvpy.waqua import plots
# imp.reload(plots)
# from hkvpy import spatial
from shapely.geometry import box
from tqdm import tqdm
from urllib.request import urlretrieve
from matplotlib.pyplot import imread

# Zet het nieuwe default font voor figuren
matplotlib.rcParams['font.family'] = 'sans-serif'
matplotlib.rcParams['font.sans-serif'] = ['Segoe UI'] + matplotlib.rcParams['font.sans-serif']
matplotlib.rcParams['font.weight'] = 'normal'

def get_topo_RD(bbox, maxsize, maptype='Topo', typename='Basiskaarten'):
    """
    Function to get world topo map from arcgis WMTS

    Parameters
    ----------
    bbox : tuple
        Extent in EPSG:28992, (left, bottom, right, top)
    maxsize : int
        Maximum image size. Depending on the bbox, the image is limited
        horizontally or vertically.
        
    maptype : string
        Name of the map you want to use options:
            Topo : Topomap --> typename = Basiskaarten
            Open_Topo : Opentopemap --> typename = Basiskaarten
            Canvas_Referentie : lightgrey with reference labels --> typename = Basiskaarten
            Canvas : ligthgrey --> typename = Basiskaarten
            Luchtfoto : Satelite  --> typename = Luchtfoto
    
    typename : string
        Name of the server where the maptype is located
            Basiskaarten or Luchtfoto
            more options see: https://services.arcgisonline.nl/arcgis/rest/services
    """
    
    # Determine imagesize to request
    size = np.array([bbox[2] - bbox[0], bbox[3] - bbox[1]])
    size = size / float(np.max(size)) * maxsize
    size = np.round(size).astype(int)

    # Create url
    url = (
        'https://services.arcgisonline.nl/arcgis/rest/services/{typename}/{maptype}/MapServer/'
        'export?bbox={xmin}%2C+{ymin}%2C+{xmax}%2C+{ymax}&bboxSR=&layers=&layerDefs=&size={sizeX}%2C+{sizeY}&imageSR=&'
        'format=png&transparent=false&dpi=&time=&layerTimeOptions=&dynamicLayers='
        '&gdbVersion=&mapScale=&rotation=&datumTransformations=&layerParameterValues=&'
        'mapRangeValues=&layerRangeValues=&f=image'
        ).format(xmin=bbox[0], ymin =bbox[1], xmax =bbox[2], ymax = bbox[3], sizeX = size[0], sizeY = size[1], maptype=maptype, typename=typename)

    # Get data
    data = urlretrieve(url)

    # Read with matplotlib
    img = imread(data[0])

    return img

def mpl_bbox(bbox):
    """Concert (left, bottom, right, top) to (left, right, bottom, top), as used by matplotlib."""
    return (bbox[0], bbox[2], bbox[1], bbox[3])

## Hier begint het echte script

# Kleurenlijst met 9 kleuren: eentje voor elke windsnelheid
color_list = ['green', 'red', 'deepskyblue', 'magenta', 'olive', 'darkblue', 'darkorange', 'gold', 'blueviolet']

parent_dir = Path(__file__).resolve().parent.parent
print(f'we werken in {parent_dir}')
workdir = os.path.join(parent_dir,'NWM')

watersystemen = ['vrm']

#algemene informatie
NBPW = gpd.read_file(os.path.join(workdir,
                                  r'database_figuren_meren/GIS/voorbeeldbestand_nationaalBestandPrimaireWaterkeringen.shp'))  
Up_all = [0,10,16,22,27,32,37,42,47]
# D_all  = [23, 45, 68, 90, 113, 135, 158, 180, 203, 225, 248, 270, 293, 315, 338, 360]
D_all  = [22.5, 45.0, 67.5, 90.0, 112.5, 135.0, 157.5, 180.0, 202.5, 225.0, 247.5, 270.0, 292.5, 315.0, 337.5, 360.0]

for watsys in watersystemen:
    if watsys == 'grev':
        filters     = ['unfiltered', 'filtered']
        trajecten   = ['25-4', '26-4', '214', '216']
        len_filter  = [2, 2, 2, 2]
        lim_grad    = [0.1, 0.1, 0.1, 0.1]
        dict_len    = dict(zip(trajecten, len_filter))
        dict_grad   = dict(zip(trajecten, lim_grad))
        #koppeltabel
        locdata     = pd.read_csv(os.path.join(workdir,
                                               r'database_figuren_meren/input_generalmodeldata/GREV/GREV_koppeltabel_v2022_06_10.csv'), sep=';')
        #Meerpeilen
        MM_all      = [-0.3,-0.15,0.0,+0.15,+0.3,+0.45,+0.6,0.75] 
        #xlabel figuren
        xlabel      = 'Meerpeil Grevelingen [m+NAP]'
    
    if watsys == 'vrm':
        # filters     = ['unfiltered', 'filtered']
        # trajecten   = ['11-3','227', '8-5', '8-6', '8-7', '205', '45-3']
        filters     = ['unfiltered','filtered']
        trajecten   = ['hoge gronden Veluwerandmeren',
                       'extra locaties Veluwerandmeren',
                       ]
        len_filter  = [2, 0]#[2, 2, 2, 2, 2, 2, 2, 2, 0]
        lim_grad  = [0.1, 0]#[0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0]
        dict_len    = dict(zip(trajecten, len_filter))
        dict_grad   = dict(zip(trajecten, lim_grad))
        #koppeltabel
        locdata     = pd.read_csv(os.path.join(workdir,
                                               r'database_figuren_meren/input_generalmodeldata/VRM/VRM_koppeltabel_v2026_04_20.csv'), sep=';')
        #Meerpeilen
        MM_all      = [-0.4,-0.2,0.0,+0.2,+0.4,+0.8,+1.2,+1.6,+2.0,+2.4] 
        #xlabel figuren
        xlabel      = 'Meerpeil Veluwerandmeren [m+NAP]'

    if watsys == 'vzm':
        filters     = ['unfiltered', 'filtered']
        trajecten   = ['215','25-3','216','217', '27-4', '27-3', '219', '31-3', '223', '33-1', '34-5', '34-4', '34-3']
        len_filter  = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
        lim_grad    = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
        dict_len    = dict(zip(trajecten, len_filter))
        dict_grad   = dict(zip(trajecten, lim_grad))
        #koppeltabel
        locdata     = pd.read_csv(os.path.join(workdir,
                                               r'database_figuren_meren/input_generalmodeldata/VZM/VZM_koppeltabel_v2022_01_07.csv'), sep=';')
        #Meerpeilen
        MM_all      = [-0.3,-0.15,0.0,+0.15,+0.3,+0.45,+0.6,0.75] 
        #xlabel figuren
        xlabel      = 'Meerpeil Volkerak-Zoommeer [m+NAP]'

    if watsys == 'mm':
        filters     = ['unfiltered', 'filtered']
        trajecten   = ['13-7','13-8','13-9','13b-1', '46-1', '44-2', '45-2', '205', '8-1', '8-2', '8-3', '204a']
        len_filter  = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
        lim_grad    = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
        dict_len    = dict(zip(trajecten, len_filter))
        dict_grad   = dict(zip(trajecten, lim_grad))
        #koppeltabel
        locdata     = pd.read_csv(os.path.join(workdir,
                                               r'database_figuren_meren/input_generalmodeldata/MM/MM_koppeltabel_v2022_01_21.csv'), sep=';')
        #Meerpeilen
        MM_all      = [-0.3,-0.15,0.0,+0.15,+0.3,+0.45,+0.6,0.75] 
        #xlabel figuren
        xlabel      = 'Meerpeil Markermeer [m+NAP]'
    
    plt.ioff()
    
    for filt in filters:
        for traject in trajecten:
            if filt == 'filtered':
                database_path   = os.path.join(workdir, 
                                               "database_figuren_meren", 
                                               f"DHYDRO_{watsys}_results", 
                                               "Normtrajectdata", 
                                               f"{traject}",
                                               f"Waterlevels_Database_grad{dict_grad[traject]}_bakje{dict_len[traject]}_Filtered_{traject}.csv")
                figdir          = os.path.join(workdir, 
                                               "database_figuren_meren", 
                                               f"DHYDRO_{watsys}_results", 
                                               "Figuren", 
                                               "Locatiefiguren", 
                                               f"{traject}_grad{dict_grad[traject]}_bakje{dict_len[traject]}_filtered")
            elif filt == 'unfiltered': 
                database_path   = os.path.join(workdir, 
                                               "database_figuren_meren", 
                                               f"DHYDRO_{watsys}_results", 
                                               "Normtrajectdata", 
                                               f"{traject}",
                                               f"Waterlevels_Database_{traject}.csv")
                figdir          = os.path.join(workdir, 
                                               "database_figuren_meren", 
                                               f"DHYDRO_{watsys}_results", 
                                               "Figuren", 
                                               "Locatiefiguren", 
                                               f"{traject}_unfiltered") 
            
            data = pd.read_csv(database_path, sep=',')       
            
            #maak map voor figuren
            if not os.path.exists(figdir):
                os.makedirs(figdir)
           
            D_loop = D_all
            M_vals = MM_all
            
            
            ylims0 = np.array([+999.0,-999.0])
            b = 1
            locdata2 =locdata.loc[locdata['normtraject']==traject]
            print('Er gaan {} figuren gemaakt worden voor traject {} ({})'.format(len(locdata), traject, filt))
            for iloc in tqdm(np.arange(0,len(locdata2),1)) :
                
            #   Om specifieke figuur te plotten...
            #    if not iloc in [115, 116]:
            #        continue
                
                dhydroloc  = locdata2['Name'].iloc[iloc]
                
                #print('Bezig met locatie {}, figuur {} van {}'.format(waqualoc, b, numfigs))
                ylims0[0] = 5
                ylims0[1] = 5
                bedlevel  = np.round(locdata2['bedlevel'].iloc[iloc],2)
            #    print('bedlevel: {}'.format(bedlevel))
                
                set_ylims_on_data = True
                if max(ylims0) != +999 and min(ylims0) != -999 :
                    set_ylims_on_data = False
            
                figrows = 4
                figcols = 5
                fig, axs = plt.subplots(figrows,figcols,figsize=(45/2.54, 35/2.54))
            
                figname1  = dhydroloc
                            
                ylims=ylims0.copy()
                
                for idx in np.arange(0,len(D_loop),1) :
            
                    Di = D_loop[idx]
            
                    # Zorg voor een voorloopnul in de naam van de afvoerniveaus
                    figtit  = 'D{}'.format(Di)
                    #print('Figuurtitel: {}'.format(figtit))
                    
                    if idx < 4 :
                        sp_row = 0
                        sp_col = idx
                    elif 3 < idx < 8:
                        sp_row = 1
                        sp_col = idx - 4 
                    elif 7 < idx < 12:
                        sp_row = 2
                        sp_col = idx - 8
                    else :
                        sp_row = 3
                        sp_col = idx - 12
                    
                    ax = axs[sp_row][sp_col]
            
                    # count max13 nan's per subplot
                    countrep = 0 
                    countnan = 0 
                    
                    for ii,Ui in enumerate(Up_all) :
            
                        WSvals = []
                        # de trackers volgen de reparaties die worden gedaan wanneer er een nanwaarde is.
                        reptracker = []
                        nantracker = []
                        # zorg dat bij U00 gebruik wordt gemaakt van de som met D360
                        if Ui == 'U00':
                            somid_D = 'D360'
                        else:
                            somid_D = Di
            
                        filterinfDataframe = data[(data['U'] == Ui) & (data['D'] == Di)][['M', dhydroloc]].sort_values(by=['M'])
                        WS = filterinfDataframe[dhydroloc]
                        # print(WS)
                        # bepalen min/max in data
                        ylims[0] = min(min(WS),ylims[0])
                        ylims[1] = max(max(WS),ylims[1])
                        
                        ax.plot(filterinfDataframe['M'], WS, label=Ui, marker='.', color=color_list[ii])
            
                    ax.axhline(y=bedlevel,xmin=-2,xmax=3,color='k',ls='--',lw=1,label='bodem')
            
                    ylims[0] = np.floor(ylims[0])
                    ylims[1] = np.ceil (ylims[1])            
                    #print('ylims: ', ylims)                
            
                    ax.set_title(figtit)
                    ax.set_ylabel('Lokale waterstand [m+NAP]')
                    ax.set_xlabel(xlabel)
            
                    if sp_row==0 and sp_col==0 :
                        ax.legend(ncol=2)
                        #pas de kleuren van de markers (laatste handle) aan
                        #leg = ax.get_legend()
                        #leg.legendHandles[-1].set_color('black')
                        
                        legend1 = ax.legend(loc='best', ncol=2, edgecolor='black', fontsize = 9, handletextpad=0.2, borderpad=0.6, handlelength=1.5 )
                        legend1.get_frame().set_linewidth(0.5)
                        #legend1.set_title('Windsnelheid',prop={'size':9, 'weight':'bold'})
                        legend1.set_title('Windsnelheid')
                        legend1._legend_box.align='left' 
            
                    for idx in np.arange(0,len(D_loop),1) :
                        if idx < 4 :
                            sp_row = 0
                            sp_col = idx
                        elif 3 < idx < 8:
                            sp_row = 1
                            sp_col = idx - 4
                        elif 7 < idx < 12:
                            sp_row = 2
                            sp_col = idx - 8
                        else :
                            sp_row = 3
                            sp_col = idx - 12
                        ax = axs[sp_row][sp_col]
                        if max(ylims) > -10 :
                            # voorkomen dat ylims worden gezet voor nan ylims
                            ax.set_ylim(ylims)
                        if (np.isnan(ylims[0]) & np.isnan(ylims[0]) ) :
                            # oplossen voor uitzonderlijke situatie dat een locatie geen data heeft (nan's)
                            ylims = np.array([+999.0,-999.0])
                        ax.set_xlim(min(M_vals)-0.1,max(M_vals)+0.1)
                        major_yticks = np.arange(ylims[0],ylims[1]+1  ,1)
                        minor_yticks = np.arange(ylims[0],ylims[1]+1/4,1/2)
                        ax.set_yticks(major_yticks)
                        ax.set_yticks(minor_yticks, minor=True)
                        ax.grid(which='minor', alpha=0.1)
                        ax.grid(which='major', alpha=0.3)                  
            
               # map met locatie toevoegen
                locx = locdata2['x'][locdata2['Name']==dhydroloc].values[0]
                locy = locdata2['y'][locdata2['Name']==dhydroloc].values[0]
            
                mapax = axs[3][4]
                fig.delaxes(axs[0][4])
                fig.delaxes(axs[1][4])
                fig.delaxes(axs[2][4])
            
                mapax.set_title(dhydroloc)
                fs   = 11
                xpos = 0
                
                # check whether NVNBPW.loc[NBPW.TRAJECT_ID==traject] is not empty if so plot the shape otherwise skip plotting the shape
                if not NBPW.loc[NBPW.TRAJECT_ID==traject].empty:
                    NBPW.loc[NBPW.TRAJECT_ID==traject].plot(ax=mapax, color='#dd1c77', linewidth=1.2, zorder=1)

                # Bepaal grenzen van shape
                #minx, miny, maxx, maxy = traject.geometry.total_bounds
                # Extra ruimte rondom grenzen
                ws = 1500
                # Bounding box voor kaartje
                BBOX = (locx - ws, locy - ws, locx + ws, locy + ws)
                box1 = box(*BBOX)
                
                # Zet achtergrondkaartje, laatste getal bepaalt kwaliteit van plaatje
                kaart = get_topo_RD(BBOX, 500)
                mapax.imshow(kaart, extent=mpl_bbox(box1.bounds), interpolation='lanczos', alpha=1.0)
                mapax.set_xlim([BBOX[0], BBOX[2]])
                mapax.set_ylim([BBOX[1], BBOX[3]])    
                mapax.get_xaxis().set_visible(False)
                mapax.get_yaxis().set_visible(False)                     
                mapax.plot(locx, locy, marker='o', ms=4, linewidth=0.2, color='yellow', zorder=2, markeredgecolor='k', label='Locatie')
                #mapax.text(xpos, -0.10, 'dhydroloc: {}'.format(dhydroloc), verticalalignment='center', horizontalalignment='left', transform=mapax.transAxes, color='black', fontsize=fs)
                #mapax.text(xpos, -0.20, 'hydraloc: {}'.format(hydraloc), verticalalignment='center', horizontalalignment='left', transform=mapax.transAxes, color='black', fontsize=fs)
                mapax.text(xpos, -0.10, 'bodemhoogte oeverlocatie: {0: .2f} m+NAP'.format(bedlevel), verticalalignment='center', horizontalalignment='left', transform=mapax.transAxes, color='black', fontsize=fs)
                
                # opslaan figuur
                plt.tight_layout()
            #        print(BBB)   
            
                
                filename1 = os.path.join(figdir,'id{:03d}_{}.png'.format(iloc,figname1))
                fig.savefig(filename1, dpi=100)
            #            print(filename1)
            #            if not set_ylims_on_data :
            #                # dan niet nodig om dit extra figuur tbv vergelijking Kao/Ksr te maken
            #                filename2 = os.path.join(figdir,'idx{:03d}_{}.png'.format(iloc,figname2))
            #                fig.savefig(filename2, dpi=150)
            ##                print(filename2)
            
                plt.close(fig)
                b +=1
            #            if b == 5:
            #                break
            
