# -*- coding: utf-8 -*-
"""
Created on Tue Jan 24 15:37:42 2017

@author: morris
"""
import numpy as np

# function definition
def readPar(path):
    
    ## first time open file just to find out the dimensions and store variable names    
    # initialize
    xloc=[];
    yloc=[];
    params=[];
    units=[];
    it=0; # number iterations
    
    fp=open(path, "r")
    
    line=fp.readline();
    
    while line:
        if "LOCATIONS" in line: 
             line=fp.readline();
             ind=line.find("number")
             nLoc=int(line[1:ind])
             
             for i in range(1,nLoc+1):
                 line=fp.readline();
                 cells=line.split()
                 xloc.append(cells[1])
                 yloc.append(cells[1])
         
        if  "QUANT" in line:
            line=fp.readline();
            ind=line.find("number")
            nQuant=int(line[1:ind])
            
            for i in range(1,nQuant+1):
                line=fp.readline();
                cells=line.split()
                params.append(cells[0]);
                line=fp.readline();
                cells=line.split()
                units.append(cells[0]);
                line=fp.readline();
        if "iteration" in line and "iteration-" not in line:
            it=it+1;            
        line=fp.readline();
    fp.close()
    
    ## second time read the results
    # initalize
    result = np.zeros((nLoc, nQuant, it))
    it=0
    
    fp=open(path, "r")
    
    line=fp.readline();
    
    while line:
        if "iteration" in line and "iteration-" not in line:
            
            for i in range(0,nLoc):
                line=fp.readline();
                cells=line.split();
                for j in range(0,nQuant):
                    result[i,j,it]=float(cells[j])
            it=it+1;            
        line=fp.readline();
    fp.close()
    
    return result, units, params, it, nQuant, nLoc