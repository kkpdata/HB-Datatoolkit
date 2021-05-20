# -*- coding: utf-8 -*-
"""
Created on Wed Feb 01 10:07:13 2017

@author: morris
"""
import os, sys
import matplotlib
matplotlib.use('Agg')
from readPRINT import readPrint
import numpy as np
from determineRecent import determineRecent
from datetime import datetime

def checkbulk(pathInp, pathOut, region):
    
    pathOut=os.path.join(pathOut, "checkbulk");    
    
    # make figure directory
    if not os.path.isdir(pathOut):
        os.makedirs(pathOut)    
    
    Dir=os.path.split(pathInp)[1];
    
    timeLim=4.5*60; # how long should the runtime be (minutes)
    
    # max iterations vary per region
    if region=='NZ':
        maxIt=80;
        region2="NZ"
    elif region=='OO':
        maxIt=80;
        region2="OO"
        region="OS";
    elif region=="OD":
        maxIt=80;
        region2="OD"
        region="OS";
    minIt=10;
        
    # all runs available in directory
    ListRuns=os.listdir(pathInp);
    
    # initialize structure to count failed runs, and run names
    counter=0;
    for i in range(0,len(ListRuns)):    
        if ListRuns[i][12:13]==region[0] and os.path.exists(os.path.join(pathInp, ListRuns[i],ListRuns[i] + '.PRT')):
            counter=counter+1; 
    
    Summary = np.zeros((counter,6));
    convergence=[];
    FailRun=np.zeros((counter,1));
    RunName=[];
    RunFail1=[];
    RunFail2=[];
    RunFail3=[];
    RunFail4=[];               
    
    counter=0;
    # loop through runs
    for i in range(0,len(ListRuns)):
        DirectoryRes2 = os.path.join(pathInp, ListRuns[i])
        if ListRuns[i][12:13]==region[0] and os.path.exists(os.path.join(DirectoryRes2,ListRuns[i] + '.PRT')):
            RunName.append(ListRuns[i])        
  
    ############# check if TAB, NC, SP1 and SP2 files all exist ###################
            check=0;   
            if not os.path.exists(os.path.join(DirectoryRes2, ListRuns[i] + '.NC')):
               check=check+1; 
            if region=='NZ':           
                for j in range(1,5):
                    if not os.path.exists(os.path.join(DirectoryRes2, ListRuns[i] + '_0' + str(j) + '.SP1')):
                        check=check+1;       
                    if not os.path.exists(os.path.join(DirectoryRes2, ListRuns[i] + '_0' + str(j) + '.SP2')):
                        check=check+1;
                    if not os.path.exists(os.path.join(DirectoryRes2, ListRuns[i] + '_0' + str(j) + '.TAB')):
                        check=check+1;
            if region=='OS':           
                for j in range(1,7):
                    if not os.path.exists(os.path.join(DirectoryRes2, ListRuns[i] + '_0' + str(j) + '.SP1')):
                        check=check+1;       
                    if not os.path.exists(os.path.join(DirectoryRes2, ListRuns[i] + '_0' + str(j) + '.SP2')):
                        check=check+1;
                    if not os.path.exists(os.path.join(DirectoryRes2, ListRuns[i] + '_0' + str(j) + '.TAB')):
                        check=check+1;
            
            if check>0:
                Summary[counter,0]=1;
            else:
                Summary[counter,0]=0;
            
            if Summary[counter,0]==1:
                RunFail1.append(ListRuns[i]);
    ############# check if PRINT file has errors ##################################
            check=0;
            
            printFile=os.path.join(DirectoryRes2,ListRuns[i] + '.PRT');
            fp=open(printFile);
            line=fp.readline();
            
            while line:
                if "Error" in line:
                    check=check+1;
                line=fp.readline();
            fp.close;
            
            if check>0:
                Summary[counter,1]=1;
            else:
                Summary[counter,1]=0;
                
            if Summary[counter,1]==1:
                RunFail2.append(ListRuns[i]);
    ############# check time of run ###############################################      
            printFile=os.path.join(DirectoryRes2,ListRuns[i] + '.PRT');
            fp=open(printFile);
            line=fp.readline();
            
            while line:
                if "Execution started" in line:
                    tmpTimeStart=line[41:57];
                line=fp.readline();
            fp.close;            
              
            tmpTimeEnd=os.path.getmtime(printFile)        
            TimeEnd=datetime.fromtimestamp(tmpTimeEnd)   
            TimeStart=datetime(int(tmpTimeStart[0:4]), int(tmpTimeStart[5:6]), int(tmpTimeStart[6:8]),int(tmpTimeStart[9:11]), int(tmpTimeStart[11:13]), int(tmpTimeStart[13:15]) )        
            if (TimeEnd-TimeStart).total_seconds()<60.0*timeLim:      
                Summary[counter,2]=0;
            else:
                Summary[counter,2]=1;
            
            if Summary[counter,2]==1:
                RunFail3.append(ListRuns[i]);
    ############# check number of iterations ######################################
            DirectoryRes3=DirectoryRes2[0:-3] + region2 + DirectoryRes2[-1]; 
            fileName=determineRecent(DirectoryRes3, "*.PRT*")        
            filePrint= os.path.join(DirectoryRes3,fileName);
    
            # read print file
            p=readPrint(filePrint,region);
            if len(p)<maxIt:
                Summary[counter,3]=0;
            else:
                Summary[counter,3]=1;
                if p[-1] < 99.5:
                    Summary[counter,4]=1;
                else:
                    Summary[counter,4]=0;
            
            convergence.append(p[-1]);            
            
            if len(p)<=minIt:
                Summary[counter,5]=1;
            
            if (Summary[counter,3]==1 and Summary[counter,4]==1) or Summary[counter,5]==1:
                RunFail4.append(ListRuns[i]);
            
            if Summary[counter,0]==1 or Summary[counter,1]==1 or Summary[counter,2]==1 or ((Summary[counter,3]==1 and Summary[counter,4]==1) or Summary[counter,5]==1 ):
                FailRun[counter]=1        
            
            counter=counter+1;
    # Write file 
    f=open(os.path.join(pathOut, 'BulkRes'+ region + Dir +'.txt'), 'w')
    f.write("THIS FILE CONTAINS RESULTS OF THE PROCEDURAL CONTROL FOR " + Dir + "\n\n")
    f.write("___________________________________________________________________________\n\n")
    f.write(str(counter) +" RUNS CHECKED\n")
    f.write("___________________________________________________________________________\n\n")
    f.write(str(int(len(Summary[:,0])-sum(Summary[:,0]))) +" runs contain all required SP1, SP2, TAB, and NC files\n");
    f.write(str(int(len(Summary[:,1])-sum(Summary[:,1]))) +" runs have 0 errors in the PRINT file\n");
    f.write(str(int(len(Summary[:,2])-sum(Summary[:,2]))) +" runs have a runtime less than " + str(timeLim) + " minutes\n");
    f.write(str(int(len(Summary[:,3])-sum(Summary[:,3]))) +" runs have less than " + str(maxIt) + " iterations and more than " + str(minIt) + "\n")
    
    if sum(Summary[:,3])>0:
        f.write("___________________________________________________________________________\n\n")
        f.write(str(int(sum(Summary[:,3]))) +" RUNS HAVE " + str(maxIt) + " ITERATIONS\n")
        f.write("___________________________________________________________________________\n\n")
        f.write("\t" + str(int(len(Summary[:,4])-sum(Summary[:,4]))-int(len(Summary[:,3])-sum(Summary[:,3]))) +" runs have greater than 99.5% convergence\n")      
    
    f.write("___________________________________________________________________________\n\n")
    f.write(str(int(sum(FailRun))) +" RUNS FAILING PROCEDURAL CONTROL\n")
    f.write("___________________________________________________________________________\n")
    
    f.write("\n\tDescription of Failure Codes\n")
    f.write("\t1 - Runs do not contain all required SP1, SP2, TAB, and NC files\n")
    f.write("\t2 - Runs have errors in the PRINT file\n")
    f.write("\t3 - Runs have a runtime greater than " + str(timeLim) + " minutes\n")
    f.write("\t4 - Runs that have not converged (either iterations < " + str(minIt) + ", or iterations = " +  str(maxIt) + " and less than 99.5% converged\n\n")
    f.write("\tFailed Runs\n")
    
    for i in  range(0,len(Summary)): 
        if Summary[i,0]==1 or Summary[i,1]==1 or Summary[i,2]==1 or ((Summary[i,3]==1 and Summary[i,4]==1) or Summary[i,5]==1 ):
            f.write("\t" + RunName[i]+ " : ")
            if Summary[i,0]==1:
                f.write( "1 ")
            else:
                f.write( "  ")
            if Summary[i,1]==1:
                f.write("2 ")
            else:
                f.write( "  ")    
            if Summary[i,2]==1:
                f.write("3 ")
            else:
                f.write( "  ")    
            if (Summary[i,3]==1 and Summary[i,4]==1) or Summary[i,5]==1 :
                f.write( "4     ")
                f.write(str(convergence[i]) + "% converged")
            else:
                f.write( "  ")    
            f.write( "\n")    
            
    f.close()           

if __name__=='__main__':
    if len(sys.argv) > 1:
        checkbulk(sys.argv[1], sys.argv[2], sys.argv[3]) 
    else:
        Dir="D248";
        region='NZ'; # NZ or OO or OD
        pathInp=r"p:\11200556-os\golven\SWAN01\RUN" + os.path.sep + Dir;
        pathOut=r'p:\1230058-os\swanmodel\TEST01\CONTROL';
        checkbulk(pathInp, pathOut, region);