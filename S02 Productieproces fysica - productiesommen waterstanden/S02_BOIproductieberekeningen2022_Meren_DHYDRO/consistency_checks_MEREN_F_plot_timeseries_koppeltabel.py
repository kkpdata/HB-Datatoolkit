# -*- coding: utf-8 -*-
"""
Project     : PR4539.10
Description : Consistency checks Meren

"""

print('importing modules')
import matplotlib
import os
import platform
platf = platform.system()
if platf != 'Windows' :
    matplotlib.use('Agg')
import sys
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import netCDF4 as nc
import gc
import datetime
print('importing modules finished')

#%%

# figdpi  = 150
# compdir   = 'e:/BOI2023/pr4539_Meren'
# koptabdir = 'd:/HKV/BOI2023/pr4539_Meren/GIS/koppeltabellen/xlsfiles'
# ws        = 'grev'
# Mstr      = 'Mp075'

def plot_timeplots(compdir,koptabdir,ws,Mstr,figdpi,write_log) :
#%%

    if 'grev' in ws :
    
        modelschem   = 'dflowfm2d-grevelingen-hr2023_6-v1a'
        compdir      = os.path.join(compdir,modelschem,'computations/hr/hr2023')    
        koptabfile   = os.path.join(koptabdir,'GREV_koppeltabel_v2022_01_05.csv')
        MM_all = ['Mm030','Mm015','Mp000','Mp015','Mp030','Mp045','Mp060','Mp075']
        M_vals = [-0.3   ,-0.15  ,+0.0   ,+0.15  ,+0.3   ,+0.45  ,+0.6   ,+0.75]
        Up_all = ['U00','U10','U16','U22','U27','U32','U37','U42','U47']
        D_all  = ['D023','D045','D068','D090','D113','D135','D158','D180','D203','D225','D248','D270','D293','D315','D338','D360']
        trajecten    = ['025-04','vk0214','026-04','vk0216']
    
    elif 'vrm' in ws :
    
        modelschem   = 'dflowfm2d-vrm-hr2023_6-v1b'
        compdir      = os.path.join(compdir,modelschem,'computations/hr/hr2023')    
        koptabfile   = os.path.join(koptabdir,'VRM_koppeltabel_v2022_01_07.csv')
        MM_all = ['Mm040','Mm020','Mp000','Mp020','Mp040','Mp080','Mp120','Mp160','Mp200','Mp240']
        M_vals = [-0.4   ,-0.2   ,0.00   ,0.20   ,0.40   ,0.80   ,1.20   ,1.60   ,2.00   ,2.40]
        Up_all = ['U00','U10','U16','U22','U27','U32','U37','U42','U47']
        D_all  = ['D023','D045','D068','D090','D113','D135','D158','D180','D203','D225','D248','D270','D293','D315','D338','D360']
        trajecten = ['011-03','vk0227','008-05','008-06','008-07','vk0205','045-03']
    
    elif 'vzm' in ws :
        
        modelschem   = 'dflowfm2d-vzm-hr2023_6-v1a'
        compdir      = os.path.join(compdir,modelschem,'computations/hr/hr2023')    
        koptabfile   = os.path.join(koptabdir,'VZM_koppeltabel_v2022_01_07.csv')
        MM_all = ['Mp000','Mp015','Mp030','Mp045','Mp060','Mp090','Mp120','Mp150','Mp180','Mp210']
        M_vals = [ +0.00 , +0.15 , +0.30 , +0.45 , +0.60 , +0.90 , +1.20 , +1.50 , +1.80 , +2.10]
        Up_all = ['U00','U10','U16','U22','U27','U32','U37','U42','U47']
        D_all  = ['D023','D045','D068','D090','D113','D135','D158','D180','D203','D225','D248','D270','D293','D315','D338','D360']
        trajecten = ['vk2150','vk2160','vk2170','vk2190','vk2230',
                     '025-03',
                     '027-03','027-04',
                     '031-03',
                     '033-01',
                     '034-03','034-04','034-05']
    
    elif 'mm' in ws :
    
        modelschem   = 'dflowfm2d-markermeer-hr2023_6-v1a'
        compdir      = os.path.join(compdir,modelschem,'computations/hr/hr2023')    
        koptabfile   = os.path.join(koptabdir,'MM_koppeltabel_v2022_01_21.csv')
        MM_all = ['Mm040','Mm020','Mp000','Mp020','Mp040','Mp080','Mp120','Mp160','Mp200','Mp240']
        M_vals = [-0.4   ,-0.2   ,0.00   ,0.20   ,0.40   ,0.80   ,1.20   ,1.60   ,2.00   ,2.40]
        Up_all = ['U00','U10','U16','U22','U27','U32','U37','U42','U47']
        D_all  = ['D023','D045','D068','D090','D113','D135','D158','D180','D203','D225','D248','D270','D293','D315','D338','D360']
        # let op!!, vk204a moet eigenlijk vk204b zijn
        trajecten = ['vk204a','013-07','013-08','013-09','014-02','045-02','vk2050','008-01','008-02']
    
    #%%
    #figdir  = os.path.join(compdir,'output_python','consistency','timeplots')
    figdir  = os.path.join('timeplots',ws,Mstr)
    print('figdir='+figdir)
        
    if not os.path.exists(figdir):
        os.makedirs(figdir)
    
    #write_log = 0    
    logfnm = os.path.join(figdir,'log.txt')
    
    fs=10
    clrs = ['k','b','r']
    
    # inlezen koppeltabel
    # bevat basis, backup en terugvallocatie
    print('inlezen koppeltabel')
    #koptab = pd.read_excel(koptabfile, sheet_name='koppeltabel')
    koptab = pd.read_csv(koptabfile, sep=',')
    locs = koptab.Name.tolist()
    locs = locs + koptab.naam_backup.tolist()
    locs = locs + koptab.naam_as.tolist()
    locs = set(locs)
    #locs = pd.DataFrame(data=locs,index=locs)
    locs = pd.DataFrame(index=sorted(locs))
    
    # inlezen van alle benodigde data
    # names eenmalig inlezen
    print('t, names eenmalig inlezen')
    somid   = ws+Mstr+Up_all[1]+D_all[0]
    hisfile = os.path.join(compdir,somid,'results',somid+'_0000_his.nc')
    ds = nc.Dataset(hisfile)
    t  = ds['time'][:]
    # Lees de namen en converteer naar niet-binaire strings
    print('get names')
    names = ds.variables['station_id'][:]
    names = [''.join(name.astype(str)).strip() for name in names]
    names = np.array(names)
    ds.close()
    
    df_wl_all = np.empty((len(Up_all)-1,len(D_all)),dtype=object)
    
    print('inlezen van alle data')
    # -------------------------
    # inlezen van alle data
    # -------------------------
    for i, Ustr in enumerate(Up_all[1:]) :
        
        #if i>3 :
        #    continue
        
        for j, Dstr in enumerate(D_all[:]) :
    
            #if j>3 :
            #    continue
            
            print(Ustr,Dstr)        
    
            if write_log == 1 :
                if i==0 and j==0 :
                    more_lines = ['', 'inlezen van alle data',Ustr+Dstr]
                else :
                    more_lines = ['', Ustr+Dstr]
                with open(logfnm, 'a') as f:
                    f.writelines('\n'.join(more_lines))
    
            somid   = ws+Mstr+Ustr+Dstr
            hisfile = os.path.join(compdir,somid,'results',somid+'_0000_his.nc')
            
            # get netcdf data
    
            # met onderstaande 'with' is na afloop data 'afgesloten'
            with nc.Dataset(hisfile) as ds:
                wl = ds['waterlevel'][:]
                #wl = ds['waterlevel'][:,[1,5,8]]
            
            #df_wl=pd.DataFrame(data=wl,columns=names[[1,5,8]])
            df_wl=pd.DataFrame(data=wl,columns=names)
            # center True:   gecentreerd windows, dan juiste idxmax
            # min_periods=1: voorkomt nan-waarden aan begin en eind
            wl_rolmean13 = df_wl.rolling(window=13, center=True, min_periods=1, axis=0).mean()

            #CHECK LOPEND GEMIDDELDE
            #fig, ax = plt.subplots(figsize=(20/2.54, 12/2.54))
            #loc = 'GR_25.00'
            #ax.plot(df_wl[loc])
            #ax.ticklabel_format(useOffset=False)  # voorkomen exponent-notitie voor y-as bij vrijwel geen variatie in signaal
            #ax.plot(wl_rolmean13[loc])

            # locaties op y-as matrix    
            df_wl=wl_rolmean13.T
    
            df_wl_all[i,j] = [df_wl]
            
            del df_wl
    
    #print(df_wl_all)
    
    #%%    
    # -------------------------
    # maken figuren
    # -------------------------
    print('maken figuren')
        
    for locidx in np.arange(len(koptab)) :

        if write_log == 1 :
            if i==0 and j==0 :
                more_lines = ['', 'maken van figuren', str(locidx) + ' (' + str(datetime.datetime.now()) + ')']
            else :
                more_lines = ['', str(locidx) + ' (' + str(datetime.datetime.now()) + ')']
            with open(logfnm, 'a') as f:
                f.writelines('\n'.join(more_lines))

        print(locidx)
        #if locidx<20 or locidx>=30:
        #    continue
            
        figname = '{}_{}_{}dpi.png'.format(Mstr,koptab.iloc[locidx]['Name'],figdpi)
        figtit  = '{}____{}____bedlevel:{}'.format(koptab.iloc[locidx]['Name'],Mstr,str(koptab.iloc[locidx]['bedlevel']))
        
        # initialiseer figuur, geen U00
        fig, axs = plt.subplots(len(Up_all)-1,len(D_all),figsize=(60/2.54, 30/2.54)) # rijen x kolommen, widthxheight
        
        # nu de figuren maken per locatie
        for i, Ustr in enumerate(Up_all[1:]) :
            
            #if i>3 :
            #    continue
            
            for j, Dstr in enumerate(D_all[:]) :
        
                #if j>3 :
                #    continue
                
                ax=axs[i,j]
                
                somid   = ws+Mstr+Ustr+Dstr
                
                for nn,loc in enumerate(['Name','naam_backup','naam_as']) :
                    clr = clrs[nn]
                    statname = koptab.iloc[locidx][loc]
                    #idx = [index for index in range(len(names)) if names[index] == statname][0]
                    dta = df_wl_all[i,j][0]
                    #dta = df_wl_all[i,j][:,idx]
                    ax.plot(t, dta.loc[statname], color=clr, lw=0.75)
                
                ax.grid(False)
                # Hide axes ticks
                ax.set_xticks([])
                #ax.set_yticks([])
                
                if i==0 :
                    ax.set_title(Dstr,fontsize=fs-1)
                if j==0 :
                    ax.set_ylabel(Ustr,fontsize=fs-1)
        
                fig.text(0.5, 1-0.01, figtit, ha='center', fontsize=fs, fontweight='bold')
            
        plt.tight_layout()
        fig.savefig(os.path.join(figdir, figname), dpi=figdpi)

        fig.clf()
        plt.close(fig)
        
        # del ds
        # del ax
        # del fig
        # del wl
        # # del df_wl
        # # del hisfile
        # del somid
        # del statname
        # #del wl_rolmean13
        
        gc.collect()
        
#%%    

if __name__ == "__main__":
    
#%%
    args = sys.argv
    
    print('aantal sys.argv: {}'.format(len(args)))
    print('sys.argv:')
    print(args)

    if len(args) > 1 :
        figdpi    = 150
        write_log = 1
        koptabdir = 'koptab_xlsfiles'
        ws        = args[1]
        compdir   = args[2] #'../versie02'
        Mstr      = args[3] #'Mm015'
    else :
        figdpi    = 150
        write_log = 1
        compdir   = 'e:/BOI2023/pr4539_Meren'
        koptabdir = 'd:/HKV/BOI2023/pr4539_Meren/GIS/koppeltabellen/xlsfiles'
        ws        = 'grev'
        Mstr      = 'Mp075'

    print(figdpi)
    print(koptabdir)
    print(ws)
    print(compdir)
    print(Mstr)
    
    plot_timeplots(compdir,koptabdir,ws,Mstr,figdpi,write_log)
    