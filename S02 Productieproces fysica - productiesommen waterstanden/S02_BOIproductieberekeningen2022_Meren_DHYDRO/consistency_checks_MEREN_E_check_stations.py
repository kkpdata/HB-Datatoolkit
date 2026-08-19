# -*- coding: utf-8 -*-
"""
Project     : PR4539.10
Description : Consistency checks Meren
Check stations; compare max_running_mean and max13
"""

import os
import pandas as pd
import glob
import re
import numpy as np
import matplotlib.pyplot as plt

#%%

# ws           = 'grev'
ws           = 'vrm'
# ws           = 'vzm'

writedata = False

print(ws)

if 'vrm' in ws :
    workdir      = r'p:\project\2262_Productiesommen_Veluwerandmeren\consistency_checks\output_python_versie01'    
    tables_path  = os.path.join(workdir,'tables_versie01')
    outdir       = os.path.join(workdir,'consistency')
    trajecten = ['011-03','vk0227','008-05','008-06','008-07','vk0205','045-03']
    #trajecten = ['vk0227']
    koptabfile = r'p:\project\2262_Productiesommen_Veluwerandmeren\consistency_checks\output_python_versie01\VRM_koppeltabel_v2022_01_07.csv'


# inlezen koppeltabel
# bevat basis, backup en terugvallocatie
koptab = pd.read_csv(koptabfile, sep=',')
# koptab = pd.read_excel(koptabfile, sheet_name='koppeltabel')

# locatie voor figuren
#figdir = os.path.join(workdir,'station_analyse')
figdir = os.path.join(os.curdir,'station_analyse')
dtadir = os.path.join(figdir,'data')

# lege lijsten aanmaken
dta_runmax = []
dta_max13  = []
#dta_maxdif = []
dta_instpk = []
somids     = []

# Build dataframe from all simulations
csvFileList = glob.glob(os.path.join(tables_path,'metadata*.csv'))

# loop over alle simulaties
for i, csvfile in enumerate(csvFileList) :

    #if i>10:
    #    continue

    # get somid 
    somid=csvfile.split('_')[-1]
    somid=somid.split('.')[0]
    somids.append(somid)

    # inlezen stationdata    
    fname = os.path.join(tables_path,'statdata_{}.csv'.format(somid))
    stationdata = pd.read_csv(fname,sep=';')
    stationdata.rename({'index_left':'Name'},inplace = True,axis=1) 
    stationdata.reset_index()
    stationdata.set_index('Name', inplace=True)
    
    #runmax_minus_max13 = stationdata['rolmean_max13'] - stationdata['max13']
    
    dta_max13.append( stationdata['max13'].tolist())
    dta_runmax.append(stationdata['rolmean_max13'].tolist())
    dta_instpk.append(stationdata['INSTPK'].tolist())

    if i==0:
        stationdata0 = stationdata.copy()

    del stationdata
    
# maken dataframe om gegevens makkelijk te kunnen gebruiken
df_instpk = (pd.DataFrame(dta_instpk, columns=stationdata0.index, index=somids)).T
df_max13  = (pd.DataFrame(dta_max13 , columns=stationdata0.index, index=somids)).T
df_runmax = (pd.DataFrame(dta_runmax, columns=stationdata0.index, index=somids)).T

df_maxdif = df_runmax - df_max13

if writedata:
    df_max13.to_csv( os.path.join(dtadir,'{}_df_max13.csv'.format(ws)))
    df_instpk.to_csv(os.path.join(dtadir,'{}_df_instpk.csv'.format(ws)))
    df_maxdif.to_csv(os.path.join(dtadir,'{}_df_maxdif.csv'.format(ws)))
    df_runmax.to_csv(os.path.join(dtadir,'{}_df_runmax.csv'.format(ws)))

#%%

# maken figuren
# per normtraject

fs = 12

print('figuren maken per normtraject')

#%%

print('MAXDIF')

# Initiate output-excel
if writedata:
    writer = pd.ExcelWriter(os.path.join(dtadir, '{}_maxdif.xlsx'.format(ws)))

# MAXDIF

# loop over normtrajecten en figuren maken
for nt in trajecten :

    ecol=-6 # for Excel writing

    print(nt)    

    fig, axs = plt.subplots(3,figsize=(25/2.54, 18/2.54))

    sp=-1
    for typ in ['HRbasis','HRbackup','HRterugval']:
        
        ecol = ecol+6  # Excel column control

        sp=sp+1
        
        if 'HRbasis' in typ :
            idx = stationdata0[stationdata0.index.str.contains(re.compile(nt+'.+'+typ))].index
        else :
            # koppeling op basis van oeverlocaties
            idx = koptab['Name'][koptab['Name'].str.contains(re.compile(nt+'.+'+'HRbasis'))].index
            if 'HRbackup' in typ :
                idx = koptab['naam_backup'][idx]
            elif 'HRterugval' in typ :
                idx = koptab['naam_as'][idx]
        
        xwaarden = np.arange(len(idx))+1 # dan is het volgnummer

        ax = axs[sp]
        
        data = df_maxdif.loc[idx]

        dta_quantiles = []
        dta_quantiles.append((data.quantile(axis=1,q=0.99)).tolist())
        dta_quantiles.append((data.quantile(axis=1,q=0.90)).tolist())
        dta_quantiles.append((data.quantile(axis=1,q=0.50)).tolist())
        dta_quantiles.append((data.quantile(axis=1,q=0.10)).tolist())
        df_quantiles = (pd.DataFrame(dta_quantiles,index=['q99','q90','q50','q10'],columns=idx)).T

        if writedata:
            df_quantiles.to_excel(writer, sheet_name='{}'.format(nt),startcol=ecol,startrow=0)

        # plotten
        #ax.plot(xwaarden,data.min (axis=1),label='min' ,linestyle=None,marker='.')
        #ax.plot(xwaarden,data.max     (axis=1)      ,label='max' ,linestyle=None,marker='.')
        ax.plot(xwaarden,df_quantiles['q99'],label='q99' ,linestyle=None,marker='.')
        ax.plot(xwaarden,df_quantiles['q90'],label='q90' ,linestyle=None,marker='.')
        ax.plot(xwaarden,df_quantiles['q50'],label='q50' ,linestyle=None,marker='.')
        ax.plot(xwaarden,df_quantiles['q10'],label='q10' ,linestyle=None,marker='.')
        #ax.plot(xwaarden,data.mean(axis=1),label='mean',linestyle=None,marker='.')
        #ax.set_ylim(ymin,ymax)
        ax.grid()
        if sp==2:
            ax.set_xlabel('volgnummer langs normtraject')
        ax.legend()
        ax.set_title(nt+' '+typ,fontsize=fs)
        #ax.set_ylabel('waterstand [m+NAP]', fontsize=fs-1, fontweight='normal')

        ax.set_xlim(0,xwaarden.max()+1)
        
    # Set common labels
    fig.supylabel('[max_running_mean] minus [max13] (m)' )

    plt.tight_layout()
    fig.savefig(os.path.join(figdir, '{}_nt_{}_maxdif.png'.format(ws,nt)), dpi=150)
    #fig.savefig(os.path.join(figdir, '{}_nt_{}_instpk.png'.format(ws,nt)), dpi=150)
    plt.close(fig)

if writedata:
    writer.save()
    writer.close()

#%%

print('INSTPK')

# INSTKP

# Initiate output-excel
if writedata:
    writer = pd.ExcelWriter(os.path.join(dtadir, '{}_instpk.xlsx'.format(ws)))

# loop over normtrajecten en figuren maken
for nt in trajecten :

    ecol=-6 # for Excel writing
    
    print(nt)    

    fig, axs = plt.subplots(3,figsize=(25/2.54, 18/2.54))

    sp=-1

    for typ in ['HRbasis','HRbackup','HRterugval']:
        
        ecol = ecol+6  # Excel column control
        
        sp=sp+1      # subplot-control
        
        if 'HRbasis' in typ :
            idx = stationdata0[stationdata0.index.str.contains(re.compile(nt+'.+'+typ))].index
        else :
            # koppeling op basis van oeverlocaties
            idx = koptab['Name'][koptab['Name'].str.contains(re.compile(nt+'.+'+'HRbasis'))].index
            if 'HRbackup' in typ :
                idx = koptab['naam_backup'][idx]
            elif 'HRterugval' in typ :
                idx = koptab['naam_as'][idx]
        
        xwaarden = np.arange(len(idx))+1 # dan is het volgnummer

        ax = axs[sp]
        
        data = df_instpk.loc[idx]

        # data['min']  = data.min (axis=1)
        # data['mean'] = data.mean(axis=1)
        # data['max']  = data.max (axis=1)
        # data['q10']  = data.quantile(axis=1,q=0.1)
        # data['q50']  = data.quantile(axis=1,q=0.5)
        # data['q90']  = data.quantile(axis=1,q=0.9)

        data_classes = data.copy()
        data_classes[ (data>0)   ] = -1
        data_classes[ (data==0)  ] = 1
        data_classes[ (data_classes==-1) ] = 0
        c0 = data_classes.sum(axis=1)
        
        data_classes = data.copy()
        data_classes[ (data!= 1) ] = 0
        c1 = data_classes.sum(axis=1)
        
        data_classes = data.copy()
        data_classes[ (data==1)  ] = 0
        data_classes[ (data>=10) ] = 0
        data_classes[ (data_classes>  0) ] = 1
        c2 = data_classes.sum(axis=1)
        
        data_classes = data.copy()
        data_classes[ (data <10) ] = 0
        data_classes[ (data_classes>=10) ] = 1
        c3 = data_classes.sum(axis=1)

        dta = []
        dta.append(c0.tolist())
        dta.append(c1.tolist())
        dta.append(c2.tolist())
        dta.append(c3.tolist())
        df_classes = (pd.DataFrame(dta,index=['c0','c1','c2','c3'],columns=idx)).T
        df_classes['tot'] = df_classes['c0'] + df_classes['c1'] + df_classes['c2'] + df_classes['c3']

        if writedata:
            df_classes.to_excel(writer, sheet_name='{}'.format(nt),startcol=ecol,startrow=0)
        
        # plotten
        #ax.plot(xwaarden,c0,label='#0   ',linestyle=None,marker='.')
        ax.plot(xwaarden,c1,label='c1: #sims met #instpk=1   ',linestyle=None,marker='.')
        ax.plot(xwaarden,c2,label='c2: #sims met #instpk=2-9 ',linestyle=None,marker='.')
        ax.plot(xwaarden,c3,label='c3: #sims met #instpk>=10 ',linestyle=None,marker='.')
        #ax.set_ylim(ymin,ymax)
        ax.grid()
        if sp==2:
            ax.set_xlabel('volgnummer langs normtraject')
            ax.legend()
        ax.set_title(nt+' '+typ,fontsize=fs)
        #ax.set_ylabel('waterstand [m+NAP]', fontsize=fs-1, fontweight='normal')

        ax.set_xlim(0,xwaarden.max()+1)

    # Set common labels
    fig.supylabel('aantal instabiliteiten rond piek (INSTPK)')
    
    plt.tight_layout()
    
    fig.savefig(os.path.join(figdir, '{}_nt_{}_instpk.png'.format(ws,nt)), dpi=150)
    #fig.savefig(os.path.join(figdir, '{}_nt_{}_instpk.png'.format(ws,nt)), dpi=150)
    plt.close(fig)
    
if writedata:
    writer.save()
    writer.close()
