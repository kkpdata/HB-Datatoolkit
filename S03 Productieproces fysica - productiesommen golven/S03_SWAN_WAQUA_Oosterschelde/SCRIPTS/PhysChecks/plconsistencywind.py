# -*- coding: utf-8 -*-
"""
Created on Mon Feb 13 09:59:58 2017

@author: morris
"""

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

def intersect(x, test, limit):
    foundIntersect=0;
    locIntersect=[];
    listIntersect=[];
#    plt.figure(1); 
#    for i in range(0,len(test[:,1])):
#        plt.plot(np.transpose(x), test[i, :]);
        
    for i in range(0,len(test[:,1])):
        for j in range(i+1, len(test[:,1])): 
            test[i,test[i,:]<limit]=np.nan;
            test[i,test[j,:]<limit]=np.nan;
            temp= np.diff(np.sign(test[i,:] - test[j,:]));
            temp = np.ma.masked_where(np.isnan(temp), temp)
#            if np.any(np.diff(np.sign(test[i,:] - test[j,:])) != 0):
            if np.any(temp != 0):
                foundIntersect=1; 
                temp2=np.where(temp!=0);
                for k in range(0, len(temp2[0])):
                    locIntersect.append(temp2[0][k]);
                listIntersect.append(str(i) + "&" + str(j))
    return foundIntersect, listIntersect, locIntersect

def plconsistencywind(pathInp, pathOut):

    pathOut=os.path.join(pathOut, "consistencywind")
    if not os.path.exists(pathOut):
        os.makedirs(pathOut)
    
    # range of conditions that will be available
    Directions=np.array([23,45,68,90,113,135,158,180, 203, 225, 248, 270, 293, 315, 338, 360]);
    Directions2=['023', '045', '068','90', '113', '135', '158','180', '203', '225', '248', '270', '293', '315', '338', '360'];
    WindSpd=np.array([10,20,24,28,30,34,38,42,46,50]);
    WatLev=np.concatenate((np.arange(-2,2.76,0.25),np.arange(2.99,3,2),np.arange(3,6.6,0.5)), axis=0)
    OpenClose=['O', 'D']
    
    # initialize variables
#    WH=[];
#    X=[];
#    Y=[];
#    RunID_avail=[]
    
    # define random colors
    color=cm.rainbow(np.linspace(0,1,len(WindSpd)))
    
    # initialize structures
    xVal=np.zeros(2038);
    xVal=np.linspace(1, 2038, num=2038)
    
    for p in range(0,2):
        # determine available results
        for i in range(0, len(Directions)):
            if os.path.isdir(os.path.join(pathInp, "D" + Directions2[i])):
                pathRes2=os.path.join(pathInp, "D" + Directions2[i]);
                if Directions[i]<181:
                    WindSpd=np.array([10,20,24,28,30,34,38]);
                else:
                    WindSpd=np.array([10,20,24,28,30,34,38,42,46,50]);
                for k in range(0, len(WatLev)):
                    for l in range(0, len(OpenClose)):
                        # initialize fig;
                        if len(sys.argv) > 1: # Amaury
                            fig=plt.figure(1, figsize=(16,6))
                        else: # Me
                            fig=plt.figure(1, figsize=(30,80)) 
                        figPlot=0;
                        result = np.zeros((len(WindSpd), 2038))* np.nan # 2039 is the number of locations in TAB01
                        for j in range(0, len(WindSpd)):
                            if WatLev[k]<0:
                                WatKey='Lm';
                                WatLev_tmp=WatLev[k]*-1;
                            else:
                                WatKey='Lp';
                                WatLev_tmp=WatLev[k];
                      
                            RunID_O="U" + str(WindSpd[j]) +"D" + Directions2[i] + WatKey + str(int(WatLev_tmp*100)) + "O" + OpenClose[l] + "a"
                            Tab_O = RunID_O + "_01.TAB"
                             
                            if os.path.exists(os.path.join(pathRes2, RunID_O,Tab_O)):
                                fp=open(os.path.join(pathRes2, RunID_O,Tab_O)) 
                                #skip header
                                counter=0;
                                for m in range(0,9):
                                    line=fp.readline();                        
                                while line:
                                    cells=line.split();
                                    if p==0:
                                        result[j,counter]=cells[3];
                                    else:
                                          result[j,counter]=cells[6];   
                                    counter=counter+1;
                                    line=fp.readline();
                                fp.close()
                                
                                if not all(np.isnan(result[j,:])):
        #                            plt.plot(range(1, 2039), result[j,:], "-", c=color[j], label=str(WindSpd[j])+"m/s NZ")                         
                                     result[j,result[j,:]==-9]=np.nan;
                                     xVal = np.ma.masked_where(np.isnan(result[j,:]), xVal)
                                     yVal = np.ma.masked_where(np.isnan(result[j,:]), result[j,:])
                                     h1=plt.subplot(2,1,1)                                
                                     plt.plot(xVal[0:1038], yVal[0:1038], c=color[j], label=str(WindSpd[j])+"m/s", linewidth=0.5)
                                     plt.xticks(np.arange(min(xVal)-1, max(xVal), 50.0))                                     
                                     plt.subplot(2,1,2)                                
                                     plt.plot(xVal[1038:], yVal[1038:], c=color[j], label=str(WindSpd[j])+"m/s", linewidth=0.5)
                                     plt.xticks(np.arange(min(xVal)-1, max(xVal), 50.0))                                         
                                     figPlot=1;
                                     xVal=np.linspace(1, 2038, num=2038)
                        if p==0:             
                            intersections, listIntersect, locIntersect=intersect(xVal, result, 0.5);
                        else:  
                            intersections, listIntersect, locIntersect=intersect(xVal, result, 0);
                                     
                        if figPlot==1:
                            plt.xlabel("Locatie # (vanaf zuidwest tegen de klok in) ");
                            if p==0:
                                plt.ylabel("$Hm0$ [m]")
                            else:
                                plt.ylabel("Tm-1,0 [s]")
                            if intersections==1 and p==0:
                                plt.text(0.7,0.8, "Warning, crossings for Hm0>0.5m", horizontalalignment='center', verticalalignment='center', fontsize=14, transform=h1.transAxes)                    
                            elif intersections==1 and p==1:  
                                plt.text(0.7,0.8, "Warning, crossings", horizontalalignment='center', verticalalignment='center', fontsize=14, transform=h1.transAxes)                    
                            mylist = list(set(locIntersect)); # list of locations with problem
                            for m in range(0, len(mylist)):
                                plt.plot([xVal[mylist[m]],xVal[mylist[m]]], [0,0.1], '-k' )
                            plt.xlim([1038,2038])
                            plt.grid()
                            plt.subplot(2,1,1)
                            for m in range(0, len(mylist)):
                                plt.plot([xVal[mylist[m]],xVal[mylist[m]]], [0,0.1], '-k' )
                            plt.xlim([1,1038])
                            plt.grid()
                            if p==0:
                                plt.ylabel("$Hm0$ [m]")
                            else:
                                plt.ylabel("Tm-1,0 [s]")
                            plt.legend(bbox_to_anchor=(1.01, 1), loc=2, borderaxespad=0.)
                            if WatLev[k]<0:
                                WatKey='Lm';
                                WatLev_tmp=WatLev[k]*-1;
                            else:
                                WatKey='Lp';
                                WatLev_tmp=WatLev[k];
                            if p==0:
                                fig.savefig(os.path.join(pathOut, "D" + Directions2[i] +WatKey + str(int(WatLev_tmp*100)) + "O" + OpenClose[l] + "a_hs" +".png") , dpi=300)
                            else:
                                fig.savefig(os.path.join(pathOut, "D" + Directions2[i] +WatKey + str(int(WatLev_tmp*100)) + "O" + OpenClose[l] + "a_tm" +".png") , dpi=300) 
                            plt.close(fig);
                                        



# results directory
if __name__=='__main__':
    if len(sys.argv) > 1:
        plconsistencywind(sys.argv[1], sys.argv[2])

    else:
        pathInp=r"p:\11200556-os\golven\SWAN01\RUN";
        pathOut=r'p:\1230058-os\swanmodel\TEST01\CONTROL';
        
        plconsistencywind(pathInp, pathOut); 