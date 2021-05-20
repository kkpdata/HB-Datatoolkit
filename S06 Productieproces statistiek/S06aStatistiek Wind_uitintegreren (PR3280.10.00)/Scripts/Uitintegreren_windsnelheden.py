"""
Script uitintegreren onzekerheid van de piekafvoer in de basisduur (B = 30 dagen),
als onzekerheid normaal is verdeeld (additief model). In dit script is het MATLAB
script van Chris Geerse (PR3216.10, november 2015) omgezet naar python

Door: Guus Rongen
PR3280.10
Datum: maart 2016.

"""

# Importeer modules
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


# Invoer

plt.close('all')

path = r'D:\Documents\3280.10 WTI Verschilanalyse\Uitintegreren\Windsnelheden\\'


# Definieer functie om kansen weg te schrijven naar Hydra NL format

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
        if (i%5 == 0 and i >= 4*5) or i == 0:
#            print(i, (i%5 == 0 and i >= 4) or i == 0)
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
    headerline = 'u (m/s) \ r,'
    headerline += ''.join('{};'.format(r) for r in range(30, 361, 30))[:-1]
    f.write(headerline)
    f.write('\n')
    
    # Write probabilities
    for i, d in enumerate(data):
        # Only write with a 0.1 interval, and the last line
        
        if (i%5 == 0.0 and i >= 4*5) or i == 0:
            ls = '  {:<.2f};{:<.3e};{:<.3e};{:<.3e};{:<.3e};{:<.3e};{:<.3e};{:<.3e};{:<.3e};{:<.3e};{:<.3e}{:<.3e};{:<.3e}'.format(*d)
            # Add line to file
            f.write(ls)
            # Add line break if not last line
            if i != len(data) - 1:
                f.write('\n')
    
    f.close()


# Lees input excel bestanden in en haal hieruit de stationsnamen
infiles = os.listdir(path+'Toeleveringen\FTP')
infiles = [naam for naam in infiles if '.xlsx' in naam]
station_namen = [naam.replace('Wind speed ', '').replace('.xlsx', '') for naam in infiles]
station_namen = [naam[:naam.find('-')-1] for naam in station_namen]

for sNaam, infile in zip(station_namen, infiles):
   
#    if sNaam != 'Vlissingen':
#        continue
    
    print('Analyse voor {}'.format(sNaam))


    # Lees windrichtingskansen uit en schrijf ze weg
    richtingskansen = pd.read_excel(path+'Toeleveringen\FTP\\'+infile, sheetname = 'Wind directions', skiprows = 3, index_col = 0, header = None, parse_cols = [2, 3])
    f = open(path + 'HydraNL\Richtingkansen_{}_2017.txt'.format(sNaam), 'w')
    f.write('*\n* Richtingkansen windsnelheid {}.\n* Overgenomen uit {}.\n*\n'.format(sNaam, infile))
    for i in richtingskansen.iterrows():
        f.write('{:03d} {:.9f}\n'.format(i[0], i[1].values[0]))
    f.close()
    Pr = richtingskansen.iloc[:].values.flatten()
    # Lees de overschrijdingsfrequenties uit de excel sheet
    ovkansenWind = pd.read_excel(path+'Toeleveringen\FTP\\'+infile, sheetname = 'Wind distribution data', skiprows = 7, index_col = 0, header = None)
    ovkansenWind.columns = np.roll(range(30, 361, 30), 1).astype(str).tolist()
    
    # lees onzekerheidsgroottes uit
    mu, sigma = pd.read_excel(path+'Toeleveringen\FTP\\'+infile, sheetname = 'Statistical uncertainty', parse_cols = [1, 2], skiprows = 7, header = None).values.flatten()
        
    # Grid voor x-waarden (zonder onzekerheid)
    xMin  = 0.
    xSt   = 0.1
    xMax  = 42.
    xGrid = np.arange(xMin, xMax+0.001, xSt)

    # Grid voor v-waarden (met onzekerheid)
    vGrid = np.copy(xGrid)    
    
    ySt   = sigma / 100.
    yMin  = mu - 5 * sigma
    yMax  = mu + 5 * sigma
    yGrid = np.arange(yMin, yMax+0.001, ySt)

    # Initialisatie:
    xPov = np.zeros((len(xGrid), 12))
    vPov = np.zeros_like(xPov)
    
    rfig = [360]+list(range(30,331,30))
    
    for r in range(12):
        
#        if r != 9:
#            continue
        # Inlezen overschrijdingskansen wind bij richting r
        xInv = ovkansenWind.index.values
        xPovInv = ovkansenWind.iloc[:,r].values
    
        # Methode 1:
    
        # Bereken klassekansen
#        f = interp1d(xInv, np.log(xPovInv), kind = 'linear', fill_value = 'extrapolate')
#        xPov[:, r] = np.exp(f(xGrid))
#        
#        klassekansen = xPov[:,r] - np.roll(xPov[:,r], -1)
#        klassekansen[-1] = 0
#    
#        for i in range(np.shape(vPov)[0]):
#            PovHulp = 1 - st.norm.cdf(vGrid[i] / xGrid, loc = mu, scale = sigma)    
#            vPov[i,r] = np.sum(PovHulp * klassekansen)
    
        # Methode 2:
        # Omdat mu en sigma constant zijn kan dit.
        # f(y)
        klassekansen = st.norm.pdf(yGrid, loc = mu, scale = sigma) * ySt

        # 1 - Fx
        oFx = interp1d(xInv, np.log(xPovInv), kind = 'linear', fill_value = 'extrapolate')
        xPov[:, r] = np.exp(oFx(xGrid))
#        for i in range(len(vGrid)):
        # De ...[:, None] notatie is wat criptisch, maar op die manier wordt een
        # array over de andere dimensie gedeeld of vermenigvuldigd.
        PovHulp = np.exp(oFx(vGrid/yGrid[:, None]))
        vPov[:,r] = np.sum(PovHulp * klassekansen[:, None], axis = 0)           
 
        #==============================================================================
        # Creeer figuren
        #==============================================================================
    
        if sNaam == 'Vlissingen':
            
            checkzon = pd.read_csv(path+'Toeleveringen\Voorbeelden\Ovkanswind_Vlissingen_2017.txt', skiprows = 8, header = None, delim_whitespace=True, index_col = 0)    
            checkmet = pd.read_csv(path+'Toeleveringen\Voorbeelden\Ovkanswind_Vlissingen_2017_metOnzHeid.txt', skiprows = 8, header = None, delim_whitespace=True, index_col = 0)    
            
            # Eerst voor een 12 uurs overschrijdingskans
            fig, ax = plt.subplots(figsize = (14/2.54, 12/2.54))
            
            ax.grid(which = 'both', axis = 'both')
            ax.set_yscale('log')
    #        ax.set_xlim(start_waterstanden[sNaam], 8)
            ax.plot(xGrid, xPov[:,r], 'b-', lw = 1.5, label = 'Zonder onzekerheid')
            ax.plot(vGrid, vPov[:,r], 'r-', lw = 1.5, label = 'Met onzekerheid')
            
            c = r - 1
            if r == 0:
                c = 11
            
            ax.plot(checkzon.index.values, checkzon.iloc[:,c].values, 'kx', lw = 1.5, label = 'Zonder onzekerheid check')
            ax.plot(checkmet.index.values, checkmet.iloc[:,c].values, 'rx', lw = 1.5, label = 'Met onzekerheid check')
    
            
            ax.set_ylim(ax.get_ylim()[0], 2)
            
            ax.set_title('Conditionele overschrijdingskans (per 12 uur) windsnelheid {} r = {}'.format(sNaam, rfig[r]))
            ax.set_xlabel('Windsnelheid [m/s]')
            ax.set_ylabel('Overschrijdingskans [-]')    
            
            lg = ax.legend(loc = 'best')
            plotting.adjust_lg(lg)
            
            plt.tight_layout()
        
            fig.savefig(path+'Figuren\Vergelijk_met_Karolina\{}_{}_12uur.png'.format(sNaam, rfig[r]), dpi = 150)

            checkzon = pd.read_csv(path+'Toeleveringen\Voorbeelden\Ovkanswind_Vlissingen_2017.txt', skiprows = 8, header = None, delim_whitespace=True, index_col = 0)    
            checkmet = pd.read_csv(path+'Toeleveringen\Voorbeelden\Ovkanswind_Vlissingen_2017_metOnzHeid.txt', skiprows = 8, header = None, delim_whitespace=True, index_col = 0)    
            
#         Eerst voor een 12 uurs overschrijdingskans
        fig, ax = plt.subplots(figsize = (14/2.54, 12/2.54))
        
        ax.grid(which = 'both', axis = 'both')
        ax.set_yscale('log')
#        ax.set_xlim(start_waterstanden[sNaam], 8)
        ax.plot(xGrid, xPov[:,r], 'b-', lw = 1.5, label = 'Zonder onzekerheid')
        ax.plot(vGrid, vPov[:,r], 'r-', lw = 1.5, label = 'Met onzekerheid')
               
        ax.set_ylim(ax.get_ylim()[0], 2)
        ax.set_xlim(0, 42)
        
        ax.set_title('Conditionele overschrijdingskans (per 12 uur) windsnelheid {} r = {}'.format(sNaam, rfig[r]))
        ax.set_xlabel('Windsnelheid [m/s]')
        ax.set_ylabel('Overschrijdingskans [-]')    
        
        lg = ax.legend(loc = 'best')
        plotting.adjust_lg(lg)
        
        plt.tight_layout()
    
        fig.savefig(path+'Figuren\{}_{}_12uur.png'.format(sNaam, rfig[r]), dpi = 150)
        plt.close('all')
            
#         Nu voor een jaarlijkse overschrijdingskans (overschrijdingsfrequentie)
#         Omrekenen van 12 uur naar jaar:
#         Fjaar(M > m , r) =  F12uur(M > m | r) * N * P(r)
#         Hierin is N het aantal 12-uursblokken in een half jaar (180 dagen)
        
        fig, ax = plt.subplots(figsize = (14/2.54, 12/2.54))
        
        ax.grid(which = 'both', axis = 'both')
        ax.set_yscale('log')
        ax.set_xlim(0, 42)
        ax.plot(xGrid, xPov[:,r] * 360 * Pr[r], 'b-', lw = 1.5, label = 'Zonder onzekerheid')
        ax.plot(vGrid, vPov[:,r] * 360 * Pr[r], 'r-', lw = 1.5, label = 'Met onzekerheid')
        
        ax.set_title('Conditionele overschrijdingskans (per jaar) windsnelheid {} r = {}'.format(sNaam, rfig[r]))
        ax.set_xlabel('Windsnelheid [m/s]')
        ax.set_ylabel('Overschrijdingskans [-]')    
        
        lg = ax.legend(loc = 'best')
        plotting.adjust_lg(lg)
        
        plt.tight_layout()
    
        fig.savefig(path+'Figuren\{}_{}_jaar.png'.format(sNaam, rfig[r]), dpi = 150)
        plt.close('all')
#        
            
    #==========================================================================
    # Schrijf naar Hydra-NL formaat
    #==========================================================================
    
    # Eerst zonder onzekerheid:
    # In vPov komt 360 graden eerst voor. 'rol' de array daarom zodanig dat 30 graden vooraan staat
#    data = np.c_[xGrid, np.roll(xPov, -1, axis = 1)]
#    
#    # Header dictionary
#    headerpath = path+r'HydraNL\HydraNLheader.txt'
#    
#    headerinp = dict(STATION = sNaam,
#                     METZONDER = 'Zonder')
#    
#    # Roep schrijffunctie aan
#    write_to_hydra_format(data, path+'HydraNL\Ovkanswind_{}_2017.txt'.format(sNaam), headerpath, headerinp)
#    write_to_csv(data, path+'CSV\Ovkanswind_{}_2017.csv'.format(sNaam))
#    
#    # Met zonder onzekerheid:
#    data = np.c_[vGrid, np.roll(vPov, -1, axis = 1)]
#    headerinp['METZONDER'] = 'Met'
#    
#    write_to_hydra_format(data, path+'HydraNL\Ovkanswind_{}_2017_metOnzHeid.txt'.format(sNaam), headerpath, headerinp)
#    write_to_csv(data, path+'CSV\Ovkanswind_{}_2017_metOnzHeid.csv'.format(sNaam))
#   
#        fig, ax = plt.subplots(figsize = (14/2.54, 10/2.54))
#
#        plotting.set_rcparams()
#        plotting.DDC_axes(ax, direction = 'vertical')        
#        ax.plot(xGrid, xPov[:,r], 'b-', lw = 1.5, label = 'Zonder onzekerheid')
#        ax.plot(vGrid, vPov[:,r], 'r-', lw = 1.5, label = 'Met onzekerheid')
#        
#        ax.fill_betweenx(xPov[:,r], xGrid * (mu + 1.96 * sigma), xGrid * (mu - 1.96 * sigma), color = 'lightgrey', label = '95% betrouwbaarheidsinterval')
#
#
#        ax.set_ylim(1e-7, 2)
#        ax.set_xlim(0, 45)
#        
#        ax.set_title('Conditionele overschrijdingskans (per 12 uur) windsnelheid {} r = {}'.format(sNaam, rfig[r]))
#        ax.set_xlabel('Windsnelheid [m/s]')
#        ax.set_ylabel('Overschrijdingskans [-]')
#        
#        lg = ax.legend(loc = 'best')
#        plotting.adjust_lg(lg)
#        
#        plt.tight_layout()
#    
#        fig.savefig(path+'Figuren\memo_vlissingen_270.png', dpi = 220)
#        plt.close('all')
    