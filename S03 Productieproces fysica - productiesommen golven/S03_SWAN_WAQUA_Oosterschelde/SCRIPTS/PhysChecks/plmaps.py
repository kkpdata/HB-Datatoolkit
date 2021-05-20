# -*- coding: utf-8 -*-
"""
Created on Tue Jan 24 13:13:09 2017

@author: gautier
"""
import matplotlib
matplotlib.use('Agg') 
from netCDF4 import Dataset
import numpy as np
import matplotlib.pyplot as plt
import os, sys
    
def plglobmaps(pathInp, pathOut):
    
    runid=os.path.split(pathInp)[1];
    fi = os.path.join(pathInp, runid + '.NC')

    pathOut=os.path.join(pathOut,'globalmaps')
    if not os.path.exists(pathOut):
        os.makedirs(pathOut)

    ldb=np.loadtxt("landboundary.txt")
    
    if runid[12:14]=='NZ':
       mstep = 8
       nstep = 8
       ax = [10, 45, 395, 430]
    else:
       mstep = 50
       nstep = 80
       ax = [36.50, 74.40, 383.00, 413.50] 

    data_read = Dataset(fi,'r')
    x     = data_read.variables['x'][:,:]/1000
    y     = data_read.variables['y'][:,:]/1000
    d     = data_read.variables['theta0'][:]
    d     = np.reshape(d,(len(x),len(x[0])))

    parameters = ['hs','dhs','tmm10','dtm']
    fig = plt.figure()
    for ind, name in enumerate(parameters):
        a = data_read.variables[name][:]
        z = np.reshape(a,(len(x),len(x[0])))
        plt.subplot(2,2,ind+1)
        plt.pcolor(x , y , z)
        plt.plot(ldb[:,0]/1000, ldb[:,1]/1000, '-g', linewidth=0.2)
        plt.colorbar()
        plt.title(runid + ' ' + name, fontsize = 10)
        plt.grid()
        if ind==2 or ind==3:
            plt.xlabel('X [km]',fontsize = 8)
        if ind==0 or ind==2:
            plt.ylabel('Y [km]',fontsize = 8)
        if ind==0:
            pldir(x,y,d,'k',mstep,nstep)
        if ind==0 or ind==1:
            plt.xticks([]);
        plt.axis('equal')
        plt.axis(ax)
    fig.savefig(os.path.join(pathOut, runid + '.png'), dpi=200)  
    data_read.close()    
    plt.close(fig) 
  
def pldir(x,y,d,kleur,mstep,nstep):
    u = np.cos(np.radians(270 - d))
    v = np.sin(np.radians(270 - d))
    plt.quiver(x[::mstep,::nstep],y[::mstep,::nstep],u[::mstep,::nstep],v[::mstep,0::nstep],\
        color=kleur,headlength=3,headaxislength=3,width=0.002)
    
def pllocmaps(pathInp, pathOut):
    varaxis=np.array([ [39.80,  44.80,  408.70,  412.30],[44.10,  50.10,  410.00,  413.40],[49.50,  52.50,  405.50,  410.50], \
                       [50.00,  56.10,  403.20,  406.50],[56.00,  60.50,  401.20,  404.50],[60.30,  65.30,  401.60,  405.90], \
                       [64.00,  72.50,  405.40,  410.80],[65.20,  71.30,  401.60,  405.60],[56.50,  61.00,  397.20,  401.30], \
                       [60.00,  64.00,  394.00,  398.00],[63.00,  67.00,  392.00,  394.50],[66.50,  71.00,  391.30,  393.80], \
                       [70.00,  73.90,  389.00,  392.00],[71.50,  74.20,  385.30,  389.50],[70.10,  74.10,  383.20,  385.70], \
                       [66.30,  70.30,  382.80,  385.30],[63.00,  66.50,  384.00,  387.50],[62.25,  64.75,  387.30,  390.80], \
                       [59.50,  63.50,  390.50,  393.50],[56.00,  60.50,  392.40,  394.90],[49.30,  53.30,  395.50,  398.50], \
                       [45.00,  50.00,  402.00,  405.00],[40.50,  45.50,  401.70,  404.50],[36.80,  40.80,  401.40,  404.40], \
                       [36.80,  40.80,  404.00,  408.00],[39.00,  41.60,  407.00,  410.50] ])
    
    runid=os.path.split(pathInp)[1];                    

    fi = os.path.join(pathInp, runid + '.NC')
    
    pathOut=os.path.join(pathOut,'localmaps', runid)
    if not os.path.exists(pathOut):
        os.makedirs(pathOut)    
  
    data_read = Dataset(fi,'r')
    x     = data_read.variables['x'][:,:]/1000
    y     = data_read.variables['y'][:,:]/1000
    
    tmp=os.path.split(pathInp)[0];
    tmp2=os.path.split(tmp)[0];
    tmp3=os.path.split(tmp2)[0];
    fixpath=tmp3;     
    
    q = np.loadtxt(os.path.join(fixpath,"INPFIX","OSPHRSET1.PNT"))  
    tel = np.arange(4,np.size(q,0),5)
    ldb=np.loadtxt("landboundary.txt")
           
    parameters = ['hs'  ,'dhs' ,'tmm10','dtm']
    units=       [' [m]',' [m]',' [s]', ' [s]']
        
    for ind, name in enumerate(parameters):
        a = data_read.variables[name][:]
        z = np.reshape(a,(len(x),len(x[0])))
                 
        fig = plt.figure()
        plt.pcolor(x , y , z)
        plt.colorbar()
        plt.grid()
        plt.xlabel('X [km]',fontsize = 8)
        plt.ylabel('Y [km]',fontsize = 8)
        plotobstacles(os.path.join(fixpath,"INPFIX", "OSBASELINE.OBS"))
        plt.axis('equal')
        plt.plot(q[:,0]/1000,q[:,1]/1000,'.k', markersize=4)
        plt.plot(q[4::5, 0]/1000, q[4::5, 1]/1000, linestyle='none', marker='o', markeredgecolor='k', markerfacecolor = 'none')
        plt.plot(ldb[:,0]/1000, ldb[:,1]/1000, linewidth=0.5)
        for t in tel:
            plt.text(0.04+ q[t,0]/1000, q[t,1]/1000, t+1,  fontsize = 7, rotation=30, va='bottom', clip_on=True)     
        for i in range(len(varaxis)):   
            plt.axis(varaxis[i,:])
            plt.title('Area ' + str(i+1).zfill(2) + ' ' + runid  + ' ' + name + units[ind],  fontsize = 10)        
            fig.savefig(os.path.join(pathOut, runid + '_' + name[:2]  + str(i+1).zfill(2) + '.png'), dpi= 350)  
        plt.close(fig) 
    data_read.close()    
    
def plotobstacles(obs):
    
    fp = open(obs,"r")
    text=fp.readlines()
    fp.close()

    for i in range(0, len(text), 3):
        x1=[]
        y1=[]
        xy1=text[i+1]
        xy2=text[i+2]
        x1.append(xy1[:9])
        y1.append(xy1[10:20])
        xx=x1
        yy=y1
        xx.append(xy2[:9])
        yy.append(xy2[10:20]) 
        xx=[float(i)/1000 for i in xx]
        yy=[float(i)/1000 for i in yy]        
        plt.plot(xx,yy, '-k', linewidth=2.0)  
        plt.plot(xx,yy, '-w', linewidth=1.0)  
        plt.axis('equal')
    
# results directory
if __name__=='__main__':
    if len(sys.argv) > 1:
        plglobmaps(sys.argv[1], sys.argv[2])
        if not sys.argv[1][-3:-1]=='NZ':
            pllocmaps(sys.argv[1], sys.argv[2]) 
    else:
        nameRun="U20D315Lp100NZa";    
        pathInp=r"P:\1230058-os\swanmodel\TEST01\RUN_TEST" + os.path.sep + "D315c" + os.path.sep + nameRun
        pathOut=r"p:\1230058-os\swanmodel\TEST01\CONTROL"
        
#        plglobmaps(pathInp, pathOut);
        if not pathInp[-3:-1]=='NZ':
            pllocmaps(pathInp, pathOut)