# -*- coding: utf-8 -*-
"""
Created on Thu Feb 02 15:39:27 2017

@author: morris
"""
import matplotlib
matplotlib.use('Agg')
import os, sys
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.pyplot import cm 

def plchecktransmission(pathInp, pathOut):

    pathOut=os.path.join(pathOut, "transmission");    
        
    # make figure directory
    if not os.path.isdir(pathOut):
        os.makedirs(pathOut)  
        
    # range of conditions that will be available
    Directions=np.array([23, 180, 203, 225, 248, 270, 293, 315, 338, 360]);
    Directions2=['023', '180', '203', '225', '248', '270', '293', '315', '338', '360'];
    WindSpd=np.array([10,20,24,28,30,34,38,42,46,50]);
    WatLev=np.concatenate((np.arange(-2,2.76,0.25),np.arange(2.99,3,2),np.arange(3,6.6,0.5)), axis=0)
    OpenClose=['O', 'D']
    
    # initialize variables
    WH=[];
    Tm_01=[];
    X=[];
    Y=[];
    RunID_avail=[]
    
    # define random colors
    color=cm.rainbow(np.linspace(0,1,len(WindSpd)))
    
    # read all available results
    for i in range(0, len(Directions)):
        if os.path.isdir(os.path.join(pathInp, "D" + Directions2[i])):
            pathRes2=os.path.join(pathInp,"D" + Directions2[i]);
            if Directions2[i]=='023' or Directions2[i]=='180':
                WindSpd=np.array([10,20,24,28,30,34,38]);
            else:
                WindSpd=np.array([10,20,24,28,30,34,38,42,46,50]);
            
            for j in range(0, len(WindSpd)):
                for k in range(0, len(WatLev)):
                    for l in range(0, len(OpenClose)):
                        if WatLev[k]<0:
                            WatKey='Lm';
                            WatLev_tmp=WatLev[k]*-1;
                        else:
                            WatKey='Lp';
                            WatLev_tmp=WatLev[k];
                  
                        RunID_K="U" + str(WindSpd[j]) +"D" + Directions2[i] + WatKey + str(int(WatLev_tmp*100)) + "NZa"
                        Tab_K = RunID_K + "_01.TAB" 
                        
                        RunID_O="U" + str(WindSpd[j]) +"D" + Directions2[i] + WatKey + str(int(WatLev_tmp*100)) + "O" + OpenClose[l] + "a"
                        Tab_O = RunID_O + "_02.TAB"
                        
                        if os.path.exists(os.path.join(pathRes2,RunID_K,Tab_K)) and l==0:
    #                        print Tab_K                               
                            fp=open(os.path.join(pathRes2,RunID_K,Tab_K)) 
                            
                            # skip header
                            for m in range(0,7):
                                line=fp.readline();                        
                            for m in range(0,6):
                                line=fp.readline();
                                
                            cells=line.split();
                            WH.append(cells[3])
                            Tm_01.append(cells[6])
                            X.append(cells[0])
                            Y.append(cells[1]);
                            RunID_avail.append(RunID_K)
                            fp.close()    
                            
                        if os.path.exists(os.path.join(pathRes2,RunID_O,Tab_O)):
    #                        print Tab_O       
                            fp=open(os.path.join(pathRes2, RunID_O, Tab_O)) 
                            
                            # skip header
                            for m in range(0,7):
                                line=fp.readline();                        
                            for m in range(0,2034):
                                line=fp.readline();
                                
                            cells=line.split();
                            WH.append(cells[3])
                            Tm_01.append(cells[6])
                            X.append(cells[0])
                            Y.append(cells[1]);
                            RunID_avail.append(RunID_O)
                            fp.close()    
    
    # store results in np array (first initialize)
    result_K = np.zeros((len(WatLev), len(WindSpd), len(Directions)))* np.nan
    result_O_Closed = np.zeros((len(WatLev), len(WindSpd), len(Directions)))* np.nan
    result_O_Open = np.zeros((len(WatLev), len(WindSpd), len(Directions)))* np.nan
    result_K_H = np.zeros((len(WatLev), len(WindSpd), len(Directions)))* np.nan
    result_O_Closed_H = np.zeros((len(WatLev), len(WindSpd), len(Directions)))* np.nan
    result_O_Open_H = np.zeros((len(WatLev), len(WindSpd), len(Directions)))* np.nan
    result_K_T = np.zeros((len(WatLev), len(WindSpd), len(Directions)))* np.nan
    result_O_Closed_T = np.zeros((len(WatLev), len(WindSpd), len(Directions)))* np.nan
    result_O_Open_T = np.zeros((len(WatLev), len(WindSpd), len(Directions)))* np.nan
    
    # store results in array
    for i in range(0, len(RunID_avail)):
        if RunID_avail[i][-3:-2]== "N":
            if RunID_avail[i][7:9] == "Lp":  
                WatLev_ind=(float(RunID_avail[i][9:12]))/100
            else:
                WatLev_ind=(0-float(RunID_avail[i][9:12]))/100
                
            Dir_ind=int(RunID_avail[i][4:7]);
            WindSpd_ind=int(RunID_avail[i][1:3]);   
            result_K_H[np.where(abs(WatLev_ind-WatLev)<0.001),np.where(WindSpd_ind== WindSpd),np.where(Dir_ind == Directions)]=float(WH[i]);
            result_K_T[np.where(abs(WatLev_ind-WatLev)<0.001),np.where(WindSpd_ind== WindSpd),np.where(Dir_ind == Directions)]=float(Tm_01[i]);
        else:
            if RunID_avail[i][-2:-1]== "O":
                if RunID_avail[i][7:9] == "Lp":  
                    WatLev_ind=(float(RunID_avail[i][9:12]))/100
                else:
                    WatLev_ind=(0-float(RunID_avail[i][9:12]))/100
                    
                Dir_ind=int(RunID_avail[i][4:7]);
                WindSpd_ind=int(RunID_avail[i][1:3]);   
                result_O_Open_H[np.where(abs(WatLev_ind-WatLev)<0.001),np.where(WindSpd_ind== WindSpd),np.where(Dir_ind == Directions)]=float(WH[i]);
                result_O_Open_T[np.where(abs(WatLev_ind-WatLev)<0.001),np.where(WindSpd_ind== WindSpd),np.where(Dir_ind == Directions)]=float(Tm_01[i]);
            else:
                if RunID_avail[i][7:9] == "Lp":  
                    WatLev_ind=(float(RunID_avail[i][9:12]))/100
                else:
                    WatLev_ind=(0-float(RunID_avail[i][9:12]))/100
                    
                Dir_ind=int(RunID_avail[i][4:7]);
                WindSpd_ind=int(RunID_avail[i][1:3]);   
                result_O_Closed_H[np.where(abs(WatLev_ind-WatLev)<0.001),np.where(WindSpd_ind== WindSpd),np.where(Dir_ind == Directions)]=float(WH[i]);
                result_O_Closed_T[np.where(abs(WatLev_ind-WatLev)<0.001),np.where(WindSpd_ind== WindSpd),np.where(Dir_ind == Directions)]=float(Tm_01[i]);    
    
    # make figures
    for m in range(0,2): # H and T
        if m==0:
            result_K=result_K_H;
            result_O_Open=result_O_Open_H;        
            result_O_Closed=result_O_Closed_H;
        else:
            result_K=result_K_T;
            result_O_Open=result_O_Open_T;        
            result_O_Closed=result_O_Closed_T;
        for i in range(0, len(Directions)):
            if Directions2[i]=='023' or Directions2[i]=='180':
                WindSpd=np.array([10,20,24,28,30,34,38]);
            else:
                WindSpd=np.array([10,20,24,28,30,34,38,42,46,50]);
            for j in range(0,2):
                if len(sys.argv) > 1: # Amaury
                    fig=plt.figure(1, figsize=(19,9))
                else: # Me
                    fig=plt.figure(1, figsize=(30,80))                
                
                figEmpty=1;
                if j==0:
                    plt.title("SWAN resultaten nabij OSK op NZ (" + X[0][0:-1] +"," + Y[0][0:-1] + ") en OS (" + X[1][0:-1] +"," + Y[1][0:-1] + " )" )
                    for k in range(0, len(WindSpd)):
                        s1mask = np.isfinite(result_K[:,k,i])
                        s2mask = np.isfinite(result_O_Open[:,k,i])
                        plt.plot(WatLev[s1mask], result_K[s1mask,k,i], "-x", c=color[k], label=str(WindSpd[k])+"m/s NZ", markersize=10)
                        plt.plot(WatLev[s2mask], result_O_Open[s2mask,k,i], "--x", c=color[k], label=str(WindSpd[k])+"m/s O", markersize=10)
                        if not all(np.isnan(result_K[:,k,i])):
                            figEmpty=0;
                else:
                    plt.title("SWAN resultaten nabij OSK op NZ(" + X[0] +"," + Y[0] + ") en OS(" + X[1] +"," + Y[1] + " )" )
                    for k in range(0, len(WindSpd)):
                        s1mask = np.isfinite(result_K[:,k,i])
                        s2mask = np.isfinite(result_O_Closed[:,k,i])
                        plt.plot(WatLev[s1mask], result_K[s1mask,k,i], "-x", c=color[k], label=str(WindSpd[k])+"m/s NZ", markersize=10)
                        plt.plot(WatLev[s2mask], result_O_Closed[s2mask,k,i], "--x", c=color[k], label=str(WindSpd[k])+"m/s O", markersize=10)
                        if not all(np.isnan(result_K[:,k,i])):
                            figEmpty=0;
                    
                if figEmpty == 0:
                    plt.xlabel("Waterstand [m + NAP]", fontsize=14);
                    
                    if m==0:                
                        plt.ylabel("Hm0 [m]", fontsize=14);
                    else:
                        plt.ylabel("Tm-1,0 [s]", fontsize=14);
                    plt.legend(bbox_to_anchor=(1.01, 1), loc=2, borderaxespad=0., fontsize=14)
                    
                    if m==0:
                        addition="hs";
                    else:
                        addition="tm"    
                    
    
                    fig.savefig(os.path.join(pathOut, "D" + Directions2[i] +"O" + OpenClose[j] +"a" + "_" + addition +".png") , dpi=200)
                    
                plt.close(fig);

# results directory
if __name__=='__main__':
    if len(sys.argv) > 1:
        plchecktransmission(sys.argv[1], sys.argv[2])

    else:
        pathInp=r"p:\11200556-os\golven\SWAN01\RUN"
        pathOut=r"p:\1230058-os\swanmodel\TEST01\CONTROL"
        
        plchecktransmission(pathInp, pathOut);  



