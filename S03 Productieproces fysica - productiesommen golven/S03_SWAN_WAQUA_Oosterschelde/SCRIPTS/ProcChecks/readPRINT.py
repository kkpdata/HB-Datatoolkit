# -*- coding: utf-8 -*-
"""
Created on Wed Jan 25 12:17:30 2017

@author: morris
"""

import numpy as np

# function definition
def readPrint(path,region):
    
    # determine number of iterations
    it=-1;
    nanv=0;
    fp=open(path, "r")
    line=fp.readline();
    
#    if region=="OS":
#        while line:
#            if "SWAN is preparing computation" in line:
#                line=fp.readline();
#                break
#            line=fp.readline();
#        while line:
#            if "SWAN is preparing computation" in line:
#                line=fp.readline();
#                break
#            line=fp.readline();    
        
    while line:
        if "not possible to compute" in line:
            it=it+1;
            nanv=nanv+1;
        if "accuracy OK in" in line: 
            it=it+1;
        if "+SWAN is processing output request" in line:
            break
        line=fp.readline();        
    fp.close()
    
    # determine % wet point
    it2=-1;
    p = np.zeros(it+1)
    
    for i in range(0, nanv):
        p[i]='nan';
    
    fp=open(path, "r")
    line=fp.readline();
    
#    if region=="OS":
#        while line:
#            if "SWAN is preparing computation" in line:
#                line=fp.readline();
#                break
#            line=fp.readline();
#            
#        while line:
#            if "SWAN is preparing computation" in line:
#                line=fp.readline();
#                break
#            line=fp.readline();        

    while line:
        if "accuracy OK in" in line: 
            it2=it2+1;
            p[it2+nanv]=(line[16:22]);
        if "+SWAN is processing output request" in line:
            break    
        line=fp.readline();        
    fp.close()
    return p