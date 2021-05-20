function GetConnection(traject, dbname)

clear DatRes SortRes;

DirLocations = '..\..\04_Work_15_12\Locaties\'; % '..\JW\Locations\';
DirResult = '..\..\04_Work_15_12\Excel\';   % '..\Excel\';
DirFinal = '..\..\04_Work_15_12\Analyse\';   %'..\Analyse\';
as_name = ['WS_', traject(1:1),'_aslocaties'];
if traject(1:1) == 'R'
    resfile = [DirFinal,'Locations_Rijn.csv'];
else
    resfile = [DirFinal,'Locations_Maas.csv'];
end

DatRes=LeesLocaties([DirLocations,traject]);
DatRes=LeesResult(DirResult, 'WS', traject, DatRes);
DatRes=Connect2Axis([DirResult,'WS\'], as_name, DatRes);

WriteAxisConnection( dbname, resfile, DatRes );