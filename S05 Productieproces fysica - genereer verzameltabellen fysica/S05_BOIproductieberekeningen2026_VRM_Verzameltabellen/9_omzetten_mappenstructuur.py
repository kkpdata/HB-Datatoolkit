"""
Script Header

Dit script zet de uitvoer van script 1 en 8c om in de datastructuur zoals nodig voor het maken van de database voor Hydra.

Functionaliteit:
- Zet de uitvoer van script 1 en 8c om naar het juiste formaat voor de Hydra-database.
- Voor VRM moeten voor alle trajecten de waterstanden meegegeven worden.
- Voor alle trajecten behalve de 'hoge gronden veluwerandmeren' moeten ook de golven worden meegegeven.
"""

import os
import zipfile

# set workingdirectory
print(f"run: {os.path.abspath(__file__)}")
os.chdir(os.path.dirname(os.path.abspath(__file__)))

# Definieer paden invoer
gebied = "vrm"

backup = "_backup" # als niet backup dan ""
# trajectnamen, en de naam zoals in de structuur voor de database
trajecten = {"11-3":"011-03",
             "205":"vk2050",
             "227":"vk2270",
             "45-3":"045-03",
             "8-5":"008-05",
             "8-6":"008-06",
             "8-7":"008-07",
             "hoge gronden Veluwerandmeren":"hg",
             "extra locaties Veluwerandmeren":"extra",}

golf_data = {"Dir":"Wave direction",
             "Hs": "Hs",
             "Tm": "Tm-1,0",
             "Tp": "Tp",}
waterlevels = "Waterlevels_Database_grad0.1_bakje2_Filtered" 

# locaties
results_location = rf"..\NWM\database_figuren_meren\DHYDRO_{gebied}_results\Normtrajectdata"
uitvoer_location = rf"..\NWM\database_figuren_meren\Meren_{gebied.upper()}"
os.makedirs(uitvoer_location, exist_ok=True)

results_mappen = os.listdir(results_location)

# loop data in resultslocation
for map_ in results_mappen:
    traject = trajecten[map_]
    uitvoer_map = os.path.join(uitvoer_location,f"meren_{gebied.upper()}_{traject}")
    print("data uit ", map_, "wordt weggeschreven naar:\n\t", uitvoer_map)	
    os.makedirs(uitvoer_map, exist_ok=True)
    results = os.listdir(os.path.join(results_location,map_))
    # zip waterstanden
    waterstand_file = f"{waterlevels}_{map_}.csv"
    if waterstand_file in results:
        # print(f"Zip en verplaats bestand {waterstand_file} naar {uitvoer_map}")
        src = os.path.join(results_location,map_,waterstand_file)
        dst = os.path.join(uitvoer_map,"h.zip")

        with zipfile.ZipFile(dst, 'w') as zipf:
            zipf.write(src, arcname=waterstand_file)
    elif f"{waterlevels[:-24]}_{map_}.csv" in results:
        print(f"\t Ongefilterde waterstanden voor {map_}")
        waterstand_file = f"{waterlevels[:-24]}_{map_}.csv" 
        src = os.path.join(results_location,map_,waterstand_file)
        dst = os.path.join(uitvoer_map,"h.zip")

        with zipfile.ZipFile(dst, 'w') as zipf:
            zipf.write(src, arcname=waterstand_file)
    else:
        print(f"Bestand {waterstand_file} niet gevonden in {map_}")
    
    # zip de golven
    for golf in golf_data.keys():
        # if (traject == "hg") or (traject=="extra"):
        #     continue
        # else:
        golf_file = f"Golfparameter_SWAN_{golf}_{map_}{backup}.csv"
        if golf_file in results:
            # print(f"Zip en verplaats bestand {golf_file} naar {uitvoer_map}")
            src = os.path.join(results_location,map_,golf_file)
            dst = os.path.join(uitvoer_map,golf_data[golf] + ".zip")

            with zipfile.ZipFile(dst, 'w') as zipf:
                zipf.write(src, arcname=golf_file)
        else:
            print(f"Bestand {golf_file} niet gevonden in {map_}")

    







