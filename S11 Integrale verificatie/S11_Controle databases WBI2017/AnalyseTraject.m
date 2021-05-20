function AnalyseTraject(traject, dbname)

clear DatRes SortRes;

DirLocations = '..\..\04_Work_15_12\Locaties\'; % '..\JW\Locations\';
DirResult = '..\..\04_Work_15_12\Excel\';   % '..\Excel\';
DirFinal = '..\..\04_Work_15_12\Analyse\';   %'..\Analyse\';

%%DirLocations = '..\JW\Locations\';
%%DirResult = '..\Excel\';
%%DirFinal = '..\Analyse\';
as_name = ['WS_', traject(1:1),'_aslocaties'];
if traject(1:1) == 'R'
    resfile = [DirFinal,'Results_Rijn.csv'];
    logfile = [DirFinal,'Messages_Rijn.log'];
else
    resfile = [DirFinal,'Results_Maas.csv'];
    logfile = [DirFinal,'Messages_Maas.log'];
end

DatRes=LeesLocaties([DirLocations,traject]);
DatRes=LeesResult(DirResult, 'WS', traject, DatRes);
DatRes=LeesResult(DirResult, 'Hs', traject, DatRes);  %%Hsig
DatRes=LeesResult(DirResult, 'TM', traject, DatRes);
DatRes=LeesResult(DirResult, 'HBN', traject, DatRes);
SortRes = Rearrange(DatRes);
SortRes=Connect2Axis([DirResult,'WS\'], as_name, SortRes);
SortRes=BerekenDecimeringsHoogte(SortRes);
SortRes=SetQuality( logfile, dbname, SortRes );

WriteResults( DirFinal, dbname, resfile, SortRes );