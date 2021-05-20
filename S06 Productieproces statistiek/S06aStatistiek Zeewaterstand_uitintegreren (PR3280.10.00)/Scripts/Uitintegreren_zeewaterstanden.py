"""
Script uitintegreren onzekerheid van de piekafvoer in de basisduur (B = 30 dagen),
als onzekerheid normaal is verdeeld (additief model). In dit script is het MATLAB
script van Chris Geerse (PR3216.10, november 2015) omgezet naar python

Door: Guus Rongen
PR3280.10
Datum: maart 2016.

"""

#%% Importeer modules
import matplotlib.pyplot as plt
import numpy as np
import sys
sys.path.append(r'D:\Documents\Python Scripts')
from myfuncs import plotting
import pandas as pd
plotting.set_rcparams()
plt.rcParams['font.size'] = 8
import scipy.stats as st
import os
from scipy.interpolate import interp1d

#%%
## Invoer

plt.close('all')

path = r'D:\Documents\3280.10 WTI Vergelijkingsanalyse\Uitintegreren\\'


#%% Definieer functie om kansen weg te schrijven naar Hydra NL format

def write_to_hydra_format(data, newpath, headerpath, headerinp):
    """
    Function to write (currently only) water level exceedance probabilities
    to HydraNL format
    
    Input:
    data : 2d array or list with in the first column the water levels and in
        the other columns the exceedance probabilities per wind direction.
        The wind directions start at 30, not 360.
    headerinp : dictionary with strings in the header which should be will
        be replaced with other strings.
    newpath : Path to write HydraNL input file to
    """
    
    # Open new file
    f = open(newpath, 'w')
    
    # Write header
    with open(headerpath, 'r') as hf:
        header = hf.read()
        for key, value in zip(headerinp.keys(), headerinp.values()):
            header = header.replace(key, value)
        f.write(header)
        f.write('\n')
    
    # Write probabilities
    for i, d in enumerate(data):
        # Only write with a 0.1 interval, and the last line
        if i%10 == 0 or i == len(data)-1:
            ls = '  {:<10.2f}{:<16.3e}{:<16.3e}{:<16.3e}{:<16.3e}{:<16.3e}{:<16.3e}{:<16.3e}{:<16.3e}{:<16.3e}{:<16.3e}{:<16.3e}{:<16.3e}'.format(*d)
            # Add line to file
            f.write(ls)
            # Add line break if not last line
            if i != len(data) - 1:
                f.write('\n')
    
    f.close()

def write_to_csv(data, newpath):
    """
    Function to write (currently only) water level exceedance probabilities
    to HydraNL format
    
    Input:
    data : 2d array or list with in the first column the water levels and in
        the other columns the exceedance probabilities per wind direction.
        The wind directions start at 30, not 360.
    headerinp : dictionary with strings in the header which should be will
        be replaced with other strings.
    newpath : Path to write HydraNL input file to
    """
    
    # Open new file
    f = open(newpath, 'w')
    
    # Write header
    headerline = 'm \ r (m+NAP),'
    headerline += ''.join('{};'.format(r) for r in range(30, 361, 30))[:-1]
    f.write(headerline)
    f.write('\n')
    
    # Write probabilities
    for i, d in enumerate(data):
        # Only write with a 0.1 interval, and the last line
        if i%10 == 0 or i == len(data)-1:
            ls = '  {:<.2f};{:<.3e};{:<.3e};{:<.3e};{:<.3e};{:<.3e};{:<.3e};{:<.3e};{:<.3e};{:<.3e};{:<.3e}{:<.3e};{:<.3e}'.format(*d)
            # Add line to file
            f.write(ls)
            # Add line break if not last line
            if i != len(data) - 1:
                f.write('\n')
    
    f.close()

#%%

station_namen = os.listdir(path+'FTP Deltares')
station_namen = [naam.replace('Water level ', '').replace('.xlsx', '') for naam in station_namen]

zws_excel = pd.read_excel(path+'Toeleveringen\Afleiding_zeewaterstandstatistiek.xls', sheetname = 'Zeelocaties', parse_cols = [0, 8], header = None)

locs = []
zwss = []
for i, (loc, zws) in enumerate(zip(zws_excel.iloc[:,0].values, zws_excel.iloc[:,1].values)):
    if i%15 == 0:
        locs.append(loc[:-1])
    if (i-9)%15 == 0:
        zwss.append(zws)

start_waterstanden = {}
for loc, zws in zip(locs, zwss):
    loc = loc.replace('Oosterschelde buiten', 'OS11')
    loc = loc.replace('West-Terschelling', 'Terschelling')
    loc = loc.replace('IJmuiden', 'IJmuiden Buitenhaven')
    start_waterstanden[loc] = zws

start_waterstanden['Vlissingen (virtueel)'] = start_waterstanden['Vlissingen']
start_waterstanden['IJmuiden Buitenhaven (virtueel)'] = start_waterstanden['IJmuiden Buitenhaven']


for sNaam in station_namen:

    infile = 'Water level {}.xlsx'.format(sNaam)
    
    print('Analyse voor {}'.format(sNaam))

    # Lees Weibull parameters uit
    wblPars = pd.read_excel(path+'FTP Deltares\\'+infile, sheetname = 'Water level data', parse_cols = range(8), skiprows = 6)
    
    # lees onzekerheidsgroottes uit
    stUnc = pd.read_excel(path+'FTP Deltares\\'+infile, sheetname = 'Statistical uncertainty', parse_cols = range(3), skiprows = 6)
    
    # Lees x en y locatie uit
    loc = pd.read_excel(path+'FTP Deltares\\'+infile, sheetname = 'Water level variable', parse_cols = [7, 8], skiprows = 3, header = None)
    RDx = loc.values[0,0]
    RDy = loc.values[0,1]
    
    stUnc.columns = ['H', 'mu', 'sigma']
    
    def condWeib(m, lamWbl, sigWbl, alfWbl, omeWbl):
        mPov = lamWbl * np.exp( -(m/sigWbl)**alfWbl + (omeWbl/sigWbl)**alfWbl )
        return mPov
    
    # Grid voor m-waarden (zonder onzekerheid)
    #     mMin  = omeWbl(r);
    mMin  = start_waterstanden[sNaam]
    mSt   = 0.01
    mMax  = 8.
    mGrid = np.arange(mMin, mMax+0.001, mSt)
    mHulp = np.arange(mMin, mMax+0.001, 0.1)
    
    # Grid voor v-waarden (met onzekerheid)
    vSt   = mSt
    vMin  = mMin #- 0.5
    vMax  = mMax
    vGrid = np.arange(vMin, vMax+0.001, vSt)
    
    # Initialisatie:
    vPov = np.zeros((len(vGrid), 12))
    mPov = np.zeros_like(vPov)
    
    rfig = [360]+list(range(30,331,30))
    
    for r in range(12):
        
        sigWbl  = wblPars.values[r,1]
        alfWbl = wblPars.values[r,2]
        omeWbl = wblPars.values[r,3]
        lamWbl = wblPars.values[r,4]
        Pr = wblPars.values[r,5]
        
        # Uitintegreren onzekerheid (additief model)
        # Model:
        # V_incl = Vexcl + Y.
        # Y ~ N(mMu, mSig).
        
    
        # Interpoleer onzekerheid (lineair over waterstandsrichting)
        f = interp1d(stUnc.H, stUnc.mu, kind = 'linear', fill_value = 'extrapolate')
        mMu = f(mGrid)
        f = interp1d(stUnc.H, stUnc.sigma, kind = 'linear', fill_value = 'extrapolate')
        mSig = f(mGrid)
    
        #======================================================================
        # Bereken overschrijdingskansen van zeewaterstanden incl. onzekerheid
        # Weibull
        #======================================================================
    
        # Bapaal klassekansen: vector met waarden f(m)dm = P(M>m) - P(M>m+dm):
        # NB: bepaalCondWbl betreft P(M>m) voor m > omeWbl. I.h.b. geeft P(M > omeWbl).
        mPovHulp = condWeib(mHulp, lamWbl, sigWbl, alfWbl, omeWbl)
        
        # Corrigeer voor lage waarden door logaritmisch de interpoleren
        mPovHulp[0] = 1
        mPovHulp[1:3] = np.exp(np.interp(mHulp[1:3], [mHulp[0], mHulp[3]], np.log([mPovHulp[0], mPovHulp[3]])))
        
        f = interp1d(mHulp, np.log(mPovHulp), kind = 'linear', fill_value = 'extrapolate')
        mPov[:,r] = np.exp(f(mGrid))
        # Waarden kleiner dan 1e-300 worden nan's. Uitintegreren lukt dan niet
        # meet, dus verkort het mgrid tot die waarden
        mPov[:,r][np.isnan(mPov[:,r])] = 0 
        mPov[:,r][mPov[:,r] < 1e-300] = 0
        
        # Zet de maximale kans op 1
        mPov[:,r] = np.minimum(1, mPov[:,r])
                
        
        klassekansen = mPov[:,r] - np.roll(mPov[:,r], -1)
        klassekansen[-1] = 0  #maak laatste klasse 0
    
        for i in range(np.shape(vPov)[0]):
            # Bereken overschrijdingskans voor vGrid(i), incl. onzekerheid:
            PovHulp    = 1 - st.norm.cdf(vGrid[i] - mGrid, loc = mMu, scale = mSig)   #vector van formaat mGrid
            Som        = np.sum(PovHulp * klassekansen)                    # waarde van de integraal
    
            vPov[i, r] = Som
        
        # Correct
        vPov[0, r] = 1
    
    
        #==============================================================================
        # Creeer figuren
        #==============================================================================
    
        # Eerst voor een 12 uurs overschrijdingskans
        fig, ax = plt.subplots(figsize = (14/2.54, 12/2.54))
        
        ax.grid(which = 'both', axis = 'both')
        ax.set_yscale('log')
        ax.set_xlim(start_waterstanden[sNaam], 8)
        ax.plot(mGrid, mPov[:,r], 'b-', lw = 1.5, label = 'Zonder onzekerheid')
        ax.plot(vGrid, vPov[:,r], 'r-', lw = 1.5, label = 'Met onzekerheid')
        ax.set_ylim(ax.get_ylim()[0], 2)
        
        ax.set_title('Conditionele overschrijdingskans (per 12 uur) zeewaterstand {} r = {}'.format(sNaam, rfig[r]))
        ax.set_xlabel('Zeewaterstand [m+NAP]')
        ax.set_ylabel('Overschrijdingskans [-]')    
        
        lg = ax.legend(loc = 'best')
        plotting.adjust_lg(lg)
        
        plt.tight_layout()
    
        fig.savefig(path+'Figuren\{}_{}_12uur.png'.format(sNaam, rfig[r]), dpi = 150)
        
#         Nu voor een jaarlijkse overschrijdingskans (overschrijdingsfrequentie)
#         Omrekenen van 12 uur naar jaar:
#         Fjaar(M > m , r) =  F12uur(M > m | r) * N * P(r)
#         Hierin is N het aantal 12-uursblokken in een half jaar (180 dagen)
        
    #    fig, ax = plt.subplots(figsize = (14/2.54, 12/2.54))
    #    
    #    ax.grid(which = 'both', axis = 'both')
    #    ax.set_yscale('log')
    #    ax.set_xlim(1.5, 8)
    #    ax.plot(mGrid, mPov[:,r] * 360 * Pr, 'b-', lw = 1.5, label = 'Zonder onzekerheid')
    #    ax.plot(vGrid, vPov[:,r] * 360 * Pr, 'r-', lw = 1.5, label = 'Met onzekerheid')
    #    
    #    ax.set_title('Conditionele overschrijdingskans (per jaar) zeewaterstand {} r = {}'.format(sNaam, rfig[r]))
    #    ax.set_xlabel('Zeewaterstand [m+NAP]')
    #    ax.set_ylabel('Overschrijdingskans [-]')    
    #    
    #    lg = ax.legend(loc = 'best')
    #    plotting.adjust_lg(lg)
    #    
    #    plt.tight_layout()
    #
    #    fig.savefig(path+'Figuren\{}_jaar.png'.format(rfig[r]), dpi = 150)
        plt.close('all')
        
            
    #==========================================================================
    # Schrijf naar Hydra-NL formaat
    #==========================================================================
    
    # Eerst zonder onzekerheid:
    # In vPov komt 360 graden eerst voor. 'rol' de array daarom zodanig dat 30 graden vooraan staat
    data = np.c_[mGrid, np.roll(mPov, -1, axis = 1)]
    
    # Header dictionary
    headerpath = path+r'HydraNL\HydraNLheader.txt'
    
    headerinp = dict(STATION = sNaam,
                     METZONDER = 'zonder',
                     LOCX = str(int(RDx)),
                     LOCY = str(int(RDy)))
    
    # Roep schrijffunctie aan
    write_to_hydra_format(data, path+'HydraNL\OvkansZee_{}_2017.txt'.format(sNaam), headerpath, headerinp)
    write_to_csv(data, path+'CSV\OvkansZee_{}_2017.csv'.format(sNaam))
    
    # Met zonder onzekerheid:
    data = np.c_[vGrid, np.roll(vPov, -1, axis = 1)]
    headerinp['METZONDER'] = 'met'
    
    write_to_hydra_format(data, path+'HydraNL\OvkansZee_{}_2017_metOnzHeid.txt'.format(sNaam), headerpath, headerinp)
    write_to_csv(data, path+'CSV\OvkansZee_{}_2017_metOnzHeid.csv'.format(sNaam))
    