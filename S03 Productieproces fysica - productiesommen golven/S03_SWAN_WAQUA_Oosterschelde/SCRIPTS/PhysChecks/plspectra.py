# -*- coding: utf-8 -*-
"""
Created on Wed Jan 25 15:58:32 2017

@author: morris
"""
# easternscheldt, uses xarrays
import matplotlib
matplotlib.use('Agg')
import oceanwaves
import matplotlib.pyplot as plt
import os
import sys
import numpy as np
from scipy.integrate import trapz, simps

def plspectra(pathInp, pathOut):
    
    if pathInp[-3:-1] == "NZ":
        region="NZ";
    else:
        region="OS";
    
    nameRun=os.path.split(pathInp)[1];    
    
    # get directory of land boundary
    tmp=os.path.split(pathInp)[0];
    tmp2=os.path.split(tmp)[0];
    tmp3=os.path.split(tmp2)[0];
    lb_file=os.path.join(tmp3, 'SCRIPTS','PhysChecks', 'landboundary.txt'); 
    
    Hm0=[];
    Tp=[];
    # load results from file
    if region=='NZ':
        tmp=os.path.join(pathInp, nameRun +"_04.SP1");
        os.path.exists(tmp);
        ow = oceanwaves.from_swan(os.path.join(pathInp, nameRun +"_04.SP1")) # obs
        tab=os.path.join(pathInp,nameRun +"_04.TAB")
        ow2 = oceanwaves.from_swan(os.path.join(pathInp, nameRun +"_02.SP1")) # check
        tab2=os.path.join(pathInp,nameRun +"_02.TAB")        
        
        # test locations intered in figures for
        Locations1=np.array([1,3,4,5,9]);
        Locations2=np.array([7]);
        
        fp=open(tab);
        
        counter=1;                
        # skip header
        for m in range(0,8):
           line=fp.readline();                        
        while line:
           if any(counter==Locations1):
               cells=line.split();
               Hm0.append(cells[3]);
               Tp.append(cells[4]);
           line=fp.readline();
           counter=counter+1; 
        fp.close()

        fp=open(tab2);
        
        counter=1;                
        # skip header
        for m in range(0,8):
           line=fp.readline();                        
        while line:
           if any(counter==Locations2):
               cells=line.split();
               Hm0.append(cells[3]);
               Tp.append(cells[4]);
           line=fp.readline();
           counter=counter+1; 
        fp.close()             
                
        
    else: # OS
        ow = oceanwaves.from_swan(os.path.join(pathInp,nameRun +"_05.SP1"))
        tab=os.path.join(pathInp,nameRun +"_05.TAB")
        # test locations intered in figures for
#        Locations1=np.array([1,3,4,8,5,6]);
        Locations1=np.array([1,3,4,5,6,8]);
        Locations2=np.array([9,12,14,15,19,22]);

        fp=open(tab);
        
        counter=1;                
        # skip header
        for m in range(0,8):
           line=fp.readline();                        
        while line:
           if any(counter==Locations1) or any(counter==Locations2):
               cells=line.split();
               Hm0.append(cells[3]);
               Tp.append(cells[4]);
           line=fp.readline();
           counter=counter+1; 
        fp.close()    
         

    lbx=[];
    lby=[];
    
    # load landboundary
    file = open(lb_file,'r') 
    for line in file:
        cells=line.split()
        lbx.append(cells[0]);
        lby.append(cells[1]);
    
    # make figure directory
    pathFigure = os.path.join(pathOut, 'spectra')
    if not os.path.isdir(pathFigure):
        os.makedirs(pathFigure)
    
#    # plot locations
#    fig1=plt.figure(1)
#    plt.plot(lbx,lby, 'k')
#    if region=='NZ':
#        for i in range(0, len(Locations1)):
#            plt.text(ow.location.location_x[Locations1[i]-1]-700, ow.location.location_y[Locations1[i]-1]-200, str(Locations1[i]) )
#        for i in range(0, len(Locations2)):
#            plt.text(ow2.location.location_x[Locations2[i]-1]-700, ow2.location.location_y[Locations2[i]-1]-200, str(Locations2[i]) )
#        plt.plot(ow.location.location_x[Locations1-1], ow.location.location_y[Locations1-1], '.r', ms=15)
#        plt.plot(ow2.location.location_x[Locations2-1], ow2.location.location_y[Locations2-1], '.b', ms=15)
#        plt.axis('equal')
#        plt.xlim((10000, 45000))
#        plt.ylim((400000, 425000))
#    else:
#        for i in range(0, len(Locations1)):
#            plt.text(ow.location.location_x[Locations1[i]-1], ow.location.location_y[Locations1[i]-1], str(Locations1[i]) )
#        for i in range(0, len(Locations2)):
#            plt.text(ow.location.location_x[Locations2[i]-1], ow.location.location_y[Locations2[i]-1], str(Locations2[i]) )
#        plt.plot(ow.location.location_x[Locations1-1], ow.location.location_y[Locations1-1], '.r', ms=15)
#        plt.plot(ow.location.location_x[Locations2-1], ow.location.location_y[Locations2-1], '.b', ms=15)
#        plt.axis('equal')
#        plt.xlim((30000, 80000))
#        plt.ylim((380000, 415000))
    
#    plt.xlabel('X[m]');
#    plt.ylabel('Y[m]');
#    fig1.savefig(os.path.join(pathFigure, nameRun + "_loc_" + region), dpi=200)   
#    plt.close(fig1);    
    
    # plot spectr   
    for i in range(0,len(Locations1)):
        fig2=plt.figure(2, figsize=(10,10))
        ax1=plt.subplot(3,2,i+1)    	
        energy2=[]
        freq2=[]  
        for j in range(0, len(ow.frequency)):
            if ow.energy[Locations1[i]-1,j]>0:
                energy2.append(ow.energy[Locations1[i]-1,j])
                freq2.append(ow.frequency[j])
        Hm0_spec=4*(trapz(energy2, freq2))**0.5;
        Tp_spec=1/freq2[np.argmax(energy2)];
        plt.text(0.65,0.9, "$H_{m0}$ = " + "%0.2f" % (Hm0_spec)+ " m (sp1)", horizontalalignment='left', verticalalignment='center', transform = ax1.transAxes, fontsize=8)
        plt.text(0.65,0.85, "$H_{m0}$ = " + "%0.2f" % (float(Hm0[i]))+ " m (tab)", horizontalalignment='left', verticalalignment='center', transform = ax1.transAxes, fontsize=8)           
        plt.text(0.65,0.8, "$T_{p}$ = " + "%0.1f" % (Tp_spec)+ " s (sp1)", horizontalalignment='left', verticalalignment='center', transform = ax1.transAxes, fontsize=8)
        plt.text(0.65,0.75, "$T_{p}$ = " + "%0.1f" % (float(Tp[i]))+ " s (tab)", horizontalalignment='left', verticalalignment='center', transform = ax1.transAxes, fontsize=8) 
        ax1.plot(freq2,energy2, 'b')
        ax1.tick_params('y', colors='b')
        if i==4 or i==5:
            plt.xlabel('Freq (Hz)')
        plt.ylabel('E ($m^{2}$/Hz)')        
        ax1.grid();
        ax2=ax1.twinx();
        ax2.semilogy(freq2,energy2, 'r')
        ax2.tick_params('y', colors='r')
        plt.minorticks_off()
        
        plt.xlim(0,2.5);
        if region =="OS":
            plt.title('Oosterschelde; loc' + str(Locations1[i]));
        else:
            plt.title('Noord Zee; loc' + str(Locations1[i]));
        
        plt.tight_layout()
    
    if region == 'OS':
	    fig2.savefig(os.path.join(pathFigure, nameRun+"_spectra1"), dpi=200)   
	    plt.close(fig2);   
      
    for i in range(0,len(Locations2)):
        energy2=[];
        freq2=[];        
        if region == 'NZ':
            ax1=plt.subplot(3,2,6);
            
            for j in range(0, len(ow2.frequency)):
                if ow2.energy[Locations2[i]-1,j]>0:
                    energy2.append(ow2.energy[Locations2[i]-1,j])
                    freq2.append(ow2.frequency[j])
        else:
            fig3=plt.figure(3, figsize=(10,10))
            ax1=plt.subplot(3,2,i+1)
          
            for j in range(0, len(ow.frequency)):
                if ow.energy[Locations2[i]-1,j]>0:
                    energy2.append(ow.energy[Locations2[i]-1,j])
                    freq2.append(ow.frequency[j])
        Hm0_spec=4*(trapz(energy2, freq2))**0.5;
        if len(energy2)>0:        
            Tp_spec=1/freq2[np.argmax(energy2)];
        else:
            Tp_spec=-9.0;
            Hm0_spec=-9.0;
        plt.text(0.65,0.9, "$H_{m0}$ = " + "%0.2f" % (Hm0_spec)+ " m (sp1)", horizontalalignment='left', verticalalignment='center', transform = ax1.transAxes, fontsize=8)
        plt.text(0.65,0.85, "$H_{m0}$ = " + "%0.2f" % (float(Hm0[i+len(Locations1)]))+ " m (tab)", horizontalalignment='left', verticalalignment='center', transform = ax1.transAxes, fontsize=8)           
        plt.text(0.65,0.8, "$T_{p}$ = " + "%0.1f" % (Tp_spec)+ " s (sp1)", horizontalalignment='left', verticalalignment='center', transform = ax1.transAxes, fontsize=8)
        plt.text(0.65,0.75, "$T_{p}$ = " + "%0.1f" % (float(Tp[i+len(Locations1)]))+ " s (tab)", horizontalalignment='left', verticalalignment='center', transform = ax1.transAxes, fontsize=8)         
        ax1.plot(freq2,energy2, 'b')
        ax1.tick_params('y', colors='b')
        if i==4 or i==5:
            plt.xlabel('Freq (Hz)')
        if region=="NZ":
            plt.xlabel('Freq (Hz)')
        plt.ylabel('E ($m^{2}$/Hz)')
        ax1.grid();
        ax2=ax1.twinx();
        
        ax2.semilogy(freq2,energy2, 'r')
        ax2.tick_params('y', colors='r') 
        plt.minorticks_off()
               
        plt.xlim(0,2.5);  
        if region =="OS":
            plt.title('Oosterschelde; loc' + str(Locations1[i]));
        else:
            plt.title('Noord Zee; loc' + str(Locations1[i]));
        plt.tight_layout()
    
    if region == "NZ":
        fig2.savefig(os.path.join(pathFigure, nameRun+"_spectra"), dpi=200)    
        plt.close(fig2); 
    else:
	    fig3.savefig(os.path.join(pathFigure, nameRun+"_spectra2"), dpi=200)
	    plt.close(fig3);       

if __name__=='__main__':
    if len(sys.argv) > 1:
        plspectra(sys.argv[1], sys.argv[2])  
    else:
        pathInp=r"p:\1230058-os\swanmodel\TEST01\RUN_TEST4\D338\U30D338Lp300OOa"        
        pathOut=r"p:\1230058-os\swanmodel\TEST01\CONTROL"
    
        plspectra(pathInp, pathOut);
