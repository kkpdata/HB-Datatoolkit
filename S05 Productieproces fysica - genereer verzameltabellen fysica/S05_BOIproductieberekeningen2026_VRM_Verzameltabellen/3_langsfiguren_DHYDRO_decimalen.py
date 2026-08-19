# -*- coding: utf-8 -*-
"""
Created on  : 11-01-2022
Author      : Cees Oerlemans
Project     : PR4539.10 BOI Meren
Description : Gebaseerd op script van Jan Stijnen voor PR4108.10 Vullen databases VIJD

"""

import os
from pathlib import Path
import getpass
# import imp
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from tqdm import tqdm
#from hkvpy_backup.waqua import plots
from matplotlib.ticker import (MultipleLocator, FormatStrFormatter, AutoMinorLocator)
#imp.reload(plots)
    
#%%
plt.ioff()
parent_dir = Path(__file__).resolve().parent.parent
print(f'we werken in {parent_dir}')

workdir = os.path.join(parent_dir,'NWM')

koppeltabellen_dict = {'grev': r'p:\PR\4539.10\Werkmap\NWM\database_figuren_meren\input_generalmodeldata\GREV\grev_koppeltabel_v2022_06_10.csv',
                       'vrm' : os.path.join(workdir,'VRM', 'VRM_koppeltabel_v2022_06_10.csv'),
                       'vzm' : r'p:\PR\4539.10\Werkmap\NWM\database_figuren_meren\input_generalmodeldata\VZM\VZM_koppeltabel_v2022_06_10.csv',
                       'mm'  : r'p:\PR\4539.10\Werkmap\NWM\database_figuren_meren\input_generalmodeldata\MM\MM_koppeltabel_v2022_06_10.csv'}

def plaatjes(ws, traject, lim_grad, max_length, filtered):
    koptabfile = koppeltabellen_dict[ws]
    print(koptabfile)
    if filtered == False: 
        database_path   = os.path.join(workdir,
                                       "database_figuren_meren",
                                       f"DHYDRO_{ws}_results",
                                       "Normtrajectdata",
                                       f"{traject}",
                                       f"Waterlevels_Database_{traject}.csv")
        figdir          = os.path.join(workdir,
                                       "database_figuren_meren",
                                       f"DHYDRO_{ws}_results",
                                       "Figuren",
                                       "Langsfiguren",
                                       f"{traject}_unfiltered") 
    if filtered == True:
        database_path   = os.path.join(workdir,
                                       "database_figuren_meren",
                                       f"DHYDRO_{ws}_results",
                                       "Normtrajectdata",
                                       f"{traject}",
                                       f"Waterlevels_Database_grad{lim_grad}_bakje{max_length}_Filtered_{traject}.csv")
        figdir          = os.path.join(workdir,
                                       "database_figuren_meren",
                                       f"DHYDRO_{ws}_results",
                                       "Figuren",
                                       "Langsfiguren",
                                       f"{traject}_grad{lim_grad}_bakje{max_length}_filtered")
    
   
    koptab = pd.read_csv(koptabfile, sep=';')
    
    # Laden van locaties per traject
    locaties = koptab.loc[koptab['normtraject'] == traject]
    
        
    if not os.path.exists(figdir):
        os.makedirs(figdir)
        
    Results = pd.read_csv(database_path)
        
    bodemhoogten = locaties['bedlevel'].tolist()
    
    # alle stochastcombinaties in de WAQUA-uitvoer database
    UU_all = Results["U"].unique()
    DD_all = Results["D"].unique()
    MM_all = Results["M"].unique()
    
    # Kleurenlijst met 9 kleuren: eentje voor elke windsnelheid
    color_list = ['green', 'red', 'deepskyblue', 'magenta', 'olive', 'darkblue', 'darkorange', 'gold', 'blueviolet']
    
    #%%
    
    def plot_vline_with_location(ax, xpos, xposoffset, xlab, xlaboffset, xnam, fs=8, color='gray', yposr=0.05):
        # Add vertical line with location to plot
    
        if yposr == 0.05 :
            va='bottom'
        elif yposr >= 0.85 :
            va='top'
        ylims    = ax.get_ylim()
        xpositie = xpos + xposoffset
        xlabpos  = xlab + xlaboffset
        ax.axvline(xpositie,color=color,zorder=0,linewidth=0.5)
        ax.text(xlabpos,yposr*np.diff(ylims)+ylims[0],xnam,rotation=90, ha='left', va=va, fontsize=fs)
        
    #%%
    
    def maak_fig_windr(trajectnaam, Results, Mi, D_loop, UU_all):
        """
        Routine die langsfiguren maakt van oeverlocaties, terugvallocaties en aslocaties in meerdere subfiguren
        Er worden 4 deelfiguren gemaakt, met daarin voor 4 windrichtingen de langsfiguren langs een traject.
        Met kleuren is steeds een andere windsnelheid weergegeven.
        
        """
        figrows = 4 # windrichtingen
        figcols = 1
        fig, axs = plt.subplots(figrows, figcols, figsize=(20, 25/2.54))
        
        # naamgeving
        if Mi < 0:
            Mii = 'Mm' + '{:03d}'.format(int(-Mi*100))
        else:
            Mii = 'Mp' + '{:03d}'.format(int(Mi*100))
    
        figname1  = '{}'.format(Mii)
        
        Results = Results[(Results["M"]==Mi)]

        # Lus over de windrichtingen
        for idx in np.arange(0,len(D_loop),1):
    
            Di      = D_loop[idx]
            # naamgeving
            Dii = 'D' + '{:03d}'.format(int(Di))
            ax      = axs[idx]
            txtstr  = 'Normtraject {}'.format(traject)
            figtit  = '{}  -- {}  --  {}'.format(txtstr, Mii, Dii)
            # Initialiseer waarden voor bepaling ylims
            # maxy    = 0
            # miny    = 0
            
            # Lus over alle windsnelheden
            for ix, Ui in enumerate(UU_all):
                
                # naamgeving
                Uii = 'U' + '{:02d}'.format(int(Ui))
                
                as_zwl_max = Results[(Results["D"]==Di) & (Results["U"]==Ui)].iloc[0, 3:].tolist()

                # print(f"vergelijk lengte zwl {np.size(as_zwl_max)}, met bodemhoogte {np.size(bodemhoogten)}")
                
                #handmatige volgnummers trajecten IJburg en hoge gronden Markermeer en Veluwerandmeren
                if trajectnaam == '13a-1':
                    volgnummers = np.arange(1, 45)
                elif trajectnaam == '44-2':
                    volgnummers = np.arange(1, 130)
                elif trajectnaam == 'hoge gronden Veluwerandmeren':
                    # volgnummers = np.arange(1,296)
                    volgnummers = np.arange(1,np.size(bodemhoogten)+1)
                elif trajectnaam == 'hoge gronden Markermeer':
                    volgnummers = np.arange(1,249)
                elif trajectnaam == 'Markermeer':
                    volgnummers = np.arange(1,249)
                else: 
                    volgnummers = [int(float(loc.split('_')[1])) for loc in Results.columns[3:]]
                
                if ix == 0:
                    # Voeg bodemhoogten toe aan elk van de deelfiguren
                    ax.plot(volgnummers, bodemhoogten, color='darkgrey', ls='-', lw=0.8, label='bodemhoogte')
    
                # Plot de waterstanden
                ax.plot(volgnummers, as_zwl_max, color=color_list[ix], marker='.', ms=2, mec='0', lw=2.0, label=Uii)       
                
                # Bepaal de maximale waterstand in een subplot voor ylim
                # temp1 = max(as_zwl_max)
                # temp2 = min(as_zwl_max)
                # if temp1 > maxy:
                #     maxy = temp1
                # if temp2 < miny:
                #     miny = temp2                
            
                # Zet verticale schaal goed op bodemhoogte
                # miny = min( min(bodemhoogten), miny)
                # maxy = max( max(bodemhoogten), maxy)
                
                # Zet verticale schaal vast
                # miny = -1
                # maxy = 5
                ax.set_ylim([miny - 0.2, maxy + 0.2])
            
        
                # Maak plot mooier
          #      major_ticks = np.arange(0, len(as_zwl_max), 1)
          #      ax.set_xticks(major_ticks, minor=True)
                ax.grid(which='minor', alpha=0.4, color='lightgrey', linewidth=0.4)
                ax.grid(which='major', alpha=0.8, color='lightgrey', linewidth=0.6)
          #      ax.tick_params(axis='both', pad=3, which='major', length=5, labelsize=10)
                
                # Label op xaxis per 10 locaties
                ax.xaxis.set_major_locator(MultipleLocator(10))
                ax.xaxis.set_major_formatter(FormatStrFormatter('%d'))
                ax.xaxis.set_minor_locator(MultipleLocator(1))
                ax.set_xlim([0, len(as_zwl_max)-1])
        
                # Voeg een legenda toe, rechts van de bovenste deelfiguur
                if idx == 0 :
                    ax.legend(bbox_to_anchor=(1.04,0.5), loc="center left", borderaxespad=0, handletextpad=0.8, borderpad=0.5)
        
                ax.set_title(figtit)
                ax.set_ylabel('Waterstand [m+NAP]')
                ax.set_xlabel('Locatie volgnummer')
                #ax.invert_xaxis()
            
        #   Opslaan figuur
            plt.tight_layout()
            # Maak een extra label voor in de bestandsnaam voor elk kwadrant aan windrichtingen
            if Di in [360.0, 22.5, 35.0, 67.5]:
                windrichtingen_set = 'D1'
            elif Di in [90.0, 112.5, 135.0, 157.5]:
                windrichtingen_set = 'D2'
            elif Di in [180.0, 202.5, 225.0, 247.5]:
                windrichtingen_set = 'D3'
            else:
                windrichtingen_set = 'D4'

            filename1 = os.path.join(figdir,'{}_{}_{}.png'.format(trajectnaam, figname1, windrichtingen_set))
            
            fig.savefig(filename1, dpi=150)
            
            plt.close(fig)
        
        #%% Aanroepen van plotroutine door over geselecteerde combinaties te lussen
    
        #%% Aanroepen van plotroutine door over geselecteerde combinaties te lussen
    
    M_loop = sorted(MM_all)
    #kwadranten windroos waarvoor plots worden gemaakt
    D_kwadranten = [[360.0, 22.5, 45.0, 67.5], [90.0, 112.5, 135.0, 157.5], [180.0, 202.5, 225.0, 247.5], [270.0, 292.5, 315.0, 337.5]]
    
    teller = 0
    N      = len(M_loop)*len(D_kwadranten)
    print('Er gaan {} figuren geplot worden voor traject {} (filter = {})' .format(N, traject, filt))
    
    for Mi in tqdm(M_loop):
        for D_loop in D_kwadranten:
            maak_fig_windr(traject, Results, Mi, D_loop, sorted(UU_all))
            
#plaatjes(watersysteem, traject, filtered=true/false)
# =============================================================================
# watersysteem = 'grev'
# filters = [False, True]
# trajecten = ['25-4', '26-4']
# len_filter = [2, 2, 2, 2]
# lim_grad = [0.1, 0.1, 0.1, 0.1]
# dict_len = dict(zip(trajecten, len_filter))
# dict_grad = dict(zip(trajecten, lim_grad))
# miny = -1
# maxy = 3

# =============================================================================
watersysteem = 'vrm'
filters = [True, False]
# trajecten = ['hoge gronden Veluwerandmeren', '227', '8-5', '8-6', '8-7', '205', '45-3', '11-3']
trajecten = ['hoge gronden Veluwerandmeren', 'extra locaties Veluwerandmeren']
# trajecten = ['hoge gronden Veluwerandmeren']
len_filter = [2, 2, 2, 2, 2, 2, 2] # LL in oude versie was len_filter voor hogegronden Veluwerandmeren 2, in de analyse was dit 3
lim_grad = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
dict_len = dict(zip(trajecten, len_filter))
dict_grad = dict(zip(trajecten, lim_grad))
miny = -1
maxy = 5.5

# =============================================================================

# watersysteem = 'vzm'
# filters = [False, True]
# trajecten = ['222.5', '215','25-3','216','217', '27-4', '27-3', '219', '31-3', '33-1', '34-5', '34-4', '34-3']
# len_filter = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
# lim_grad = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
# dict_len = dict(zip(trajecten, len_filter))
# dict_grad = dict(zip(trajecten, lim_grad))
# miny = -1
# maxy = 5

# watersysteem = 'mm'
# filters = [True, False]
# trajecten = ['13a-1', '13-7','13-8','13-9','13b-1', '46-1', '44-2', '45-2', '205', '8-1', '8-2', '8-3', '204a', 'hoge gronden Markermeer']
# len_filter = [5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
# lim_grad = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
# dict_len = dict(zip(trajecten, len_filter))
# dict_grad = dict(zip(trajecten, lim_grad))
# miny = -1
# maxy = 5

for filt in filters:
    for traject in trajecten:
        plaatjes(watersysteem, traject, dict_grad[traject], dict_len[traject], filt)
