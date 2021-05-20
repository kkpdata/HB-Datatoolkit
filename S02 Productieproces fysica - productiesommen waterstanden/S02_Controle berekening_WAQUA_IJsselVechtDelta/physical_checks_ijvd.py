# -*- coding: utf-8 -*-
"""
Created on  : 24-07-2017
Author      : Andries Paarlberg
Project     : PR3638.10
Description : gebaseerd op Oosterschelde-scripts

"""

import matplotlib
matplotlib.use('Agg')

import os
import sys

import geopandas as gpd
import pandas as pd
import shapely.geometry as shp
from shapely.geometry import LineString, Point
import matplotlib.pyplot as plt
import datetime
import re
import numpy as np

def parse_path(string, paths):
    # Search and replace variables, already defined in paths
    for var, path in paths.items():
        string = string.replace('{'+var+'}', path)
    # Split the paths on seperators ('\')
    parts = string.split('\\')
    string = os.path.join(*parts)
    # Return the joined parts
    return string


def read_ini_paths(inifile):
    # Read general parameters from ini
    #--------------------------------------------------------------------------------
    paths = {}
    with open(inifile, 'r') as f:
        for line in f.readlines():
            # Skip comment lines
            if line.startswith('#'):
                continue
            # Split each line in parameter and value (often path)
            [param, value] = [word.strip() for word in line.split('=')]
            # Parse and add to dictionary
            paths[param] = parse_path(value, paths)

    return paths


def import_stationdata(paths):
    # Import station coordinates
    stationcrds = pd.read_csv(paths['stationnames'], sep=';', index_col='Name')
    stationcrds.columns = ['stationid', 'set', 'x', 'y', 'm', 'n', 'postprocess', 'nearestsection']
    
    # Generate point sequence for shapefile
    pts = [shp.Point(locdata.x, locdata.y) for _, locdata in stationcrds.iterrows()]
    
    model_path = paths['model']
    print(model_path)
    #if re.search("_WTI2017", model_path):
    if re.search("uitgezetvoorpr3871", model_path):
        print("reduce stationdata to WTI-stations")
        stationcrds = stationcrds[:6427]
        # stationsnamen hebben max 20 karakters in WTI2017 ...
        # daarnaast zijn alle spaties vervangen door _
        stationslijst = []
        for idxname in stationcrds.index:
            statnm = idxname[:20]
            statnm = statnm.replace(' ','_')
            statnm = statnm.replace('.00_IJ','_IJ')
            stationslijst.append(statnm)
            del statnm
        stationcrds['Name'] = stationslijst
        stationcrds = stationcrds.set_index(stationcrds['Name'],drop=True)
        pts = pts[:6427]
    elif re.search("initieel", model_path):
        print("reduce stationdata to stations used to check initial conditions")
        stationcrds = stationcrds.drop(stationcrds.index[[np.arange(334,6816)]])
        pts[334:6816] = []
    else:
        print("Using default station data")
        
    return stationcrds, pts

def plot_vline_with_location(ax,xpos,xposoffset,xlab,xlaboffset,xnam,fs=8,color='gray',yposr=0.05):
    # Add vertical line with location to plot

    ylims = ax.get_ylim()
    xpositie = xpos + xposoffset
    xlabpos = xlab + xlaboffset
    ax.axvline(xpositie,color='gray',zorder=0,linewidth=0.5)
    ax.text(xlabpos,yposr*np.diff(ylims)+ylims[0],xnam,rotation=90, ha='left', va='bottom', fontsize=fs)


def get_calc_metadata(outputfolder, simid):
    
    from hkvpy.waqua import controles, io

    # Count number of warnings in waqpre-m
    with open(os.path.join(outputfolder, 'waqpre-m.{}'.format(simid)), 'r') as f:
        numwarning = len(re.findall('\*\*\* WARNING', f.read()))
    
    # Count number successfull in waqpre-m
    with open(os.path.join(outputfolder, 'waqpro-m.{}'.format(simid)), 'r') as f:
        text = f.read()    
    numsuccess = len(re.findall('\*\*\*\*\*\*  SIMONA --- program ended successfully  \*\*\*\*\*\*', text))
    # Determine end time of the calculation
    date = re.findall('RunDate    = (.+)', text)[-1]
    time = re.findall('RunTime    = (.+)', text)[-1]
    dt = datetime.datetime(*[int(i) for i in date.split('-')[::-1] + time.split(':')])
        
    # Count files in output folder
    numoutputfiles = len(os.listdir(outputfolder))
    
    # Add to DataFrame
    index = ['WaqPreMWarning', 'WaqProMSuccessfull', 'NOuputFiles', 'TEndSimulation']
    values = [numwarning, numsuccess, numoutputfiles, dt]
    columns = ['Value']
    return pd.DataFrame(values, index=index, columns=columns)
    
    
def str2bool(v):

    if type(v) != bool :

        if v.lower() in ('yes', 'true', 't', 'y', '1'):
            return True
        elif v.lower() in ('no', 'false', 'f', 'n', '0'):
            return False
        else:
            raise TypeError('Boolean value expected.')
            
    else :
        
        return v
        
        
def check_timeseries(somid, runid, inputparametersfile,TFHISTO,TIHISTO,TLHISTO):

#%%
    
    # Read paths
    paths = read_ini_paths(inputparametersfile)
    
    # Check if output folders already exists. Otherwise create them
    for path in ['output_tables', 'output_shapes', 'output_figures']:
        try:
            if not os.path.exists(paths[path]):
                os.makedirs(paths[path])
        except:
            pass
    
    # Voeg pad naar hkvpy toe.    
    if not paths['hkvpy'] in sys.path:
        sys.path.append(paths['hkvpy'])
    # Importeer hkvpy
    from hkvpy.waqua import controles, io

    # Initiate output-excel
    writer = pd.ExcelWriter(os.path.join(paths['output_tables'], '{}.xlsx'.format(somid)))
    
    # Define number of runs, and load the barrier timeseries if run 002 is done
    #runid = 'wYVG-Q02U34D292S02'
    print(os.path.join(paths['somdir'], somid, runid+'_treeks_zwl.nc'))
    if not os.path.exists(os.path.join(paths['somdir'], somid, runid+'_treeks_zwl.nc')):
        raise OSError('No time series netcdf-file (used to find simulation id) found at: "{}"'.format(os.path.join(paths['somdir'], somid, runid+'_treeks_zwl.nc')))
    
    # Import modeldata
    #--------------------------------------------------------------------------------
    # Import station coordinates
    stationcrds, pts = import_stationdata(paths)
    
    # Import bed level
    bed = io.read_boxfile(paths['bedlevel'], -999999.0)
    # Generate point sequence for shapefile
    pts = [shp.Point(locdata.x, locdata.y) for _, locdata in stationcrds.iterrows()]
    
    paths['timeserieszwl'] = os.path.join(paths['somdir'], somid, runid+'_treeks_zwl.nc')
    paths['timeseriesctr'] = os.path.join(paths['somdir'], somid, runid+'_treeks_ctr.nc')
    paths['timeseriesctrv'] = os.path.join(paths['somdir'], somid, runid+'_treeks_ctrv.nc')
    paths['asciioutput'] =  os.path.join(paths['somdir'], somid, runid+'_max25_ZWL.txt')
    paths['maxseptim'] = os.path.join(paths['somdir'], somid, runid+'_MAXSEPTIM')
    paths['maxsepsep'] = os.path.join(paths['somdir'], somid, runid+'_MAXSEPSEP')
    
    # Check if paths are present
    for key, val in paths.items():
        if not os.path.exists(val):
            raise OSError('Path for {}: \"{}\" not found'.format(key, val))
    
    # Import simulation data
    #--------------------------------------------------------------------------------

    # Import netcdf ZWL
    zwl_nc = io.read_ncfile(paths['timeserieszwl'], indexvar='TIME', colvar='NAMWL', datavar='ZWL', method='scipy')

    # Eerste element er af halen (want getdata neemt init condities mee op T=0)
    zwl_nc = zwl_nc[1:]

    # Import ascii station output
    asciioutput = io.import_ascii_reeks(paths['asciioutput'])
    if len(asciioutput.index.unique()) != len(asciioutput.index):
        raise IndexError('The number of unique station names ({}) is not equal to the total number of station names ({}). Make sure the stationnames are unique.'.format(len(asciioutput.index.unique()), len(asciioutput.index)))
    
    asciioutput = asciioutput.loc[stationcrds.index]

#%%

    # tijdelijk manipuleren van asciioutput, omdat getdata geen rekening houdt met TIHIST    
    # Uitgezet omdat getdata is gerepareerd
    #asciioutput.to_csv(paths['asciioutput'][:-4]+'a.csv',float_format='%.4f')
    print('tijdelijke herdefinitie van max13 <uitgezet>...')
    #for i, name in asciioutput.iterrows():
    #    treeks    = zwl_nc[i]
    #    asciioutput.loc[i,'max13'] = pd.rolling_mean(treeks,13,center=True)[treeks.idxmax()]
    #    asciioutput.loc[i,'max25'] = pd.rolling_mean(treeks,25,center=True)[treeks.idxmax()]
    #    asciioutput.loc[i,'min13'] = pd.rolling_mean(treeks,13,center=True)[treeks.idxmin()]
    #    asciioutput.loc[i,'min25'] = pd.rolling_mean(treeks,25,center=True)[treeks.idxmin()]
    #asciioutput.to_csv(paths['asciioutput'][:-4]+'b.csv',float_format='%.4f')

    print('inlezen boxfiles')
    # Import boxfiles with waterlevel data
    maxseptim = io.read_boxfile(paths['maxseptim'], -999.0)
    maxsepsep = io.read_boxfile(paths['maxsepsep'], -999.0)

    # Order the time series to the order of the station names
    # is niet meer nodig, zijn al geordend
    # zwl_nc = zwl_nc[stationcrds.index]
    
    # Carry out different analyses
    #--------------------------------------------------------------------------------------------------

    # Initiate output-structure
    stationdata = pd.DataFrame(index=stationcrds.index, columns=
                            ['stationid', 'x', 'y', 'm', 'n', 'set',
                             'bedlevel', 'NANMAX', 'DROOGP', 'SEPMAX',
                             'INSTPK', 'max13', 'rolmean_max13', 'last25'])

    # Add station data
    for col in ['stationid', 'x', 'y', 'm', 'n', 'set', 'nearestsection']:
        stationdata[col] = stationcrds[col]
        asciioutput[col] = stationcrds[col]
    for col in ['m', 'n', 'stationid']:
        stationdata[col] = stationdata[col].values.astype(int)
        asciioutput[col] = asciioutput[col].values.astype(int)

    stationdata['bedlevel'] = bed[stationdata.m.values-1, stationdata.n.values-1]
    asciioutput['bedlevel'] = stationdata['bedlevel']
    
    stationdata['max13'] = asciioutput['max13']
    stationdata['last25'] = asciioutput['last25']
    
    stationdata['rolmean_max13'] = zwl_nc.rolling(window=13, center=False).mean().max()
    stationdata.loc[np.isnan(stationdata['max13']), 'rolmean_max13'] = np.nan
    # Carry out NANMAX analysis
    stationdata.loc[:, 'NANMAX'] = controles.nanmaxanalyse(asciioutput)
    print(stationdata.groupby('NANMAX')['stationid'].nunique())
    
    # Carry out DROOGP analysis
    stationdata.loc[:, 'DROOGP'] = controles.drypointanalysis(asciioutput, maxsepsep, bed)
        
    # Carry out SEPMAX analysis
    # sepmaxdiff = -1. * float(somid.split('L')[1].split('S')[0].replace('m', '-').replace('p', ''))/ 1e4
    sepmaxdiff = -0.03 # Zie WTI2017 rapport p58
    stationdata.loc[:, 'SEPMAX'], sepdiff = controles.difference_max_13(asciioutput, maxsepsep, sepmaxdiff=sepmaxdiff)
        
    # Carry out INSTPK analysis
    ninstab, tinstab = controles.instpkanalyse(asciioutput, zwl_nc, maxseptim, instab_val=0.04, TFHISto=TFHISTO, TLHISto=TLHISTO, TIHISto=TIHISTO)
    #ninstab, tinstab = controles.instpkanalyse(asciioutput, zwl_nc, maxseptim, instab_val=0.04, TFHISto=TFHIST, TIHISto=TIHISTO)
    stationdata.loc[:, 'INSTPK'] = ninstab['ninstabiliteiten']

    # Get calculation metadata
    simulation_metadata = get_calc_metadata(os.path.join(paths['somdir'], somid), runid)
    #overtopping_volumes = get_overtopping_volumes(os.path.join(paths['somdir'], somid))
    #simulation_metadata = pd.concat([simulation_metadata, overtopping_volumes])
    
    # Save data to excel
    #--------------------------------------------------------------------------------------------------
    # Add data to excel
    stationdata.to_excel(writer, sheet_name='stationdata_{}'.format(runid))

    # Add time instabilities to excel
    tinstab = {key : {i+1 : t for i, t in enumerate(val)} for key, val in tinstab.items() if val}
    tinstab = pd.DataFrame(pd.DataFrame.from_dict(tinstab, orient='index').stack(), columns=['tinstab'], dtype=int)
    if not tinstab.empty:
        tinstab.to_excel(writer, sheet_name='instab_{}'.format(runid))
    
    # Add simulation metadata to excel
    simulation_metadata.to_excel(writer, sheet_name='metadata_{}'.format(runid))
    
    # Save data to shapefile
    #--------------------------------------------------------------------------------------------------
    gdf = gpd.GeoDataFrame(index=stationdata.index, geometry=pts)
    for col in stationdata.columns:
        gdf[col] = stationdata[col]
    
    gdf['Name'] = gdf.index
    gdf.crs = {'init' : 'epsg:28992'}
    #gdf.to_file(os.path.join(paths['output_shapes'], somid+'.shp'))
     
    writer.save()
    writer.close()


def plot_checkfigs(somid, runid, inputparametersfile, TFHISTO, TIHISTO, TLHISTO, windv, plot_timeseries = False):
    
#%%
    
    # Read paths
    paths = read_ini_paths(inputparametersfile)

    # Import station data (oa postproc)
    stationcrds, pts = import_stationdata(paths)
        
    # Voeg pad naar hkvpy toe.    
    if not paths['hkvpy'] in sys.path:
        sys.path.append(paths['hkvpy'])
    # Importeer hkvpy
    from hkvpy import background, plotting
    from hkvpy.waqua import io, plots
    
    # Check if output folders already exists. Otherwise create them
    for figpath in ['consistency', 'globalmaps', os.path.join('localmaps', somid), os.path.join('timeseries', somid)]:
        if not os.path.exists(os.path.join(paths['output_figures'], figpath)):
            os.makedirs(os.path.join(paths['output_figures'], figpath))
    
    plotting.set_rcparams()

    # Load grid
    print('load grid ...')
    grid = io.read_gridfile(paths['grid'])
    
    if not os.path.exists(paths['gridmask']):
        print('load enclosure ...')
        geometry = gpd.read_file(paths['enclosure']).loc[0, 'geometry']
        exterior = geometry.buffer(1.0).exterior.coords[:]
        interiors = [interior.coords[:] for interior in geometry.interiors]
        print('clip grid with enclosure (and save mask for later use)...')
        grid.clip(exterior=exterior, interiors=interiors,coordinatetype='corner')
        grid.save_mask(paths['gridmask'])
    else:
        grid.load_mask(paths['gridmask'])
    
    print('clip grid with enclosure ...')
    grid.clip(coordinatetype='corner')

    #print('load enclosure ...')
    #polygoncoords = gpd.read_file(paths['enclosure']).loc[0, 'geometry'].buffer(1.0).exterior.coords[:]
    #print('clip grid with enclosure ...')
    #grid.clip(polygoncoords)
    
    # Define number of runs, and load the barrier timeseries if run 002 is done
    print('define runid ...')
    #runid = 'wYVO-Q08U11D225S04'
    print(os.path.join(paths['somdir'], somid, runid+'_treeks_zwl.nc'))
    if not os.path.exists(os.path.join(paths['somdir'], somid, runid+'_treeks_zwl.nc')):
        raise OSError('No time series netcdf-file (used to find simulation id) found at: "{}"'.format(os.path.join(paths['somdir'], somid, runid+'_treeks_zwl.nc')))
    
    # Load station data
    print('load station data ...')
    sheets = pd.read_excel(os.path.join(paths['output_tables'], '{}.xlsx'.format(somid)), sheetname=None)
    global stationdata
    stationdata = sheets['stationdata_{}'.format(runid)]
    stationdata.set_index('Name', inplace=True)
    
    # Load time instabilities data, if present
    tinstabsheetname = 'instab_{}'.format(runid)
    if tinstabsheetname in sheets.keys():
        print('load instab data ...')
        tinstab = pd.read_excel(os.path.join(paths['output_tables'], '{}.xlsx'.format(somid)), sheetname=tinstabsheetname, index_col=[0,1])
        tinstab = {key : vals.dropna().values.tolist() for key, vals in tinstab.unstack().iterrows()}
    else:
        tinstab = {}
    paths['timeseriesbarrier'] = os.path.join(paths['somdir'], somid, runid+'_BARQ.nc')
    paths['timeserieszwl'] = os.path.join(paths['somdir'], somid, runid+'_treeks_zwl.nc')
    paths['timeseriesctr'] = os.path.join(paths['somdir'], somid, runid+'_treeks_ctr.nc')
    paths['timeseriesctrv'] = os.path.join(paths['somdir'], somid, runid+'_treeks_ctrv.nc')
    paths['asciioutput'] =  os.path.join(paths['somdir'], somid, runid+'_max25_ZWL.txt')
    paths['maxseptim'] = os.path.join(paths['somdir'], somid, runid+'_MAXSEPTIM')
    paths['wetmaxval'] = os.path.join(paths['somdir'], somid, runid+'_WETMAXVAL')
        
    # Import netcdf ZWL
    print('import netcdf ZWL ...')
    zwl_nc = io.read_ncfile(paths['timeserieszwl'], indexvar='TIME', colvar='NAMWL', datavar='ZWL', method='scipy')
    # Eerste element er af halen
    # !!!! TIJDELIJK
    zwl_nc = zwl_nc[1:]

    # Import netcdf CTRV/CTR
    ctrv_nc = io.read_ncfile(paths['timeseriesctrv'], indexvar='TIME', colvar='NAMTRV', datavar='CTRV', method='scipy')
    ctr_nc  = io.read_ncfile(paths['timeseriesctr'] , indexvar='TIME', colvar='NAMTRA', datavar='CTR' , method='scipy')
    ctrv_nc = ctrv_nc[1:]
    ctr_nc  = ctr_nc[1:]
        
    # Order the time series to the order of the station names
    #zwl_nc = zwl_nc[stationdata.index]

    # Load boxfiles
    print('load box files ...')
    wetmaxval = io.read_boxfile(paths['wetmaxval'], -999.0)
    maxseptim = io.read_boxfile(paths['maxseptim'], -999.0)

    xlims2D = (120000, 240000)
    ylims2D = (480000, 570000)

    tssavepath = os.path.join(paths['output_figures'], 'timeseries', somid)
    if not os.path.exists(tssavepath):
        os.mkdir(tssavepath)

#%%
        
    # Plot globalmaps
    #--------------------------------------------------------------------------------
    print('plot global maps ...')
    for i, controle in enumerate(['NANMAX','DROOGP','SEPMAX','INSTPK']):
        
        idx = stationdata.where(stationdata[controle] != 0).dropna(how='all').index
        cbtitle = 'Maximale waterstand [m + NAP]'
        Z = wetmaxval[1:,1:]
        vmin, vmax = np.percentile(Z[~np.isnan(Z)], [1, 99])
        
        # Generate title and filename
        title = '{}_FysCont_{:02d}_{} (#={})'.format(runid, i+1, controle, len(idx))
        filename = '{}_FysCont_{:02d}_{}.png'.format(runid, i+1, controle)
    
    
        # Plot een overzichtsfiguur
        #------------------------------------------------------------------------------
        fig, ax = plt.subplots(figsize=(20/2.54, 12/2.54))
        ax.set_xlim(*xlims2D)
        ax.set_ylim(*ylims2D)
        ax.set_facecolor('#dddddd')
        background.add(ax, zomerbedkleur='#ffffff', winterbedkleur='#eeeeee')
        plots.plot_2D_markers(stationdata, controle, idx, grid, Z,
                              ax=ax, mc='r', marker='o', figtitle=title,
                              cbtitle=cbtitle, vmin=vmin, vmax=vmax)
        
        ax.legend()
        ax.grid()
        plt.tight_layout()
        fig.savefig(os.path.join(paths['output_figures'], 'globalmaps', filename), dpi=220)
        plt.close(fig)
    
#%%

    # Plot time series
    #--------------------------------------------------------------------------------
    if str2bool(plot_timeseries) :
        
        print('plot time series ...')
        
        for name, locdata in stationdata.iterrows():

            # wanneer nanmax == 0, overige checks geen bijzonderheden, postprocess ==0
            # dan continue naar volgende station
            if ((stationdata.at[name, 'NANMAX'] == 0) &
                (stationdata.at[name, 'SEPMAX'] <= 0) &
                (stationdata.at[name, 'INSTPK'] <= 0) &
                (stationcrds.at[name, 'postprocess'] == 0)):
                continue

            # tijdreeksen met
            # nanmax==2 en 5 hoeven niet geplot
            # 2 = droogpunt, 5 = afwaaiing
            # nanmax==1,3,4 dus wel (en 0 ook, anders ook SEPMAX/INSTPK niet)
            if ((stationdata.at[name, 'NANMAX'] == 2) &
                (stationcrds.at[name, 'postprocess'] == 0)):
                continue
            if ((stationdata.at[name, 'NANMAX'] == 5) &
                (stationcrds.at[name, 'postprocess'] == 0)):
                continue

            # 3&4 niet plotten voor <=Q06 && U00
            Qnum = float(runid[6:8])
            Ustr = runid[8:11]
            if Qnum<=6 and Ustr=='U00' :
                if ((stationdata.at[name, 'NANMAX'] == 3) &
                    (stationcrds.at[name, 'postprocess'] == 0)):
                    continue
                if ((stationdata.at[name, 'NANMAX'] == 4) &
                    (stationcrds.at[name, 'postprocess'] == 0)):
                    continue

            #print(name)
            
            # Onderstaande aanzetten wanneer we selectie willen processen
            #if (stationcrds.at[name, 'postprocess'] == 0):
            #continue

            codestr = '{}{}{}{}'.format(stationcrds.at[name, 'postprocess'],stationdata.at[name, 'NANMAX'],stationdata.at[name, 'SEPMAX'],stationdata.at[name, 'INSTPK'])        
            
            #print(codestr)
            #if name not in ['ZW_HR_R_9_381']:
            #    continue
            #print(name)
            
            # Selecteer benodigde data
            #--------------------------------------------------------------------------
            m, n = int(locdata['m']-1), int(locdata['n']-1)
            locdata['wetmax'] = wetmaxval[m, n]
            locdata['timmax'] = maxseptim[m, n]
            
            zwl_tijdreeks = zwl_nc[name]
    
            if name not in tinstab.keys():
                loc_tinstab = []
            else:
                loc_tinstab = tinstab[name]
        
            figtitle = '{} {}'.format(runid, name)
            
            # Roep plotfunctie aan
            #--------------------------------------------------------------------------
            fig = plt.figure(figsize=(22/2.54, 10/2.54))
            ax = plt.subplot2grid((1,4), (0,0), colspan=3)
            mapax = plt.subplot2grid((1,4), (0,3), colspan=1)
            mapax.set_xlim(*(locdata.x-10000, locdata.x+10000))
            mapax.set_ylim(*(locdata.y-18000, locdata.y+18000))
            mapax.set_facecolor('#dddddd')
            background.add(mapax, zomerbedkleur='#ffffff', winterbedkleur='#eeeeee')
            mapax.set_aspect('equal')
            mapax.plot(locdata.x, locdata.y, marker='o', mfc='none', color='C3')
            plotting.map_axes(mapax, color='k')
            
            plots.plot_tijdreeks(zwl_tijdreeks, locdata, loc_tinstab, ax=ax, TFHISto=TFHISTO, TLHISto=TLHISTO, TIHISto=TIHISTO,
                                 figtitle=figtitle, markersize_instab=7)
            ax.grid()
            
            plt.tight_layout()
            
            fig.savefig(os.path.join(tssavepath, '{}_{}_{}.png'.format(runid, name, codestr)), dpi=72)
            plt.close(fig)    
    
    else:
    
        print('plot time series <<UIT>>...')

#%%

    # Plot waterstand rivieras (IJssel)
    print('plot waterstand IJsselmeer ...')
    #--------------------------------------------------------------------------------
    
    fig, ax = plt.subplots(figsize=(25/2.54, 12.5/2.54))
    
    ax.plot(zwl_nc['punt_1_IJsselmeer'],label='punt_1_IJsselmeer (NW)')
    ax.plot(zwl_nc['punt_2_IJsselmeer'],label='punt_2_IJsselmeer (NO)')
    ax.plot(zwl_nc['punt_3_IJsselmeer'],label='punt_3_IJsselmeer (ZW)')
    ax.plot(zwl_nc['FL02_2012'],label='FL02_2012 (ZO)')
    ax.legend()
    ax.grid()
    ax.set_title(runid)
    ax.set_ylabel('waterstand [m+NAP]')
    ax.set_xlabel('tijd [minuten]')

    plt.title(runid)
    plt.tight_layout()

    fig.savefig(os.path.join(paths['output_figures'], 'consistency', '{}_{}.png'.format(somid, 'wl_IJsselmeer')), dpi=150)
    plt.close(fig)
    
#%%

    # Rondwandeling
    #if not re.search("_WTI2017" , inputparametersfile):
    if not re.search("uitgezetvoorpr3871" , inputparametersfile):
        
        print('plot rondwandeling ...')
        #--------------------------------------------------------------------------------
        #for typ in ['max13', 'rolmean_max13']:
    
        # inlezen koppeltabellen
        koppeltabel_L_11 = pd.read_csv('input_generalmodeldata/uitvloc_koppeltabel_L_11.csv', sep=';')
        koppeltabel_R_10 = pd.read_csv('input_generalmodeldata/uitvloc_koppeltabel_R_10.csv', sep=';')
            
        for typ in ['max13','last25']:
            
            ymin = np.percentile(stationdata[typ][~np.isnan(stationdata[typ])], 1) - 0.10
            ymax = np.max(stationdata[typ]) + 0.05
    
            setA = stationdata.where(stationdata.set==1).dropna(how='all')  # rivieras (A)
            setL = stationdata.where(stationdata.set==2).dropna(how='all')  # linker  oever (L)
            setR = stationdata.where(stationdata.set==3).dropna(how='all')  # rechter oever (R)
    
            setA_max13 = setA.loc[setA.index.str.startswith('km'),typ]
            setA_rkm = setA_max13.index.tolist()
            setA_rkm_vals = np.zeros(len(setA_rkm))
            for i in range(len(setA_rkm)):    
                setA_rkm_vals[i] = (setA_rkm[i][2:-3])
    
    #        # - ophalen coordinaten voor set1 (rivieras)
    #        # - tuples er van maken
    #        # - aslijn als LineString
    #        # - afstand van de punten langs de aslijn bepalen
    #        setAxy = setA[['x','y']]
    #        setAxy = setAxy.apply(tuple,axis=1).tolist()
    #        aslijn = LineString(setAxy)
    #        afstand = [] # lege lijst met afstanden langs de aslijn
    #        for aspt in setAxy:
    #            afstand.append(aslijn.project(Point(aspt)))
    #        afstand = np.array(afstand)
    #
    #        # Linker oever
    #        setL_rkm_vals = np.zeros(len(setL))
    #        for i in np.arange(len(setL)):
    #            pt = Point(setL.iloc[i]['x'],setL.iloc[i]['y'])
    #            aa = aslijn.project(pt)
    #            pt_rkm = np.interp(aa,afstand,setA_rkm_vals)
    #            setL_rkm_vals[i] = pt_rkm
    #
    #        # Rechter oever
    #        setR_rkm_vals = np.zeros(len(setR))
    #        for i in np.arange(len(setR)):
    #            pt = Point(setR.iloc[i]['x'],setR.iloc[i]['y'])
    #            aa = aslijn.project(pt)
    #            pt_rkm = np.interp(aa,afstand,setA_rkm_vals)
    #            setR_rkm_vals[i] = pt_rkm
            
            setL_rkm_vals = np.array(koppeltabel_L_11['hmp'])
            setR_rkm_vals = np.array(koppeltabel_R_10['hmp'])
                              
            fig, ax = plt.subplots(figsize=(25/2.54, 12.5/2.54))
    
            #ax.set_ylim(ymin, ymax)
            ax.plot(setA_rkm_vals, setA[typ],label='rivieras')
            ax.plot(setL_rkm_vals, setL[typ],label='linker oever',marker='o',markersize=3)
            ax.plot(setR_rkm_vals, setR[typ],label='rechter oever',marker='o',markersize=3)
            
            #plot_vline_with_location(ax,957,0.1,957,0.2,'Olst')
            #plot_vline_with_location(ax,965,0.1,965,0.2,'Wijhe')
            #plot_vline_with_location(ax,980,0.1,980,0.2,'Zwolle')
            plot_vline_with_location(ax,990.5,0.1,990.5,0.2,'Inlaat Reevediep')
            plot_vline_with_location(ax,994.5,0.1,994.5,0.2,'Kampen')
            
            ax.grid()
            ax.legend()
            ax.set_title(runid)
            ax.set_ylabel('waterstand [m+NAP]')
            ax.set_xlabel('rivierkilometer')
            plt.tight_layout()
            
            fig.savefig(os.path.join(paths['output_figures'], 'consistency', '{}_{}_{}.png'.format(somid, 'rondw' ,typ)), dpi=150)
            plt.close(fig)

#%%

    # waterstand IJssel inclusief WTI2017-data
    #if not re.search("_WTI2017" , inputparametersfile):
    if not re.search("uitgezetvoorpr3871" , inputparametersfile):
        print('plot waterstand IJssel inclusief WTI2017-data ...')
        #--------------------------------------------------------------------------------
        Qnum = float(runid[6:8])
        Ustr = runid[8:11]
        typ = 'max13'
        if Qnum<=6 and Ustr=='U00' :
            typ = 'last25'
            
        # alle data uitlezen
    
        # inlezen WTI2017 data
        WTImax13 = pd.read_csv('input_generalmodeldata/max13zwl_IJVD_WTI2017_IJssel_interp.csv', sep=';', index_col='simulatie')
        WTImax13_km = np.arange(956,1007,1)
        
        somidWTI = somid
        if re.search("U00", somidWTI):
            somidWTI = somidWTI.replace('D292','D360')
            #print(somidWTI)
        
        Ureplacer = {16:18,22:24,32:34,42:43}

        for Urep in Ureplacer:
            somidWTI = somidWTI.replace('U{}'.format(Urep),'U{}'.format(Ureplacer[Urep])) 

        WTImax13_somid = WTImax13.loc[somidWTI]
        
        ymin = np.percentile(stationdata[typ][~np.isnan(stationdata[typ])], 1) - 0.10
        ymax = np.max(stationdata[typ]) + 0.05
    
        setA = stationdata[stationdata.index.str.startswith('km')].dropna(how='all')  # rivieras (A)
    
        setA_max13 = setA[typ]
        setA_rkm = setA_max13.index.tolist()
        setA_rkm_vals = np.zeros(len(setA_rkm))
        for i in range(len(setA_rkm)):    
            setA_rkm_vals[i] = (setA_rkm[i][2:-3])
        
        # km-waarden uit setA
        kmpunten = np.arange(0,len(setA_max13)+1,10)
        setA_max13_helekms = setA_max13.iloc[kmpunten]
        
        # figuur maken
        
        figrows = 2
        figcols = 1
        fig, axs = plt.subplots(figrows,figcols,figsize=(25/2.54, 12.5/2.54))
    
        ax = axs[0]

        if re.search("06-WTI2017_geenBypass" , inputparametersfile) or re.search("02_WTI2017_geenBypass_met_wda-RD2018_mRB_wda_N105" , inputparametersfile):
            ax.plot(setA_rkm_vals, setA[typ],label='wl rivieras RD fase 1b zonder bypass')
            ax.plot(WTImax13_km, WTImax13_somid,label='wl rivieras RD fase 1b met bypass (persgemaal)',linestyle='',marker='x')
            wl_verschil = WTImax13_somid - setA_max13_helekms.values
            wl_verschil_label = 'effect Bypass in fase 1b'
        else:
            ax.plot(setA_rkm_vals, setA[typ],label='wl rivieras RD fase 2')
            ax.plot(WTImax13_km, WTImax13_somid,label='wl rivieras RD fase 1b',linestyle='',marker='x')
            wl_verschil = setA_max13_helekms.values - WTImax13_somid
            wl_verschil_label = 'fase 2 minus fase 1b'
        
        plot_vline_with_location(ax,957,0.1,957,0.2,'Olst')
        plot_vline_with_location(ax,965,0.1,965,0.2,'Wijhe')
        plot_vline_with_location(ax,980,0.1,980,0.2,'Zwolle')
        plot_vline_with_location(ax,990.5,0.1,990.5,0.2,'Inlaat Reevediep')
        plot_vline_with_location(ax,994.5,0.1,994.5,0.2,'Kampen')
        
        ax.grid()
        ax.legend(loc='upper right')
        ax.set_title(runid)
        ax.set_ylabel('waterstand [m+NAP]')
        ax.set_xlabel('rivierkilometer')
        plt.tight_layout()
        
        ax = axs[1]
        ax.plot(WTImax13_km, wl_verschil,label=wl_verschil_label)
        ax.set_ylim(-0.5,0.5)
        plot_vline_with_location(ax,957,0.1,957,0.2,'Olst')
        plot_vline_with_location(ax,965,0.1,965,0.2,'Wijhe')
        plot_vline_with_location(ax,980,0.1,980,0.2,'Zwolle')
        plot_vline_with_location(ax,990.5,0.1,990.5,0.2,'Inlaat Reevediep')
        plot_vline_with_location(ax,994.5,0.1,994.5,0.2,'Kampen')
    
        ax.grid()
        ax.legend()
        ax.set_title(runid)
        ax.set_ylabel('waterstandsverschil [m]')
        ax.set_xlabel('rivierkilometer')
        plt.tight_layout()
        
        fig.savefig(os.path.join(paths['output_figures'], 'consistency', '{}_{}.png'.format(somid, 'wl_IJssel_met_WTI2017')), dpi=150)
        plt.close(fig)

#%%

    # Controle afvoeren
    print('plot afvoeren ...')
    #--------------------------------------------------------------------------------
    ymin = -3000
    ymax = +5000
    figrows = 4
    figcols = 1
    fig, axs = plt.subplots(figrows,figcols,figsize=(25/2.54, 18/2.54))
    
    Qnames = ['debiet-raai Den Oever','debiet-raai Kornwerderzand','Q-ZwartsluisZwartemeer']
    #if re.search("_WTI2017" , inputparametersfile):
    if re.search("uitgezetvoorpr3871" , inputparametersfile):
        Qnames = ['debiet-raai Den Oeve','debiet-raai Kornwerd','Q-ZwartsluisZwarteme']

    Quit = ctrv_nc[Qnames[0]] + ctrv_nc[Qnames[1]]
    Qin  = ctrv_nc['33_VE'] + ctrv_nc['956.00_IJ']
    
    # inlezen windverloop
    windverloop = pd.read_csv(windv, sep=';')
    
    ax=axs[0]
    ax.plot(ctrv_nc['33_VE'],label='33_VE')
    ax.plot(ctrv_nc[Qnames[2]],label='Q-ZwartsluisZwartemeer')
    #if re.search("_WTI2017" , inputparametersfile):
    if re.search("uitgezetvoorpr3871" , inputparametersfile):
        tnew = np.array([7200,15840])
        ax.set_xlim(tnew[0]-0.05*np.diff(tnew),tnew[1]+0.05*np.diff(tnew))
    ax.set_title(runid)
    ax.set_ylabel('afvoer [m$^{3}$/s]')
    ax.grid()
    ax.legend()
    ax.text(0.025, 0.85 ,'Vecht (neg. = bovenstr. richting)', ha='left', va='center', fontsize=10, transform=axs[0].transAxes)
    ax.set_title(runid)
    
    ax=axs[1]
    ax.plot(ctrv_nc['956.00_IJ'],label='Q956')
    ax.plot(ctrv_nc['990.00_IJ'],label='Q990')
    ax.plot(ctrv_nc['992.00_IJ'],label='Q992')
    ax.plot(ctrv_nc['1001.00_IJ'],label='Q1001')
    ax.plot(ctrv_nc['1006.00_IJ'],label='Q1006')
    #if re.search("_WTI2017" , inputparametersfile):
    if re.search("uitgezetvoorpr3871" , inputparametersfile):
        tnew = np.array([7200,15840])
        ax.set_xlim(tnew[0]-0.05*np.diff(tnew),tnew[1]+0.05*np.diff(tnew))
    xlim=ax.get_xlim()
    ylim=ax.get_ylim()
    y0 = ylim[0]+0.1*np.diff(ylim)/2
    y1 = ylim[1]-0.1*np.diff(ylim)/2
    wv = np.array([y0,y0,y1,y1,y0,y0])
    ax.set_xlim(xlim)
    ax.plot(windverloop['tijd'],wv,color='grey',label='windverloop',linestyle='-.',linewidth=0.75)
    ax.text(0.025, 0.85 ,'IJssel (neg. = bovenstr. richting)', ha='left', va='center', fontsize=10, transform=axs[1].transAxes)
    ax.set_ylabel('afvoer [m$^{3}$/s]')
    ax.grid()
    ax.legend()

    #if not re.search("_WTI2017" , inputparametersfile):
    if not re.search("uitgezetvoorpr3871" , inputparametersfile):
        ax=axs[2]
        ax.plot(- ctr_nc['Qrvdp1'],label='Qrvdp1')
        ax.plot( ctrv_nc['Qrvdp2'],label='Qrvdp2')
        xlim=ax.get_xlim()
        ylim=ax.get_ylim()
        y0 = ylim[0]+0.1*np.diff(ylim)/2
        y1 = ylim[1]-0.1*np.diff(ylim)/2
        wv = np.array([y0,y0,y1,y1,y0,y0])
        ax.set_xlim(xlim)
        ax.plot(windverloop['tijd'],wv,color='grey',label='windverloop',linestyle='-.',linewidth=0.75)
        ax.text(0.025, 0.85 ,'Reevediep (neg. = richting IJssel)', ha='left', va='center', fontsize=10, transform=axs[2].transAxes)
        ax.set_ylabel('afvoer [m$^{3}$/s]')
        ax.grid()
        ax.legend()
    
    ax=axs[3]
    ax.plot( Qin,label='Qin_IJssel_Vecht')
    ax.plot(ctrv_nc['1006.00_IJ'],label='Q1006')
    ax.plot(Quit,label='Quit',linestyle='--')
    ax.text(0.025,0.85 ,'Volume-check', ha='left', va='center', fontsize=10, transform=axs[3].transAxes)
#    if re.search("_WTI2017" , inputparametersfile):
    if re.search("uitgezetvoorpr3871" , inputparametersfile):
        tnew = np.array([7200,15840])
        ax.set_xlim(tnew[0]-0.05*np.diff(tnew),tnew[1]+0.05*np.diff(tnew))
    ax.set_xlabel('tijd [minuten]')
    ax.set_ylabel('afvoer [m$^{3}$/s]')
    ax.grid()
    ax.legend()

    plt.tight_layout()

    fig.savefig(os.path.join(paths['output_figures'], 'consistency', '{}_{}.png'.format(somid, 'afvoeren')), dpi=150)
    plt.close(fig)

#%%

    # Controle Stuwen Vecht + Kadoeler keersluis
    print('plot controle Stuwen Vecht + Kadoeler keersluis ...')
    #--------------------------------------------------------------------------------
    figrows = 3
    figcols = 1
    fig, axs = plt.subplots(figrows,figcols,figsize=(25/2.54, 12.5/2.54))

#        --- sturing voor Kadoelerkeersluis ---
#     dicht als peil Zwartewater boven NAP + 1.0m  

    #Pos. 1: Actual time for time series 2: Preferred sill level 3: Actual sill level 4: Preferred gate level 5: Actual gate level 6: Preferred barrier width 7: Actual barrier width.'
    #let op: hieronder idx = Pos - 1
    sill_levels = io.read_ncfile(os.path.join(paths['somdir'], somid, runid+'_barriers.nc'), indexvar='TIME', colvar='NAMBAR', datavar='RRSBAH', level=3-1, method='scipy')
    gate_levels = io.read_ncfile(os.path.join(paths['somdir'], somid, runid+'_barriers.nc'), indexvar='TIME', colvar='NAMBAR', datavar='RRSBAH', level=5-1, method='scipy')
    sill_levels = sill_levels[1:]
    gate_levels = gate_levels[1:]
    
    xmin = sill_levels.index[0]
    xmax = sill_levels.index[-1]
    
    axs[0].plot(-sill_levels['Vilsteren'],label='sill Vilsteren')
    #axs[0].set_xlim(xmin,xmax)
    axs[0].grid()
    axs[0].legend()
    axs[0].set_ylabel('sill level [m+NAP]')
    axs[0].set_title(runid)
    axs[1].plot(-sill_levels['Vechterweerd'],label='sill Vechterweerd')
    #axs[1].set_xlim(xmin,xmax)
    axs[1].grid()
    axs[1].legend()
    axs[1].set_ylabel('sill level [m+NAP]')
    axs[2].plot(-sill_levels['Kadoelen'],label='sill Kadoelen')
    axs[2].plot( gate_levels['Kadoelen'],label='gate Kadoelen')
    axs[2].plot( zwl_nc['Kadoelen_waq'],label='wl Kadoelen_waq')
    #axs[2].set_xlim(xmin,xmax)
    axs[2].grid()
    axs[2].legend()
    axs[2].set_ylabel('sill en gate level [m+NAP]\nwater level [m+NAP]')
    axs[2].set_xlabel('tijd [minuten]')

    plt.tight_layout()

    fig.savefig(os.path.join(paths['output_figures'], 'consistency', '{}_{}.png'.format(somid, 'StuwenVechtKadoelen')), dpi=150)
    plt.close(fig)

#%%

    # Controle Veessen Wapenveld
    print('plot controle Veessen Wapenveld ...')
    #--------------------------------------------------------------------------------
    ymin = 0
    ymax = +5000
    figrows = 2
    figcols = 1
    fig, axs = plt.subplots(figrows,figcols,figsize=(25/2.54, 12.5/2.54))

    #Pos. 1: Actual time for time series 2: Preferred sill level 3: Actual sill level 4: Preferred gate level 5: Actual gate level 6: Preferred barrier width 7: Actual barrier width.'
    #let op: hieronder idx = Pos - 1
    sill_levels = io.read_ncfile(os.path.join(paths['somdir'], somid, runid+'_barriers.nc'), indexvar='TIME', colvar='NAMBAR', datavar='RRSBAH', level=2, method='scipy')
    sill_levels = sill_levels[1:]
    xmin = sill_levels.index[0]
    xmax = sill_levels.index[-1]
    
    #vw_uitlaat_r
    axs[0].plot(ctrv_nc['961.00_IJ'],label='Q961')
    axs[0].plot(ctrv_nc['963.00_IJ'],label='Q963')
    axs[0].plot(ctrv_nc['961.00_IJ']-ctrv_nc['963.00_IJ'],label='Afvoerverschil')
    #if not re.search("_WTI2017" , inputparametersfile):
    if not re.search("uitgezetvoorpr3871" , inputparametersfile):
        axs[0].plot(ctrv_nc['Qvw1'],label='Qvw1')
        axs[0].plot(ctrv_nc['Qvw2'],label='Qvw2')
    axs[0].legend()
    #axs[0].set_ylim(ymin,ymax)
    #axs[0].set_xlim(xmin,xmax)
    axs[0].grid()
    axs[0].set_title(runid)
    axs[0].set_ylabel('afvoer [m$^{3}$/s]')

    axs[1].plot(-sill_levels['vw_inlaat14'],label='vw_inlaat14')
    #if not re.search("_WTI2017" , inputparametersfile):
    if not re.search("uitgezetvoorpr3871" , inputparametersfile):
        axs[1].plot(-sill_levels['vw_uitlaat_r'],label='vw_uitlaat_r')
        axs[1].plot(-sill_levels['vw_uitlaat_l'],label='vw_uitlaat_l')
    #axs[1].set_xlim(xmin,xmax)
    axs[1].grid()
    axs[1].legend()
    axs[1].set_ylabel('sill level [m+NAP]')
    axs[1].set_xlabel('tijd [minuten]')

    plt.tight_layout()

    fig.savefig(os.path.join(paths['output_figures'], 'consistency', '{}_{}.png'.format(somid, 'VeessenWapenveld')), dpi=150)
    plt.close(fig)

#%%    

    # Plot waterstand rivieras (IJssel)
    #if not re.search("_WTI2017" , inputparametersfile):
    if not re.search("uitgezetvoorpr3871" , inputparametersfile):
        print('plot waterstand IJssel en Reevediep ...')
        #--------------------------------------------------------------------------------
        
        for typ in ['max13','last25']:
        
            figrows = 2
            figcols = 1
            fig, axs = plt.subplots(figrows,figcols,figsize=(25/2.54, 12.5/2.54))
            
            # RIVIERAS IJSSEL
            max13_rkm = stationdata.loc[stationdata.index.str.startswith('km'),typ]
            rkm = max13_rkm.index.tolist()
            rkm_vals = np.zeros(len(rkm))
            for i in range(len(rkm)):    
                rkm_vals[i] = (rkm[i][2:-3])
        
            RDws_x = np.empty([0,1])
            RDws_z = np.empty([0,1])
            # AS REEVEDIEP
            
            RD_as_01 = pd.DataFrame(stationdata.loc[stationdata.index.str.startswith('RD_as_01'),typ])
            RD_as_01['afstand'] = pd.Series(np.arange(0,401,100),index=RD_as_01.index)
            RD_as_02 = pd.DataFrame(stationdata.loc[stationdata.index.str.startswith('RD_as_02'),typ])
            RD_as_02['afstand'] = pd.Series(np.arange(600,1001,100),index=RD_as_02.index)
            RD_as_03 = pd.DataFrame(stationdata.loc[stationdata.index.str.startswith('RD_as_03'),typ])
            RD_as_03['afstand'] = pd.Series(np.arange(0,1101,100),index=RD_as_03.index)
            RD_as_04 = pd.DataFrame(stationdata.loc[stationdata.index.str.startswith('RD_as_04'),typ])
            RD_as_04['afstand'] = pd.Series(np.arange(1100,7001,100),index=RD_as_04.index)
            RD_as_05 = pd.DataFrame(stationdata.loc[stationdata.index.str.startswith('RD_as_05'),typ])
            RD_as_05['afstand'] = pd.Series(np.arange(0-900+7100,10401-900+7100,100),index=RD_as_05.index)
                
            axs[0].plot(rkm_vals,max13_rkm,label='wl rivieras',zorder=10)
            axs[0].legend()
            axs[0].grid(b=True, which='both', color='0.65',linestyle='-')
            axs[0].set_title(runid)
            axs[0].set_xlabel('rivierkilometer')
            axs[0].set_ylabel('waterstand [m+NAP]')
    
            ax = axs[0]
            plot_vline_with_location(ax,957,0.1,957,0.2,'Olst')
            plot_vline_with_location(ax,965,0.1,965,0.2,'Wijhe')
            plot_vline_with_location(ax,980,0.1,980,0.2,'Zwolle')
            plot_vline_with_location(ax,990.5,0.1,990.5,0.2,'Inlaat Reevediep')
            plot_vline_with_location(ax,994.5,0.1,994.5,0.2,'Kampen')
        
            mark=''
            axs[1].plot(RD_as_01['afstand'],RD_as_01[typ],marker=mark,label='RD_as_01',zorder=10)
            axs[1].plot(RD_as_02['afstand'],RD_as_02[typ],marker=mark,label='RD_as_02',zorder=10)
            axs[1].plot(RD_as_03['afstand'],RD_as_03[typ],marker=mark,label='RD_as_03',zorder=10)
            axs[1].plot(RD_as_04['afstand'],RD_as_04[typ],marker=mark,label='RD_as_04',zorder=10)
            axs[1].plot(RD_as_05.iloc[9:]['afstand'],RD_as_05.iloc[9:][typ],marker=mark,label='RD_as_05',zorder=10)
            axs[1].legend()
            axs[1].grid(b=True, which='both', color='0.65',linestyle='-')
            axs[1].set_xlabel('afstand vanaf instroom [m]')
            axs[1].set_ylabel('waterstand [m+NAP]')
        
            ax = axs[1]
            plot_vline_with_location(ax,575,0,575,100,'huidige dijk')
    
            ylims = axs[1].get_ylim()
            fs = 8
            xpos = 575
            xlab = xpos + 100
            xnam = 'huidige dijk'
            axs[1].axvline(xpos,color='gray',zorder=0,linewidth=0.5)
            axs[1].text(xlab,0.05*np.diff(ylims)+ylims[0],xnam,rotation=90, ha='left', va='bottom', fontsize=fs)
            xpos = 2600
            xlab = xpos + 100
            xnam = 'N50'
            axs[1].axvline(xpos,color='gray',zorder=0,linewidth=0.5)
            axs[1].text(xlab,0.05*np.diff(ylims)+ylims[0],xnam,rotation=90, ha='left', va='bottom', fontsize=fs)
            xpos = 9075
            xlab = xpos + 100
            xnam = 'Roggebotsluis'
            axs[1].axvline(xpos,color='gray',zorder=0,linewidth=0.5)
            axs[1].text(xlab,0.05*np.diff(ylims)+ylims[0],xnam,rotation=90, ha='left', va='bottom', fontsize=fs)
        
            plt.tight_layout()
        
            fig.savefig(os.path.join(paths['output_figures'], 'consistency', '{}_{}_{}.png'.format(somid, 'wl_rivieras_Reevediep', typ)), dpi=150)
            plt.close(fig)

#%%    

#%%

    # Plot balgstuw
    print('plot balgstuw Ramspol ...')
    #--------------------------------------------------------------------------------
    
    figrows = 3
    figcols = 1
    fig, axs = plt.subplots(figrows,figcols,figsize=(25/2.54, 12.5/2.54))

    #Pos. 1: Actual time for time series 2: Preferred sill level 3: Actual sill level 4: Preferred gate level 5: Actual gate level 6: Preferred barrier width 7: Actual barrier width.'
    #let op: hieronder idx = Pos - 1
    idx=2
    lockname='Balgstuw_Ramsdiep'
    barrier_nc = os.path.join(paths['somdir'], somid, runid+'_barriers.nc')
    sill_level = io.read_ncfile(barrier_nc, indexvar='TIME', colvar='NAMBAR',
                             datavar='RRSBAH', level=idx,
                             method='scipy')[lockname]
    sill_level = sill_level[1:]
    xmin = sill_level.index[0]
    xmax = sill_level.index[-1]
    
    axs[0].plot(-sill_level,label=lockname)
    #axs[0].set_xlim(xmin,xmax)
    axs[0].grid()
    axs[0].legend()
    axs[0].set_title(runid)
    axs[0].set_ylabel('sill level [m+NAP]')
    axs[1].plot(zwl_nc['Balg_Ramsgeul_west'],label='Balg_Ramsgeul_west')
    axs[1].plot(zwl_nc['Balg_Ramsgeul_oost'],label='Balg_Ramsgeul_oost')
    axs[1].plot(zwl_nc['Balg_Ramsgeul_west']-zwl_nc['Balg_Ramsgeul_oost'],label='verval (west minus oost)')
    #axs[1].set_xlim(xmin,xmax)
    axs[1].grid()
    axs[1].legend()
    axs[1].set_ylabel('waterstand [m+NAP] \n verval [m]')
    Qnames = ['debiet-raai Ramspol']
    #if re.search("_WTI2017" , inputparametersfile):
    if re.search("uitgezetvoorpr3871" , inputparametersfile):
        Qnames = ['debiet-raai_Ramspol']
    
    axs[2].plot(ctrv_nc[Qnames[0]],label='debiet-raai Ramspol')
    #axs[2].set_xlim(xmin,xmax)
    axs[2].grid()
    axs[2].legend()
    axs[2].set_xlabel('tijd [minuten]')
    axs[2].set_ylabel('afvoer [m$^{3}$/s]')

    plt.tight_layout()

    fig.savefig(os.path.join(paths['output_figures'], 'consistency', '{}_{}.png'.format(somid, 'Balgstuw')), dpi=150)
    plt.close(fig)

#%%    

    # Plot local maps
#    print('plot local maps ...')
#    #--------------------------------------------------------------------------------
#    varaxis=np.array([[39.80,  44.80,  408.70,  412.30],[44.10,  50.10,  410.00,  413.40],[49.50,  52.50,  405.50,  410.50],
#                      [50.00,  56.10,  403.20,  406.50],[56.00,  60.50,  401.20,  404.50],[60.30,  65.30,  401.60,  405.90],
#                      [64.00,  72.50,  405.40,  410.80],[65.20,  71.30,  401.60,  405.60],[56.50,  61.00,  397.20,  401.30],
#                      [60.00,  64.00,  394.00,  398.00],[63.00,  67.00,  392.00,  394.50],[66.50,  71.00,  391.30,  393.80],
#                      [70.00,  73.90,  389.00,  392.00],[71.50,  74.20,  385.30,  389.50],[70.10,  74.10,  383.20,  385.70],
#                      [66.30,  70.30,  382.80,  385.30],[63.00,  66.50,  384.00,  387.50],[62.25,  64.75,  387.30,  390.80],
#                      [59.50,  63.50,  390.50,  393.50],[56.00,  60.50,  392.40,  394.90],[49.30,  53.30,  395.50,  398.50],
#                      [45.00,  50.00,  402.00,  405.00],[40.50,  45.50,  401.70,  404.50],[36.80,  40.80,  401.40,  404.40],
#                      [36.80,  40.80,  404.00,  408.00],[39.00,  41.60,  407.00,  410.50]])
#
#    fig, ax = plt.subplots(figsize=(16/2.54, 12/2.54))
#    ax.set_xlim(*xlims2D)
#    ax.set_ylim(*ylims2D)
#    ax.set_facecolor('#dddddd')
#    
#    lb = np.loadtxt(paths['landboundary'])
#    Z = wetmaxval[1:-1,1:-1]
#    vmin, vmax = np.percentile(Z[~np.isnan(Z)], [1, 99])
#    cmesh = ax.pcolormesh(grid.xcc/1000., grid.ycc/1000., Z, cmap='viridis', vmin=vmin, vmax=vmax)
#    cb = plt.colorbar(cmesh)
#    cb.set_label('Max. Water level [m+NAP]')
#    ax.set_aspect('equal')
#    
#    ax.plot(*zip(*lb), color='C1')
#    ax.plot(set1.x[~np.isnan(set1.max13)]/1000., set1.y[~np.isnan(set1.max13)]/1000., color='red', marker = '.', ls='', mew=0.5, label='Set1', ms=4)
#    ax.plot(set2.x[~np.isnan(set2.max13)]/1000., set2.y[~np.isnan(set2.max13)]/1000., color='C6', marker = '.', ls='', mew=0.5, label='Set2', ms=4)
#    ax.plot(setrest.x[~np.isnan(setrest.max13)]/1000., setrest.y[~np.isnan(setrest.max13)]/1000., color='yellowgreen', marker = '.', ls='', mew=0.5, label='Other', ms=4)
#    
#    ax.plot(set1.x[np.isnan(set1.max13)]/1000., set1.y[np.isnan(set1.max13)]/1000., color='red', marker = 'x', ls='', mew=1.5, label='Set1 NaN', ms=7)
#    ax.plot(set2.x[np.isnan(set2.max13)]/1000., set2.y[np.isnan(set2.max13)]/1000., color='C6', marker = 'x', ls='', mew=1.5, label='Set2 NaN', ms=7)
#    ax.plot(setrest.x[np.isnan(setrest.max13)]/1000., setrest.y[np.isnan(setrest.max13)]/1000., color='yellowgreen', marker = 'x', ls='', mew=1.5, label='Other NaN', ms=7)
#    
#    ax.legend()
#    ax.grid()
#    ax.set_ylabel('Y [km]')
#    ax.set_xlabel('X [km]')
#    
#    for i, lims in enumerate(varaxis):
#        xdiff = np.diff(lims[:2])
#        ydiff = np.diff(lims[2:])
#        if xdiff < ydiff:
#            lims[0] -= (ydiff-xdiff)/2.
#            lims[1] += (ydiff-xdiff)/2.
#        if ydiff < xdiff:
#            lims[2] -= (xdiff-ydiff)/2.
#            lims[3] += (xdiff-ydiff)/2.
#        ax.set_xlim(lims[0], lims[1])
#        ax.set_ylim(lims[2], lims[3])
#        
#        plt.tight_layout()
#        fig.savefig(os.path.join(paths['output_figures'], 'localmaps', somid, '{}_{}_DryPoints_dh{:02d}.png'.format(somid, runid, i+1)), dpi=150)
#
#    plt.close(fig)


if __name__ == "__main__":
    
    args = sys.argv
    
    plot_timeseries = False # default
    
    if len(args) == 1:
        
        somid = 'wYVG-Q03U34D292S01'
        runid = 'wYVG-Q03U34D292S01'
        inputparametersfile = '../06-WTI2017_geenBypass/berekeningen/input_generalparameters.ini'
        plot_timeseries = False

        # WTI2017
        #somid = 'wYVG-Q09U43D292S05'
        #runid = 'wYVG-Q09U43D292S05'
        #inputparametersfile = '../01-test_WTI2017/input_generalparameters_WTI2017.ini'
        #plot_timeseries=False
        
    else:
        
        somid = args[1]
        runid = args[2]
        inputparametersfile = args[3]
        plot_timeseries = args[4]
        if not os.path.exists(inputparametersfile):
            raise OSError('Path not found: "{}"'.format(inputparametersfile))

    Qnum = float(runid[6:8])
    if Qnum<=6:
        TFHISTO =  2880.0
        TIHISTO =     5.0
        TLHISTO =  8640.0
        windv = 'input_generalmodeldata/windverloop_afv_const.csv'
    else:
        TFHISTO =  7200.0
        TIHISTO =     1.0
        TLHISTO = 18720.0
        windv = 'input_generalmodeldata/windverloop_afv_golf.csv'

    if re.search("06-WTI2017_geenBypass" , inputparametersfile):
        TIHISTO =     1.0

    if re.search("02_WTI2017_geenBypass_met_wda-RD2018_mRB_wda_N105" , inputparametersfile):
        TIHISTO =     1.0
    
    print('plot_timeseries='+str(plot_timeseries))
    
    check_timeseries(somid, runid, inputparametersfile, TFHISTO, TIHISTO, TLHISTO)
    plot_checkfigs  (somid, runid, inputparametersfile, TFHISTO, TIHISTO, TLHISTO, windv, plot_timeseries)
    