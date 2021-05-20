# -*- coding: utf-8 -*-
"""
Created on Fri Mar 10 11:10:16 2017

@author: morris
"""
import matplotlib.pyplot as plt
import os

lb_file=r"p:\1230058-os\swanmodel\TEST01\0prepare\PhysChecks\landboundary.txt"; 

lbx=[];
lby=[];
    
# load landboundary
file = open(lb_file,'r') 
for line in file:
    cells=line.split()
    lbx.append(cells[0]);
    lby.append(cells[1]);

# X and Y coordinates taken from PAR file
X=[38271.36, 
40374.26,
40847.52, 
45623.55, 
53117.49, 
57818.53, 
67695.84, 
71999.40, 
43513.39, 
49299.77, 
53274.34, 
62248.51, 
63964.11, 
73858.90, 
69828.82, 
61211.96, 
58378.36,
65082.21, 
69826.63, 
66045.57, 
59381.91, 
51342.14, 
47552.45, 
40883.98];

Y=[ 403446.47,
 407242.25,
 409600.00,
 406751.44,
 402181.25,
 396257.28,
 386042.53,
 388394.69,
 402574.22,
 402415.75,
 396064.94,
 391383.78,
 386604.72,
 388124.81,
 393347.31,
 396950.06,
 401444.22,
 403437.81,
 410095.41,
 408934.19,
 404019.22,
 406699.03,
 411354.16,
 410476.09]

# plot locations
fig1=plt.figure(1)
plt.plot(lbx,lby, 'k')
for i in range(0, len(X)):
    plt.text(X[i]-1000, Y[i]-400, str(i+1))
plt.plot(X, Y, '.r', ms=15)
plt.axis('equal')
plt.xlim((30000, 80000))
plt.ylim((380000, 415000))
    
plt.xlabel('X[m]');
plt.ylabel('Y[m]');
fig1.savefig(os.path.join('p:\\1230058-os\swanmodel\TEST01\CONTROL\convergence', 'loc_OS.png'), dpi=200)   
#plt.close(fig1);