# -*- coding: utf-8 -*-
"""
Project     : PR4539.10
Description : Consistency checks Meren

"""

import os
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# kies watersysteem

ws = 'vrm'
#ws = 'vzm'

#%%

if 'vrm' in ws :
    #%%
    workdir      = r'p:\project\2262_Productiesommen_Veluwerandmeren\consistency_checks\output_python_versie01'    
    tables_path  = os.path.join(workdir,'tables_versie01')
    outdir       = os.path.join(workdir,'consistency')
    
    MM_all = ['Mm040','Mm020','Mp000','Mp020','Mp040','Mp080','Mp120','Mp160','Mp200','Mp240']
    M_vals = [-0.4   ,-0.2   ,0.00   ,0.20   ,0.40   ,0.80   ,1.20   ,1.60   ,2.00   ,2.40]
    Up_all = ['U00','U10','U16','U22','U27','U32','U37','U42','U47']
    D_all  = ['D023','D045','D068','D090','D113','D135','D158','D180','D203','D225','D248','D270','D293','D315','D338','D360']
    
    statsnm = ['NU_26.10','VE_42.70','VE_60.80','DM_68.00']
    statslb = ['A Nijkerkersluis (NU_26.10)','B N302 Harderwijk (VE_42.70)','C Elburgerweg (VE_60.80)','D Reevesluis (DM_68.00)']
    
    xlims = (min(M_vals)-.2, max(M_vals)+.2)
    ylims = (-5.0, +7.0)
    
    #clr    = ['b','r']

from matplotlib import cm
cmap = cm.get_cmap('tab10', len(Up_all)) # viridis
clr = cmap(range(len(Up_all)))

#%%

D_loop = D_all
U_loop = Up_all

M_loop = MM_all
M_vals = M_vals

#M_loop = ['Mm030','Mp015','Mp075']
#M_vals = [-0.3   ,+0.15  ,+0.75]
minor_xticks = M_vals

parameters = ['maximum', 'minimum']

for iloc, loc in enumerate(statsnm) :
    
    for par in parameters :
    
        figtit = statslb[iloc] + ' :' + par + ' waterstand'

        print('figtit: {} -- par: {}'.format(figtit,par))    
    
        # opbouwen volgens windrichting
        # totaal 16 windrichtingen
        figrows = 4 
        figcols = 4
        fig, axs = plt.subplots(figrows,figcols,figsize=(30/2.54, 20/2.54))
        
        marker='.'
        ms=4
        
        for Di, Ds in enumerate(D_loop) :
        
            sp_row = int(np.floor(Di/figcols))
            sp_col = int(np.mod(Di/figcols,1)*figcols)
            ax = axs[sp_row][sp_col]
        
            if True :    
            #if ('D045' in Ds) or ('D338' in Ds) :
        
                for Ui, Us in enumerate(U_loop) :
                    
                    xvals = []
                    yvals = []
                    
                    for Mi, Ms in enumerate(M_loop) :
                        
                        if ('U00' in Us) and ('D360' not in Ds) :
                            continue
                        
                        # als waarde
                        Dv = float(Ds[1:])
                        Uv = float(Ds[1:])
                        Mv = M_vals[Mi]
                        
                        somid = '{}{}{}{}'.format(ws,Ms,Us,Ds)

                        fname = os.path.join(tables_path,'statdata_{}.csv'.format(somid))

                        if os.path.exists(fname) : 
                            
                            print(somid)
                            
                            stationdata = pd.read_csv(fname,sep=';')
                            # TODO, waarom dit nodig is, is niet duidelijk...
                            # somehow in Docker it gets messed up;
                            # has to do with sjoin before writing to Excel?!
                            stationdata.rename({'index_left':'Name'},inplace = True,axis=1) 
                            stationdata.reset_index()
                            stationdata.set_index('Name', inplace=True)
                            
                            xvals.append(Mv)
                            yvals.append(stationdata.loc[loc][par])
                        
                        #ax.plot(Mv, stationdata.loc[loc]['max13'], ls='', marker=marker, mfc=clr[Ui], mec=clr[Ui], ms=ms, label=legstr)
                        #if Ui == len(U_loop)-1 : # dan item voor legend()
                        #    ax.plot(Mv, stationdata.loc[loc][parameter], ls='', marker=marker, mfc=clr[Ui], mec=clr[Ui], ms=ms, label=Us)
                        #else :
                    
                    ax.plot(xvals, yvals, ls='-', color=clr[Ui], marker=marker, mfc=clr[Ui], mec=clr[Ui], ms=ms, label=Us)
        
        # set figure properties            
        for Di, Ds in enumerate(D_loop) :
            sp_row = int(np.floor(Di/figcols))
            sp_col = int(np.mod(Di/figcols,1)*figcols)
            ax = axs[sp_row][sp_col]
            if max(ylims) > -10 :
                # voorkomen dat ylims worden gezet voor nan ylims
                ax.set_ylim(ylims)
            ax.set_xlim(xlims)
            ax.set_ylim(ylims)
            ax.set_title(Ds)
            #major_yticks = np.arange(ylims[0],ylims[1]+1  ,1)
            #minor_yticks = np.arange(ylims[0],ylims[1]+1/4,1/2)
            #ax.set_xticks(major_xticks)
            ax.set_xticks(minor_xticks, minor=True)
            ax.grid(which='minor', alpha=0.3)
            ax.grid(which='major', alpha=0.8)            
            if sp_row < 3 :
                ax.tick_params(
                    axis='x',          # changes apply to the x-axis
                    labelbottom=False) # labels along the bottom edge are off
            if sp_col == 0:
                ax.set_ylabel('waterstand [m+NAP]')
            if sp_row == 3:
                ax.set_xlabel('meerpeil [m+NAP]')
            if sp_col == 0 and sp_row == 0:
                ax.legend(fontsize=6)
        
        fig.suptitle(figtit)

        fig.savefig(os.path.join(outdir, '{}_consistency_stat_{}_{}.png'.format(ws, statslb[iloc], par)), dpi=150)
        plt.close(fig)    
        
        #stop

# plt.tick_params(
#     axis='x',          # changes apply to the x-axis
#     which='both',      # both major and minor ticks are affected
#     bottom=False,      # ticks along the bottom edge are off
#     top=False,         # ticks along the top edge are off
#     labelbottom=False) # labels along the bottom edge are off
