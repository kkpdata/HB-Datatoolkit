# -*- coding: utf-8 -*-
"""
Project     : PR4539.10
Description : Consistency checks Meren

"""

import os
import getpass
import pandas as pd

#%%
user = getpass.getuser()
print('user={}'.format(user))

# import platform
# if user == 'paarlberg':
#     workdir         = r'd:\HKV\BOI2023\dockershare\dflowfm2d-grevelingen-hr2023_6-v1a\computations\hr\hr2023\output_python'    
# elif user.startswith('mp') :
#     workdir         = r'/data/computations/python/consistency_checks'
# else:
#     print('user unknown')

ws           = 'vrm'


if 'vrm' in ws :
    workdir      = r'p:\project\2262_Productiesommen_Veluwerandmeren\consistency_checks\output_python_versie01'    
    tables_path  = os.path.join(workdir,'tables_versie01')
    outdir       = os.path.join(workdir,'consistency')

import glob

csvFileList = glob.glob(os.path.join(tables_path,'metadata*.csv'))

for i, csvfile in enumerate(csvFileList) :
    # get somid 
    somid=csvfile.split('_')[-1]
    somid=somid.split('.')[0]
    # read metadata
    metadata = pd.read_csv(csvfile, skiprows=0, sep=';')
    metadata.columns=['parameter','value']
    metadata=metadata.set_index('parameter',drop=True).T
    metadata['somid']=somid
    if i==0:
        # initialize full matrix
        metadata_all = metadata.copy()
    else:
        # appenden data
        metadata_all = pd.concat([metadata_all, metadata], ignore_index=True)
        
metadata_all=metadata_all.set_index('somid',drop=True)

csvfile = os.path.join(outdir, ws+'_metadata_all.csv')
metadata_all.to_csv(csvfile,sep=';')

# xlsfile = os.path.join(outdir, ws+'_metadata_all.xlsx')
# writer = pd.ExcelWriter(xlsfile)
# metadata_all.to_excel(writer, sheet_name='metadata')
# writer.save()
# writer.close()
