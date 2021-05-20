"""
Created on Wed May 15 13:09:00 2019

Maken van een batch bestand om meerdere Hydra-NL berekeningen te starten.

Maakt een batchbestand met daarin alle berekeningen die zijn aangemaakt maar nog niet gedraaid.

@author: daggenvoorde
"""

import os
WERKMAP = os.path.join('..', 'Interne_controles')
BATFILE = []
for dbnaam in os.listdir(WERKMAP):
    # if dbnaam in ['WBI2023_IJsseldelta_IJsselmeer_v00_terBeoordeling',
    #               'WBI2023_IJsseldelta_GeulVWas_v00_terBeoordeling',
    #               'WBI2023_Vechtdelta_Vogeleiland_v00_terBeoordeling']:
    #     continue
    hydra_locs = os.listdir(os.path.join(WERKMAP, dbnaam))
    for loc in hydra_locs:
        if (not os.path.isdir(os.path.join(WERKMAP, dbnaam,
                                           loc))) | (loc == '_Shapes'):
            continue
        if not os.path.exists(os.path.join(WERKMAP, dbnaam,
                                           f'Copy_{dbnaam}.sqlite')):
            continue
        if not os.path.exists(os.path.join(WERKMAP, dbnaam,
                                           loc, 'Berekeningen')):
            continue
        berekeningen = os.listdir(os.path.join(WERKMAP, dbnaam,
                                               loc, 'Berekeningen'))
        for ber in berekeningen:
            if not ber.startswith('HS'):
                continue
            #kijk of het uitvoerbestand bestaat, zo ja dan deze berekening niet opnieuw starten
            if os.path.exists(os.path.join(WERKMAP, dbnaam, loc,
                                           'Berekeningen', ber,
                                           'uitvoer.html')):
                continue

            invoerpad = os.path.join(WERKMAP, dbnaam, loc, 'Berekeningen',
                                     ber, 'invoer.hyd')
            invoerpad = os.path.abspath(invoerpad)
            commando = 'call jobs\\run_basis_lokaal.bat "{}"'.format(invoerpad)

            BATFILE.append(commando)

print('Aantal sommen dat gestart gaat worden is : {}'.format(len(BATFILE)))

# schrijf batchbestand
with open(os.path.join('..', 'Start_sommen_HS.bat'), 'w') as f:
    for i, line in enumerate(BATFILE):
        f.writelines(line + '\n')
