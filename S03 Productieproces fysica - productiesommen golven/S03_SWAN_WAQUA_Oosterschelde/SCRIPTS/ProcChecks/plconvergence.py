# -*- coding: utf-8 -*-
"""
Created on Mon Jan 23 14:32:35 2017

@author: morris
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from readPAR import readPar
from readPRINT import readPrint
from determineRecent import determineRecent
import os,sys

## only for easternschelt

def plconvergence(pathInp, pathOut):

    nameRun=os.path.split(pathInp)[1];
    
    if pathInp[-3:-1] == "NZ":
        region="NZ";
        region2="NZ"
    elif pathInp[-3:-1] == "OO":
        region="OS";
        region2="OO"
    elif pathInp[-3:-1] == "OD":
        region="OS";
        region2="OD"
    
    # define files to read, Par, and Print
#    fileName=determineRecent(pathInp[0:-3] + "NZ" + pathInp[len(pathInp)-1], "*.o*")
    filePrint=os.path.join(pathInp[0:-3] + region2 + pathInp[len(pathInp)-1], nameRun +".PRT");
    filePar=os.path.join(pathInp,nameRun + ".PAR");
    
    # read parameter file
    [Results, Units, Params, it, nQuant, nLoc]=readPar(filePar);
    
    # read print file
    p=readPrint(filePrint,region);
    
    x1=range(1,it+1); # iterations
    
    # make figure directory
    pathOut=os.path.join(pathOut, "convergence");    
    
    # make figure directory
    if not os.path.isdir(pathOut):
        os.makedirs(pathOut)  
    
    # Make Figures
    for i in range(1, 13):
        if len(sys.argv) > 1: # Amaury
            fig=plt.figure(1, figsize=(20,10))
        else: # Me
            fig=plt.figure(1, figsize=(30,80))
        ax1=plt.subplot(3,4,i)
        ax1.plot(x1,Results[i-1,0,:], 'b')
        ax1.tick_params('y', colors='b')
        ax1.grid();
        dH=abs(Results[i-1,0,-1]- Results[i-1,0,-2]) # change last step
        rH=dH/Results[i-1,0,-1]*100 # relative change last step
        if i==12 or i==9 or i==10 or i==11:    
            plt.xlabel('Number of Iterations (Maximum = ' + str(it) +')');    
        ax1.set_ylim([Results[i-1,0,-1]-0.6, Results[i-1,0,-1]+0.5])
        
        ax2=ax1.twinx()
        ax2.plot(x1,Results[i-1,1,:], 'r')
        ax2.tick_params('y', colors='r')
#        plt.title("$H_{sig}$[m] and $RT_{m01}$[s] testlocatie "+ str(i), fontsize=15)

        plt.text(0.17, 1, "$H_{sig}$[m]", ha="center", va="bottom", fontsize=15,color="blue", transform = ax1.transAxes)
        plt.text(0.30, 1, "&", ha="center", va="bottom", fontsize=15, transform = ax1.transAxes)
        plt.text(0.44,1,"$RT_{m01}$[s]", ha="center", va="bottom", fontsize=15,color="red", transform = ax1.transAxes)        
        plt.text(0.72, 1, " testlocatie "+ str(i), ha="center", va="bottom", fontsize=12, transform = ax1.transAxes)        
        dT=abs(Results[i-1,1,-1]- Results[i-1,1,-2])
        rT=dT/Results[i-1,1,-1]*100
        plt.text(0.7,0.9, "$\Delta$$H_{abs}$ = " + "%0.3f" % (dH)+ " m", horizontalalignment='left', verticalalignment='center',transform = ax1.transAxes,color="blue")
        plt.text(0.7,0.85, "$\Delta$$H_{rel}$ = " + "%0.3f" % (rH)+ " %", horizontalalignment='left', verticalalignment='center',transform = ax1.transAxes,color="blue")           
        plt.text(0.7,0.8, "$\Delta$$T_{abs}$ = " + "%0.3f" % (dT)+ " s", horizontalalignment='left', verticalalignment='center',transform = ax1.transAxes,color="red")
        plt.text(0.7,0.75, "$\Delta$$T_{rel}$ = " + "%0.3f" % (rT)+ " %", horizontalalignment='left', verticalalignment='center',transform = ax1.transAxes,color="red")        
        ax2.set_ylim([Results[i-1,1,-1]-0.5, Results[i-1,1,-1]+0.6])    
        
        y_lim = ax2.get_ylim()    
        ax2.plot(x1,p/100*(y_lim[1]-y_lim[0])+y_lim[0], 'k') 
        
    fig.savefig(os.path.join(pathOut, nameRun+"_1"), dpi=200)
    plt.close(fig);
        
    for i in range(1, 13):
        if len(sys.argv) > 1: # Amaury
            fig2=plt.figure(1, figsize=(20,10))
        else: # Me
            fig2=plt.figure(1, figsize=(30,80))
#        fig2=plt.figure(2, figsize=(10,10))
        ax1=plt.subplot(3,4,i)
        ax1.plot(x1,Results[i-1+12,0,:], 'b')   
        ax1.tick_params('y', colors='b')
        ax1.grid();
        dH=abs(Results[i-1+12,0,-1]- Results[i-1+12,0,-2])
        rH=dH/Results[i-1+12,0,-1]*100 
        if i==12 or i==9 or i==10 or i==11:    
            plt.xlabel('Aantal iteraties (Maximum = ' + str(it) +')');  
        ax1.set_ylim([Results[i-1+12,0,-1]-0.6, Results[i-1+12,0,-1]+0.5])
        
        ax2=ax1.twinx()
        ax2.plot(x1,Results[i-1+12,1,:], 'r')
        ax2.tick_params('y', colors='r')
        plt.text(0.17, 1, "$H_{sig}$[m]", ha="center", va="bottom", fontsize=15,color="blue", transform = ax1.transAxes)
        plt.text(0.30, 1, "&", ha="center", va="bottom", fontsize=15, transform = ax1.transAxes)
        plt.text(0.44,1,"$RT_{m01}$[s]", ha="center", va="bottom", fontsize=15,color="red", transform = ax1.transAxes)        
        plt.text(0.72, 1, " testlocatie "+ str(i+12), ha="center", va="bottom", fontsize=12, transform = ax1.transAxes)        
        dT=abs(Results[i-1+12,1,-1]- Results[i-1+12,1,-2])
        rT=dT/Results[i-1+12,1,-1]*100
        plt.text(0.7,0.9, "$\Delta$$H_{abs}$ = " + "%0.3f" % (dH)+ " m", horizontalalignment='left', verticalalignment='center',transform = ax1.transAxes,color="blue")
        plt.text(0.7,0.85, "$\Delta$$H_{rel}$ = " + "%0.3f" % (rH)+ " %", horizontalalignment='left', verticalalignment='center',transform = ax1.transAxes,color="blue")           
        plt.text(0.7,0.8, "$\Delta$$T_{abs}$ = " + "%0.3f" % (dT)+ " s", horizontalalignment='left', verticalalignment='center',transform = ax1.transAxes,color="red")
        plt.text(0.7,0.75, "$\Delta$$T_{rel}$ = " + "%0.3f" % (rT)+ " %", horizontalalignment='left', verticalalignment='center',transform = ax1.transAxes,color="red")        
        ax2.set_ylim([Results[i-1+12,1,-1]-0.5, Results[i-1+12,1,-1]+0.6])
    
        y_lim = ax2.get_ylim()    
        ax2.plot(x1,p/100*(y_lim[1]-y_lim[0])+y_lim[0], 'k') 
        
    fig2.savefig(os.path.join(pathOut, nameRun+"_2"), dpi=200)    
    plt.close(fig2);    

# how to run it 

   
if __name__=='__main__':
    if len(sys.argv) > 1:
        plconvergence(sys.argv[1], sys.argv[2])
    else:
#        nameRun="U20D315Lp100OOa";    
#        pathInp=r"P:\1230058-os\swanmodel\TEST01\RUN_TEST" + os.path.sep + "D315c" + os.path.sep + nameRun
        pathInp=r"p:\1230058-os\swanmodel\TEST01\RUN_TEST8\D203\U10D203Lm000ODa"
        pathOut=r"p:\1230058-os\swanmodel\TEST01\CONTROL"
        
        plconvergence(pathInp, pathOut)
