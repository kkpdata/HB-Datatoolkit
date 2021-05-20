# -*- coding: utf-8 -*-
"""
Created on Wed Feb 01 11:42:22 2017

@author: morris
"""
import glob, os

def determineRecent(path, formatRes):
    tmp=str(glob.glob1(path, formatRes));  # literal_directory, basename_pattern     
    tmp2=tmp[1:-1].split(', ');
    Time=0;
    for i in range(0,len(tmp2)):
        
        tmp3=os.path.join(path,tmp2[i][1:-1]);
        tmpTime=os.path.getmtime(tmp3);
        if tmpTime>Time:
            fileSel=i;
            
    return tmp2[fileSel][1:-1];       
    