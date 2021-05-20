# -*- coding: utf-8 -*-
"""
Created on  : Tue Jul 19 16:58:30 2016
Author      : Guus Rongen
Project     : PR3280.20.03
Description : Script uitintegreren onzekerheid van de piekafvoer in de basisduur (B = 30 dagen),
              als onzekerheid normaal is verdeeld (additief model). In dit script is het MATLAB
              script van Chris Geerse (PR3216.10, november 2015) omgezet naar python

"""

# Import modules
import os
import pandas as pd
import numpy as np
from scipy.interpolate import interp1d
import scipy.stats as st
import matplotlib.pyplot as plt
from myfuncs import stats

# Zet wat plotstijl parameters
plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['grid.linestyle'] = '-'
plt.rcParams['axes.linewidth'] = 0.5
plt.rcParams['axes.labelsize'] = 'medium'
plt.rcParams['grid.alpha'] = 0.15
plt.rcParams['legend.handletextpad'] = 0.4
plt.rcParams['legend.fontsize'] = 8
plt.rcParams['legend.labelspacing'] = 0.2
plt.rcParams['font.size'] = 8
plt.rcParams['font.sans-serif'] = 'Verdana'

# Verander werkmap
os.chdir(r'd:\Documents\PR3280.20.09 Maasstatistiek')

# Bepaald pad waar de originele bestanden staan
origineel_pad = r'Toeleveringen\\Afvoer\\'

# lees data in
#-----------------------------------------------------
data = pd.read_csv(r'Toeleveringen\TableFrequencyCurveMeuse.tab', skiprows = 16, skipfooter = 64, header = None, delimiter=r"\s+", usecols = [0, 2, 3])
data.columns = ['terugkeertijd', 'afvoer', 'sigma']
locatie = 'Borgharen'
data['overschrijdingskans'] = 1./data.terugkeertijd / 6

## Vertaal naar afvoer en onzekerheid om de rest van het script consistent te
# houden
#------------------------------------------------------------------------------
afvoer = data[['afvoer', 'overschrijdingskans']]
afvoer = afvoer.set_index('afvoer')

onzekerheid = data[['afvoer', 'sigma']]
onzekerheid['mu'] = 0

## bereid het uitintegreren voor
#-----------------------------------------------------
# Grid waarvoor de verwachtingswaarde wordt bepaald
xmin = 1002
xstap = 2
vmax = 8000 # 10 is voor de preciezie in de staart; (is dit eigenlijk wel nodig hier?)
xmax = 6000 # Uiteindelijk nemen we 8 m als maximum.
xgrid = np.arange(xmin, vmax+xstap/10, xstap)

# Bepaal de eindindex
end = int((xmax - vmax) / xstap)

# Hetzelfde grid wordt voor de uitgeïntegreerde als niet uitgeïntegreerde
# statistiek gebruikt.
zonder_onzekerheid = pd.DataFrame(index = xgrid[:end], columns = ['overschrijdingskans'])
met_onzekerheid = pd.DataFrame(index = xgrid[:end], columns = ['overschrijdingskans'])

## Interpoleer onzekerheid (lineair over waterstandsrichting) op het grid
# Eerst de gemiddelden
fMu = interp1d(onzekerheid.afvoer, onzekerheid.mu, kind = 'linear', fill_value = 'extrapolate')
xMu = fMu(xgrid)
# Dan de standaardafwijking
fSig = interp1d(onzekerheid.afvoer, onzekerheid.sigma, kind = 'linear', fill_value = 'extrapolate')
xSig = fSig(xgrid)

# Interpoleer de overschrijdingskansen
fPov = interp1d(afvoer.index, np.log(afvoer.overschrijdingskans), fill_value = 'extrapolate')
xPov = np.exp(fPov(xgrid))

# Bereken het verschil tussen de overschrijdingskansen, de klassekansen
klassekansen = xPov- np.roll(xPov, -1)
klassekansen[-1] = 0  # maak laatste klasse 0

"""
Bereken overschrijdingskans voor vGrid(i), incl. onzekerheid:
Waarom xgrid - vgrid?:
P(V > v) = P(M + Y > v)
         = integraal[dm f(m)P(m+Y > v | M = m)]
         = integraal[dm f(m)P(Y > v-m | M = m)]
         = integraal[dm f(m)[1-P(Y < v-m | M = m)]]
         = integraal[dm f(m)[1-Fy|m (v -m)]]
Intuitieve uitleg: Voor elke waterstand wordt de kans op overschrijden berekend,
gegeven een bepaalde waterstand zonder onzekerheid. Per klassekans is dit een
bepaalde waterstand zonder onzekerheid. Vervolgens is dus v (met onzekerheid) - m (zonder) de
grootte van de onzekerheid, en de cumulatieve kans, de kans dat deze onderschreden wordt.
PovHulp[:, i] = 1 - st.norm.cdf(vGrid[i] - xGrid, loc = xMu, scale = xSig)   #vector van formaat mGrid
vPov[i, r] = np.sum(PovHulp[i, :] * klassekansen)                    # waarde van de integraal
"""
PovHulp = np.zeros((len(xgrid), len(xgrid)))
PovHulp = 1 - st.norm.cdf(xgrid - xgrid[:, None], loc = xMu[:, None], scale = xSig[:, None])   #vector van formaat xgrid
vPov = np.sum(PovHulp * klassekansen[:, None], axis = 0)                    # waarde van de integraal

# Voeg toe aan dictionaries, maar tot 8 meter: In de staarten wordt een
# fout gemaakt. 

# In sommige gevallen kan de overschrijdingskans met onzekerheden onder die
# zonder onzekerheden uitkomen. Corrigeer hier gelijk voor.

zonder_onzekerheid.loc[:, 'overschrijdingskans'] = xPov[:end]
met_onzekerheid.loc[:, 'overschrijdingskans'] = np.max([vPov[:end], xPov[:end]], axis = 0)

## Maak figuren ter controle
#-----------------------------------------------------     
fig, ax = plt.subplots(figsize = (16.5/2.54, 8/2.54))
ax.plot(zonder_onzekerheid.loc[:, 'overschrijdingskans'], xgrid[:end], 'b-', lw = 1.5, label = 'Zonder onzekerheid')
ax.plot(met_onzekerheid.loc[:, 'overschrijdingskans'], xgrid[:end], 'r-', lw = 1.5, label = 'Met onzekerheid')
ax.grid()
ax.set_xscale('log')
ax.set_xlim(afvoer.overschrijdingskans.max(), afvoer.overschrijdingskans.min())

ax.set_xlabel('Overschrijdingskans per basistijdsduur (30 dagen)')
ax.set_ylabel('Afvoer [m$^{\mathregular{3}}$/s]')
lg = ax.legend(loc = 'best')
lg.get_frame().set_lw(0.5)
plt.tight_layout()
fig.savefig(r'Opleveringen\\Statistiek\\Figuren\\Overschrijdingsfrequentielijn', dpi = 300)

# Maak beginwaardentabel
beginwaarden = pd.DataFrame(
    np.array([1.00, 0.995, 0.88, 0.76, 0.55, 0.264]),
    columns = ['overschrijdingskans'],
    index = np.array([0, 75, 200, 300, 500, 1000]).astype(int)
    )

## Schrijf naar Hydra-NL formaat
#--------------------------------------------
for kansen, onz in zip([met_onzekerheid, zonder_onzekerheid], [True, False]):
    # Header dictionary
    headertext = open(r'Werkzaamheden\HydraNLheader.txt', 'r').read()
    headertext = headertext.replace('METZONDER', 'Met' if onz else 'Zonder')
    
    # Open nieuw bestand
    hydrainvoer = open(r'Opleveringen\Statistiek\Ovkans_Borgharen_piekafvoer_2017{}_Weismandrempel.txt'.format('_metOnzHeid' if onz else ''), 'w')
    # Voeg header toe
    hydrainvoer.write(headertext)
    # Bepaal het schrijfformaat en stapgrootte
    formatstring = ''.join(['        {:<16.3e}']*1)
    
    # Voeg beginwaarden toe aan kansen
    kansen = pd.concat([beginwaarden, kansen])    
    
    # Voeg data toe
    # Ga tot len(kansen) - 6, want de maximale voorlaatste stap moet 7.94
    # meter zijn.
    for q, row in kansen.iterrows():
        if (q >= xmin) and not (q % 200 == 0):
            continue
        elif q == 6000:
            continue
        q = int(q)
        # Schrijf waterstand
        hydrainvoer.write('        {:<4d}'.format(q))
        # Schrijf kansen
        hydrainvoer.write(formatstring.format(row.overschrijdingskans))
        # Schrijf linebreak als het niet de laatste entry is
        hydrainvoer.write('\n')
    # Schrijf laatste rij
    hydrainvoer.write('        {:<4d}'.format(int(kansen.iloc[-1].name)))
    hydrainvoer.write(formatstring.format(*kansen.iloc[-1].values))
    
    # Sluit het bestand af
    hydrainvoer.close()


## Rapportagefiguur
#-----------------------------------------------------     
#plt.close('all')
fig, ax = plt.subplots(figsize = (16.5/2.54, 10.5/2.54))
ax.plot(zonder_onzekerheid.loc[:, 'overschrijdingskans'] * 6, xgrid[:end], 'b-', lw = 1.5, label = 'Zonder onzekerheid')
ax.plot(met_onzekerheid.loc[:, 'overschrijdingskans'] * 6, xgrid[:end], 'r-', lw = 1.5, label = 'Met onzekerheid')
#ax.fill_between()

from myfuncs import stats

ax.grid()
ax.set_xscale('log')
ax.set_xlim(afvoer.overschrijdingskans.max()*6, afvoer.overschrijdingskans.min()*6)

f, Q, jaren = stats.get_annual_maxima(where = 'Borgharen', mode = 'f', plotpos = (0, 1), return_years = True)
ax.plot(f, Q, 'k^', mew = 1, mfc = 'yellowgreen', label = 'Gemeten jaarlijkse maxima', zorder = 1)
for i in range(len(jaren)-3, len(jaren)):
    ax.text(f[i]/1.1, Q[i]-10, jaren[i], va = 'top', ha = 'left')

upper = onzekerheid.afvoer.values + 1.96 * onzekerheid.sigma.values
lower = onzekerheid.afvoer.values - 1.96 * onzekerheid.sigma.values
ax.fill_between(afvoer.overschrijdingskans*6, upper, lower, color = 'lightgrey', label = '95% betrouwbaarheidsinterval')


ax.set_xlabel('Overschrijdingsfrequentie per winterhalfjaar (180 dagen)')
ax.set_ylabel('Afvoer [m$^{\mathregular{3}}$/s]')
lg = ax.legend(loc = 'upper left')
lg.get_frame().set_lw(0.5)
plt.tight_layout()
ax.set_ylim(1000, 7000)
fig.savefig(r'Opleveringen\\Statistiek\\Figuren\\Overschrijdingsfrequentielijn_rapport', dpi = 300)

## Rapportfiguur vergelijking

fig, ax = plt.subplots(figsize = (16.5/2.54, 9/2.54))
for kansen, onz, color in zip([met_onzekerheid, zonder_onzekerheid], [True, False], ['r', 'b']):
    ax.plot(kansen.loc[:, 'overschrijdingskans'], xgrid[:end], color = color, ls ='-', lw = 1.5, label = '{} onzekerheid'.format('Met' if onz else 'Zonder'), alpha = 0.5)

ax.grid()
ax.set_xscale('log')
ax.set_xlim(afvoer.overschrijdingskans.max(), afvoer.overschrijdingskans.min())
ax.set_ylim(1000, 6500)


# Plot oude gegevens
# Verander werkmap

# Integreer uit
#-----------------------------------------------------
excelbestand = r'Toeleveringen\Discharge Borgharen.xlsx'

## Lees alle benodigde informatie uit het excelbestand
#-----------------------------------------------------
# Lees Weibull parameters uit
afvoer = pd.read_excel(excelbestand, sheetname = 'Discharge data', parse_cols = range(2), skiprows = 6)    
afvoer.columns = ['afvoer', 'overschrijdingskans']
afvoer = afvoer.set_index('afvoer')
# lees onzekerheidsgroottes uit
onzekerheid = pd.read_excel(excelbestand, sheetname = 'Statistical uncertainty', parse_cols = range(3), skiprows = 6)    
onzekerheid.columns = ['afvoer', 'mu', 'sigma']

vPov, xPov = stats.integreeg_uit(xgrid, afvoer.index, afvoer.overschrijdingskans, onzekerheid.mu[1:], onzekerheid.sigma[1:], returnp = True)

ax.plot(vPov, xgrid, 'r--', lw = 1.5, label = 'Oud, met onzekerheid', dashes = (4,3))
ax.plot(xPov, xgrid, 'b--', lw = 1.5, label = 'Oud, zonder onzekerheid', dashes = (4,3))

ax.set_xlabel('Overschrijdingskans per basistijdsduur (30 dagen)')
ax.set_ylabel('Afvoer [m$^{\mathregular{3}}$/s]')
lg = ax.legend(loc = 'best')
lg.get_frame().set_lw(0.5)
plt.tight_layout()

fig.savefig(r'Opleveringen\\Statistiek\\Figuren\\Overschrijdingsfrequentielijn_verschil', dpi = 300)

