# -*- coding: utf-8 -*-
"""
Project     : PR4539.10
Description : Consistency checks Meren

"""

import os
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import cm

#%%

# kies watersysteem

ws = 'vrm'
#ws = 'vzm'

#%%

if 'vrm' in ws :
    workdir      = r'p:\project\2262_Productiesommen_Veluwerandmeren\consistency_checks\output_python_versie01'    
    tables_path  = os.path.join(workdir,'tables_versie01')
    outdir       = os.path.join(workdir,'consistency')
    
    MM_all = ['Mm040','Mm020','Mp000','Mp020','Mp040','Mp080','Mp120','Mp160','Mp200','Mp240']
    M_vals = [-0.4   ,-0.2   ,0.00   ,0.20   ,0.40   ,0.80   ,1.20   ,1.60   ,2.00   ,2.40]
    Up_all = ['U00','U10','U16','U22','U27','U32','U37','U42','U47']
    # D_all  = ['D023','D045','D068','D090','D113','D135','D158','D180','D203','D225','D248','D270','D293','D315','D338','D360']
    # andere volgorde tbv volgorde subplots:    
    D_all  = ['D338','D360','D315','D023','D293','D045','D270','D068','D248','D090','D225','D113','D203','D135','D180','D158']
    
    ticks_for_labels = np.arange(30,70,5)
    # location for vertical lines
    loc_lines = [26.10,42.70,60.80,68]
    #lab_lines = ['Nijkerkersluis','N302 Harderwijk','Elburgerweg','Reevesluis']
    lab_lines = ['Nijk.sluis','N302 H.wijk','Elb.weg','Reevesluis']
    
    xlims = (25,70)
    ylims = [-2.0, +6.0]
    
    #clr    = ['b','r']
    cmap = cm.get_cmap('tab10', len(Up_all)) # viridis
    clr = cmap(range(len(Up_all)))
    
    #idx  = np.arange(2474,stationdata.shape[0])
    idx  = np.arange(2474,2896) # tot laatste station
    hmp  = np.arange(26.1,68.3,0.1)


#%%

D_loop = D_all
U_loop = Up_all

M_loop = MM_all
M_vals = M_vals

#M_loop = ['Mm030','Mp015','Mp075']
#M_vals = [-0.3   ,+0.15  ,+0.75]
minor_xticks = M_vals

parameters = ['maximum', 'minimum']

# per meerpeil een figuur
for Mi, Ms in enumerate(M_loop) :
    
    figtit = Ms
    
    print('figtit: {}'.format(figtit))    
    
    # opbouwen volgens windrichting
    # totaal 16 windrichtingen
    figrows = 8 
    figcols = 2
    fig, axs = plt.subplots(figrows,figcols,figsize=(35/2.54, 30/2.54))
    
    for Di, Ds in enumerate(D_loop) :
    
        sp_row = int(np.floor(Di/figcols))
        sp_col = int(np.mod(Di/figcols,1)*figcols)
        ax = axs[sp_row][sp_col]
    
        if True :    
        #if ('D045' in Ds) or ('D338' in Ds) :
    
            for Ui, Us in enumerate(U_loop) :
                
                if ('U00' in Us) and ('D360' not in Ds) :
                    continue
                
                somid = '{}{}{}{}'.format(ws,Ms,Us,Ds)
                fname = os.path.join(tables_path,'statdata_{}.csv'.format(somid))
                
                if os.path.exists(fname) : 
                    
                    #print(somid)
                    
                    stationdata = pd.read_csv(fname,sep=';')
                    # TODO, waarom dit nodig is, is niet duidelijk...
                    # somehow in Docker it gets messed up;
                    # has to do with sjoin before writing to Excel?!
                    stationdata.rename({'index_left':'Name'},inplace = True,axis=1) 
                    stationdata.reset_index()
                    stationdata.set_index('Name', inplace=True)

                    data_sel  = stationdata.iloc[idx]
                    
                    data_sel['hm'] = hmp
                    xwaarden  = data_sel['hm']
    
                    # als waarde
                    Dv = float(Ds[1:])
                    Uv = float(Ds[1:])
                    Mv = M_vals[Mi]
    
                    lw=1.5
                    ax.plot(xwaarden,data_sel['maximum'],zorder=0  ,linewidth=lw/1, color=clr[Ui], label=Us)
                    #ax.plot(xwaarden,data_sel['max13']  ,label='max13',zorder= 5 ,linewidth=2*lw)
                    ax.plot(xwaarden,data_sel['minimum'],zorder=0  ,linewidth=lw/2, ls=':', color=clr[Ui])
                    
                    #ax.plot(xvals, yvals, ls='-', color=clr[Ui], marker=marker, mfc=clr[Ui], mec=clr[Ui], ms=ms, label=Us)

    # set figure properties            
    for Di, Ds in enumerate(D_loop) :
        sp_row = int(np.floor(Di/figcols))
        sp_col = int(np.mod(Di/figcols,1)*figcols)
        ax = axs[sp_row][sp_col]
        if max(ylims) > -10 :
            # voorkomen dat ylims worden gezet voor nan ylims
            ax.set_ylim(ylims)
        ax.set_title(Ds)
        #major_yticks = np.arange(ylims[0],ylims[1]+1  ,1)
        #minor_yticks = np.arange(ylims[0],ylims[1]+1/4,1/2)
        #ax.set_xticks(major_xticks)
        ax.set_xticks(minor_xticks, minor=True)
        ax.grid(which='minor', alpha=0.3)
        ax.grid(which='major', alpha=0.8)            
        if sp_row < 7 :
            ax.tick_params(
                axis='x',          # changes apply to the x-axis
                labelbottom=False) # labels along the bottom edge are off
        if sp_col == 0 and sp_row == 4:
            ax.set_ylabel('waterstand [m+NAP]')
        if sp_row == 3:
            ax.set_xlabel('')
        if sp_col == 1 and sp_row == 0: # rechtsboven
            #ax.legend(fontsize=8,loc='upper right',ncol = len(Up_all))
            ax.legend(fontsize=8,loc='upper right',ncol = 4)
        ax.set_xlim(xlims)
        ax.set_ylim(ylims)

        fs=12        
        
        if sp_row == 7:
            for i, lab in enumerate(lab_lines):
                #plot_vline_with_location(ax,loc_lines[i],0,loc_lines[i],0,lab,color='r',linewidth=1)
                ax.axvline(loc_lines[i],color='k',zorder=0,linewidth=0.75)
                ax.text(loc_lines[i],ylims[0]+.03*np.diff(ylims),lab,rotation=90, ha='left', va='bottom', fontsize=fs-2, color='grey')

        if sp_row == 7:
        #   Labels bij tickmarks
            namelabels = []
            for i, lab in enumerate(ticks_for_labels):
                namelabels.append(data_sel[np.abs(data_sel['hm']-lab)<0.0001].index[0])
        
    #Use the pyplot interface to change just one subplot...
    #https://stackoverflow.com/questions/19626530/python-xticks-in-subplots
    for j in [0,1] :
        plt.sca(axs[7][j])
        plt.xticks(ticks_for_labels, namelabels, ha='right', rotation=45, fontsize=fs-1 )
    
    plt.tight_layout()
    
    fig.suptitle(figtit,fontsize=14,fontweight='bold')

    fig.savefig(os.path.join(outdir, '{}_consistency_{}_{}.png'.format(ws, 'verhanglijn', figtit)), dpi=150)
    plt.close(fig)    
    
    #stop
