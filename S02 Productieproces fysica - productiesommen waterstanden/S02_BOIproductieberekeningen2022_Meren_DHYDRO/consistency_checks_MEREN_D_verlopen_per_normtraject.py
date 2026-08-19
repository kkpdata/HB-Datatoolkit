# -*- coding: utf-8 -*-
"""
Project     : PR4539.10
Description : Consistency checks Meren

"""

import os
import pandas as pd
import glob
import re
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import gc

#%%

#ws           = 'grev'
ws           = 'vrm'
#ws           = 'vzm'

fs = 12 # base fontsize 


if 'vrm' in ws :
    workdir      = r'p:\project\2262_Productiesommen_Veluwerandmeren\consistency_checks\output_python_versie01'    
    tables_path  = os.path.join(workdir,'tables_versie01')
    ymin, ymax = -5, 7
    trajecten = ['011-03','vk0227','008-05','008-06','008-07','vk0205','045-03']
    koptabfile = r'p:\project\2262_Productiesommen_Veluwerandmeren\consistency_checks\output_python_versie01\VRM_koppeltabel_v2022_01_07.csv'


koptab = pd.read_csv(koptabfile, sep=',')
#koptab = pd.read_excel(koptabfile, sheet_name='koppeltabel')

# figdirs aamaken
for nt in trajecten :
    figdir = os.path.join(workdir,'consistency','nt_'+nt)
    if not os.path.exists(figdir):
        os.makedirs(figdir)
    
csvFileList = glob.glob(os.path.join(tables_path,'statdata*.csv'))

lw=1.5

for i, csvfile in enumerate(csvFileList) :

    #if i<1280 :
    #if i>10 :
    #    continue
    
    # get somid
    somid=csvfile.split('_')[-1]
    somid=somid.split('.')[0]

    # Load station data
    print('load station data from csv for {}'.format(somid))
    stationdata = pd.read_csv(os.path.join(tables_path, 'statdata_{}.csv'.format(somid)),sep=';')
    stationdata.rename({'index_left':'Name'},inplace = True,axis=1) 
    stationdata.reset_index()
    stationdata.set_index('Name', inplace=True)

    # loop over normtrajecten en figuren maken
    for nt in trajecten :

        figdir = os.path.join(workdir,'consistency','nt_'+nt)
    
        fig, ax = plt.subplots(figsize=(25/2.54, 12.5/2.54))
    
        for typ in ['HRbasis','HRbackup','HRterugval']:
    
            if 'HRbasis' in typ :
                idx = stationdata[stationdata.index.str.contains(re.compile(nt+'.+'+typ))].index
            else :
                # koppeling op basis van oeverlocaties
                idx = koptab['Name'][koptab['Name'].str.contains(re.compile(nt+'.+'+'HRbasis'))].index
                if 'HRbackup' in typ :
                    idx = koptab['naam_backup'][idx]
                elif 'HRterugval' in typ :
                    idx = koptab['naam_as'][idx]
            
            xwaarden = np.arange(len(idx))
        
            y_bedlevel   = stationdata.loc[idx,'bedlevel']
            y_min        = stationdata.loc[idx,'minimum']
            y_min13      = stationdata.loc[idx,'min13']
            y_max        = stationdata.loc[idx,'maximum']
            y_max13      = stationdata.loc[idx,'max13']
            y_wlmaxfou   = stationdata.loc[idx,'wlmaxfou2']
            y_last25     = stationdata.loc[idx,'last25']
        
            y_wlmaxfou[y_wlmaxfou<-100]=np.nan
            y_bedlevel[y_bedlevel<-100]=np.nan
            y_max13   [y_max13   <-100]=np.nan
            y_max     [y_max     <-100]=np.nan
            y_min     [y_min     <-100]=np.nan
                              
            ax.plot(xwaarden,y_max     ,label=typ+' max  '   ,zorder=10 ,linewidth=lw/2)
            ax.plot(xwaarden,y_max13   ,label=typ+' max13'   ,zorder= 5 ,linewidth=2*lw)
        
            if 'HRbasis' in typ :
                xbl = xwaarden
                ybl = y_bedlevel
                yl25 = y_last25
        
            if 'terugval' in typ :
                xtvmin = xwaarden
                ytvmin = y_min

        ax.plot(xbl,ybl       ,label='bedlevel oeverlocatie',color='grey',zorder=0  ,linewidth=lw, 
                marker='.', mfc='grey', mec='grey', ms=6)
        ax.plot(xbl,y_last25  ,label='HRbasis last25'  ,zorder= 5 ,linewidth=lw)
        ax.plot(xtvmin,ytvmin ,label='HRterugval min'  ,zorder= 5 ,linewidth=lw/2, color='brown', linestyle='--')
        
        #ax.plot(xwaarden,y_min     ,label='min'                  ,zorder=0  ,linewidth=lw)
        #ax.plot(xwaarden,y_min13   ,label='min13'                ,zorder=0  ,linewidth=lw)
        #ax.plot(xwaarden,y_wlmaxfou,label='wlmaxfou2'            ,zorder=0  ,linewidth=lw/2)
    
        ax.set_ylim(ymin,ymax)
        ax.grid()
        ax.legend()
        ax.set_title(somid,fontsize=fs)
        ax.set_ylabel('waterstand [m+NAP]', fontsize=fs-1, fontweight='normal')
        #ax.set_xlabel('locatie', fontsize=12, fontweight='bold')
        plt.tight_layout()
        
        fig.savefig(os.path.join(figdir, '{}_{}_{}.png'.format(nt, somid, 'bedlevel_waterstand_basis_backup_terugval')), dpi=150)
        
        plt.close(fig)

        fig.clf()
        plt.close()

        del xwaarden
        del y_bedlevel
        del y_min
        del y_min13
        del y_max
        del y_max13
        del y_wlmaxfou
        del y_last25
        
        gc.collect()        
    
    del stationdata
    del somid
    