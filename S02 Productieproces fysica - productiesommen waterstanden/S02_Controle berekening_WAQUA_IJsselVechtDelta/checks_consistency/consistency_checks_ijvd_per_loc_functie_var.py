# -*- coding: utf-8 -*-
"""
Created on  : 24-07-2017
Author      : Andries Paarlberg
Project     : PR3638.10
Description : gebaseerd op Oosterschelde-scripts

"""

import matplotlib
import os

import platform
platf = platform.system()
if platf is not 'Windows' :
    matplotlib.use('Agg')
import getpass
import imp
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from hkvpy.waqua import plots
imp.reload(plots)
from hkvpy import plotting, background
import math

#%%

def plot_vline_with_location(ax,xpos,xposoffset,xlab,xlaboffset,xnam,fs=8,color='gray',yposr=0.05):
    # Add vertical line with location to plot

    ylims = ax.get_ylim()
    xpositie = xpos + xposoffset
    xlabpos = xlab + xlaboffset
    ax.axvline(xpositie,color='gray',zorder=0,linewidth=0.5)
    ax.text(xlabpos,yposr*np.diff(ylims)+ylims[0],xnam,rotation=90, ha='left', va='bottom', fontsize=fs)
#%%

def add_map(ax, loc):
    ax.plot(*loc, marker='o', color='C3')
    ax.set_xlim(128000,228000)
    ax.set_ylim(480000,572000)
    ax.set_aspect('equal')
    plotting.map_axes(ax, color='k')
    background.add(ax)
    return ax

#%% 

def add_shp(ax, shapenm, lw=0.5):
    
    import geopandas as gpd
    import descartes
    
    bgshape = gpd.GeoDataFrame.from_file(shapenm)
    bgshape['patch'] = [descartes.patch.PolygonPath(row.geometry) for _, row in bgshape.iterrows()]
    
    patches = []
    for i, row in bgshape.iterrows():
        patches.append(descartes.patch.PathPatch(bgshape.iloc[i].patch))
    
    patch = descartes.patch.PathPatch(bgshape.iloc[0].patch, fill=False, linewidth=lw)
    ax.add_patch(patch)
    return ax
    
#%%

def lees_shapefile(fname) :
    import shapefile as shp
    shpx=[]
    shpy=[]
    test = shp.Reader(fname)
    for sr in test.shapeRecords():
        for xNew,yNew in sr.shape.points:
            shpx.append(xNew)
            shpy.append(yNew)
    return shpx,shpy

#%%
user = getpass.getuser()

print('user={}'.format(user))

if user == 'paarlberg':
    workdir         = r'd:\HKV\pr3707\python\consistency_checks'    
    tables_path     = os.path.join(workdir,'tables','csv')
    figdir          = os.path.join(workdir,'figs_functie_meerpeil_per_locatie')
    hulpdir         = os.path.join(workdir,'hulpbestanden')
    locdata         = pd.read_excel(os.path.join(figdir,'data','locaties.xlsx'),sheetname='Sheet1')
    IJVDlocaties    = pd.read_excel(os.path.join(hulpdir,'IJVDlocaties.xlsx'),sheetname='IJVDlocaties')
    IJVDlocaties.set_index('Name', inplace=True)
elif user == 'daggenvoorde':
    workdir         = r'd:\3707 - SSC campus rekenomgeving testen\Consistency_Checks'    
    tables_path     = r'd:\3707 - SSC campus rekenomgeving testen\tables_csv_complete'
    figdir          = r'd:\3707 - SSC campus rekenomgeving testen\Consistency_Checks\figuren\figs_functie_meerpeil_per_locatie'
    hulpdir         = r'd:\3707 - SSC campus rekenomgeving testen\Consistency_Checks\hulpbestanden'
    locdata         = pd.read_excel(os.path.join(hulpdir,'locaties.xlsx'),sheetname='Sheet1')
    IJVDlocaties    = pd.read_excel(os.path.join(hulpdir,'IJVDlocaties.xlsx'),sheetname='IJVDlocaties')
    IJVDlocaties.set_index('Name', inplace=True)
elif user.startswith('mp') :
    workdir         = r'/data/computations/python/consistency_checks'
    tables_path     = r'/data/computations/hr2017_wda/output/tables_csv_complete_n8892'
    figdir          = os.path.join(workdir,'figs_functie_meerpeil_per_locatie')
    hulpdir         = os.path.join(workdir,'hulpbestanden')
    locdata         = pd.read_excel(os.path.join(hulpdir,'locaties.xlsx'),sheetname='Sheet1')
    IJVDlocaties    = pd.read_excel(os.path.join(hulpdir,'IJVDlocaties.xlsx'),sheetname='IJVDlocaties')
    IJVDlocaties.set_index('Name', inplace=True)
else:
    print('user unknown')

if not os.path.exists(figdir):
    os.makedirs(figdir)

QQ_all = ['Q0100','Q0500','Q0950','Q1400','Q1850','Q2300','Q2750','Q2975','Q3200','Q3400','Q3600','Q3800','Q4000']
MM_all = ['Mn040','Mn010','Mp040','Mp090','Mp130','Mp150']
Up_all = ['U00','U10','U16','U22','U27','U32','U37','U42','U47']
D_all  = ['D225','D247','D270','D292','D315','D337','D360']
K_all  = ['Ksr' ,'Kao' ]

varX = 'M' # of Q

#%%

# per keringtoestand
# per meerpeil
# per afvoer
# 7x windrichting
# in ieder figuur windsnelheid

K_loop = K_all
Q_loop = QQ_all #['Q1850']# ['Q0100','Q0500', 'Q1850','Q2750','Q3200','Q4000']
M_loop = MM_all
M_vals = [-0.4,-0.1,+0.4,+0.9,+1.3,+1.5]
D_loop = D_all
#K_loop = K_loop[0]
#Q_loop = Q_loop[0]
#M_loop = M_loop[0]

numfigs = len(K_loop)*len(Q_loop)*len(locdata)*2
print('Er gaan {} sommen geplot worden'.format(numfigs))

shapenm = os.path.join(hulpdir,'thin_dams_edit2_pol_interior.shp')
#ext_x,ext_y = lees_shapefile(shapenm)

ylims0 = np.array([+999.0,-999.0])
b = 1
for iloc in np.arange(0,len(locdata),1) :
    
    #Om specifieke figuur te plotten...
#    if not iloc in [9, 56, 65, 41]:
#        continue
    print('Bezig met figuur {} van de {}'.format(b,numfigs))
    waqualoc  = locdata['waquanaam'].loc[iloc]
    hydraloc  = locdata['hydranaam'].loc[iloc]
    ylims0[0] = locdata['ylims0'].loc[iloc]
    ylims0[1] = locdata['ylims1'].loc[iloc]
    bedlevel  = np.round(IJVDlocaties['bedlevel'].loc[waqualoc],2)
#    print('bedlevel: {}'.format(bedlevel))
    
    set_ylims_on_data = True
    if max(ylims0) != +999 and min(ylims0) != -999 :
        set_ylims_on_data = False
    
    for Ki in K_loop :
    
        for Qi in Q_loop :
    
            figrows = 2 # windrichtingen
            figcols = 4
            fig, axs = plt.subplots(figrows,figcols,figsize=(30/2.54, 20/2.54))
    
            figname1  = '{}_{}{}'.format(waqualoc,Ki,Qi)
            figname2  = '{}_{}{}'.format(waqualoc,Qi,Ki)
                        
            ylims=ylims0.copy()
#            print(ylims)
            
            for idx in np.arange(0,len(D_loop),1) :
    
                Di = D_loop[idx]
                
                print('{}{}{}'.format(Ki,Qi,Di))
                
                if idx < 4 :
                    sp_row = 0
                    sp_col = idx
                else :
                    sp_row = 1
                    sp_col = idx-4
                
                ax = axs[sp_row][sp_col]
                
                figtit  = '{}{}{}'.format(Ki,Qi,Di)

                # count max13 nan's per subplot
                countrep = 0 
                countnan = 0 
                
                for Ui in Up_all :
    
                    WSvals = []
                    # de trackers volgen de reparaties die worden gedaan wanneer er een nanwaarde is.
                    reptracker = []
                    nantracker = []
                    # zorg dat bij U00 gebruik wordt gemaakt van de som met D360
                    if Ui == 'U00':
                        somid_D = 'D360'
                    else:
                        somid_D = Di

                    for Mi in M_loop :
                    
                        somid = '{}{}{}{}{}'.format(Ki,Mi,Qi,Ui,somid_D)
                        #print(somid)
                        
                        Qstr = somid[8:13]
                        Ustr = somid[13:16]
                        Qijssel = float(Qstr[1:])
                        if ( Qijssel <= 2300 ) and ( Ustr == 'U00' ) :
                            typ = 'last25'
                        else:
                            typ = 'max13'
                        
                        fname = os.path.join(tables_path,'statdata_{}.csv'.format(somid))
                        stationdata = pd.read_csv(fname,sep=';')
                        stationdata.set_index('Name', inplace=True)
                        nanmax_dta = stationdata['NANMAX']
                        nanmax_dta_loc = nanmax_dta.loc[waqualoc]
                        zwl_dta = stationdata[typ]
                        zwl_max = zwl_dta.loc[waqualoc]
                        
                        # afwaaiing, geen max13, neem maximum, geldt alleen op meren (IJsselmeer [YM], Ketelmeer [KM] of Zwartemeer [ZM])
                        if ((nanmax_dta_loc == 5) & (Ustr != 'U00') & (waqualoc.split('_')[0] in ['YM','KM','ZM'])):
                            zwl_dta = stationdata['maximum']
                            zwl_max = zwl_dta.loc[waqualoc]
                            #tel en track de reparaties zodat ze geplot kunnen worden in de figuren.
                            countrep+=1
                            reptracker.append(zwl_max)
                            nantracker.append(np.nan)
                        #als geen afwaaiing en toch nan de nan-waardes in de reeksen voor het maximum, dit wordt ook gedaan in de databases
                        elif math.isnan(zwl_max):
                            zwl_dta = stationdata['maximum']
                            zwl_max = zwl_dta.loc[waqualoc]
                            #tel en track de nan-waardes zodat ze geplot kunnen worden in de figuren.
                            countnan+=1
                            nantracker.append(zwl_max)
                            reptracker.append(np.nan)
                        else:
                            reptracker.append(np.nan)
                            nantracker.append(np.nan)
                        
                        WSvals.append(zwl_max)
                        
                        
                        
                        if set_ylims_on_data and not math.isnan(zwl_max):
                            # bepalen min/max in data
                            ylims[0] = min(zwl_max,ylims[0])  #minimum bepalen met de maximale waterstand werkt niet heel mooi...
                            ylims[1] = max(zwl_max,ylims[1])
                            #print(zwl_max,ylims[0],ylims[1])
                        
                        # ook "tegengestelde" keringensituatie om assen gelijk te houden
                        if Ki == 'Ksr' :
                            Ki2 = 'Kao'
                        elif Ki == 'Kao' :
                            Ki2 = 'Ksr'
                        somid2 = '{}{}{}{}{}'.format(Ki2,Mi,Qi,Ui,somid_D)
                        fname = os.path.join(tables_path,'statdata_{}.csv'.format(somid2))
                        stationdata2 = pd.read_csv(fname,sep=';')
                        stationdata2.set_index('Name', inplace=True)
                        dta2 = stationdata2[typ]
                        zwl_max2 = dta2.loc[waqualoc]

                        # bepalen min/max in data
                        #ylims[0] = min(zwl_max2,ylims[0])
                        #ylims[1] = max(zwl_max2,ylims[1])
                            
                        
                    
                    ax.plot(M_vals,WSvals,label=Ui,marker='x')
                    ax.scatter(M_vals,reptracker,marker='o',label="afw" if Ui == 'U47' else "")   #plot een andere marker in het geval dat er replacement is toegepast
                    ax.scatter(M_vals,nantracker,marker='^',label="nan" if Ui == 'U47' else "")   #plot een andere marker in het geval dat er replacement is toegepast
                    #ax.plot(ijssel_km, zwl_t1,label='fase1b',marker='x')

                ax.text(0.97, 0.06, '#nan: {}'.format(str(countnan)), verticalalignment='bottom', horizontalalignment='right', transform=ax.transAxes, color='black', fontsize=10)
                ax.text(0.97, 0.01, '#afw: {}'.format(str(countrep)), verticalalignment='bottom', horizontalalignment='right', transform=ax.transAxes, color='black', fontsize=10)
                ax.axhline(y=bedlevel,xmin=-2,xmax=3,color='black',ls=':',lw=2,label='bed')
                #print(str(countnan))
                    
                if sp_row==0 and sp_col==0 :
                    ax.legend(ncol=2)
                    #pas de kleuren van de markers (laatste twee handles) aan
                    leg = ax.get_legend()
                    leg.legendHandles[-1].set_color('black')
                    leg.legendHandles[-2].set_color('black')
                    leg.legendHandles[-3].set_color('black')
                ax.set_title(figtit)
                ax.set_ylabel('lokale waterstand [m+NAP]')
                ax.set_xlabel('waterstand IJsselmeer [m+NAP]')
            # goed zetten y-as, per figuur
            
            ylims[0]=np.floor(ylims[0])
            ylims[1]=np.ceil (ylims[1])
            
            print('ylims: ',ylims)
            
            for idx in np.arange(0,len(D_loop),1) :
                if idx < 4 :
                    sp_row = 0
                    sp_col = idx
                else :
                    sp_row = 1
                    sp_col = idx-4
                ax = axs[sp_row][sp_col]
                if max(ylims) > -10 :
                    # voorkomen dat ylims worden gezet voor nan ylims
                    ax.set_ylim(ylims)
                ax.set_xlim(min(M_vals)-0.1,max(M_vals)+0.1)
                major_yticks = np.arange(ylims[0],ylims[1]+1  ,1)
                minor_yticks = np.arange(ylims[0],ylims[1]+1/4,1/2)
                ax.set_yticks(major_yticks)
                ax.set_yticks(minor_yticks, minor=True)
                ax.grid(which='minor', alpha=0.3)
                ax.grid(which='major', alpha=0.8)
            
            # map met locatie toevoegen
            ax = axs[1][3]
            locx = stationdata['x'].loc[waqualoc]
            locy = stationdata['y'].loc[waqualoc]
            ax = add_map(ax, (locx,locy))
            ax = add_shp(ax, shapenm)

            ax.set_title('{}{}'.format(Ki,Qi))
            fn = 'Arial'
            ff = 'serif'
            fs = 11
            xpos = 0
            ax.text(xpos, -0.10, 'waqualoc: {}'.format(waqualoc), verticalalignment='center', horizontalalignment='left', transform=ax.transAxes, color='black', fontsize=fs, fontname=fn, family=ff)
            ax.text(xpos, -0.20, 'hydraloc: {}'.format(hydraloc), verticalalignment='center', horizontalalignment='left', transform=ax.transAxes, color='black', fontsize=fs, fontname=fn, family=ff)
            ax.text(xpos, -0.30, 'bedlevel: {} m+NAP'.format(str(bedlevel)), verticalalignment='center', horizontalalignment='left', transform=ax.transAxes, color='black', fontsize=fs, fontname=fn, family=ff)
            
            # opslaan figuur
            plt.tight_layout()

            #print(BBB)
            
            filename1 = os.path.join(figdir,'idx{:03d}_{}.png'.format(iloc,figname1))
            fig.savefig(filename1, dpi=150)
#            print(filename1)
            if not set_ylims_on_data :
                # dan niet nodig om dit extra figuur tbv vergelijking Kao/Ksr te maken
                filename2 = os.path.join(figdir,'idx{:03d}_{}.png'.format(iloc,figname2))
                fig.savefig(filename2, dpi=150)
#                print(filename2)

            plt.close(fig)
            b +=1
#            if b == 5:
#                break
                        
