function CreateProfile(traject, dbname)

DirLocations = '..\..\04_Work_15_12\Locaties\';   %'..\JW\Locations\';
DirResult = '..\..\04_Work_15_12\Excel\';
DirDijknormaal = '..\..\04_Work_15_12\Profielbestanden\dijknormalen\BenedenRijn\';
DirPLB = '..\..\04_Work_15_12\Profielbestanden\';

DatRes=LeesLocaties([DirLocations,traject]);
DatRes=LeesResult(DirResult, 'WS', traject, DatRes);
GeneratePLB(DirDijknormaal, DirPLB,dbname,DatRes);

end
