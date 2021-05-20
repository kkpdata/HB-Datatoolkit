function GenerateSettingsMatFiles_IJVD_Vechtdelta(IDsFile, matFileDir)

WaterSystem = 6;
matFileName = '06_settings.mat';

NNUM = xlsread(IDsFile);
filter = NNUM(:,1) == WaterSystem;

IDs = NNUM(filter,2);
Xs = NNUM(filter,3);
Ys = NNUM(filter,4);

idx = isort(IDs);
IDs = IDs(idx);
Xs = Xs(idx);
Ys = Ys(idx);

%% Veessen Wapenveld polygons
polyX_ZwarteWater = [1.988e5 1.992e5 2.06e5 2.06e5 2.045e5 1.98e5 1.988e5];
polyY_ZwarteWater = [5.16e5 5.18e5 5.18e5 5.07e5 5.06e5 4.95e5 5.16e5];

inPoly = inpolygon(Xs, Ys, polyX_ZwarteWater, polyY_ZwarteWater);


AreaVector          = ones(numel(IDs),1);
AreaVector(inPoly)  = 2;

%% Settings 1: Zwarte Meer & Vecht, 2: Zwarte Water
timeIntegration.MHW     = [1 1];
timeIntegration.QVar    = [1 1];
timeIntegration.Waves   = [1 1];
timeIntegration.HBN     = [1 1];
timeIntegration.KW      = [1 1];
timeIntegration.KW_FBC  = [1 1];

probMethod.MHW      = [11 12];
probMethod.QVar     = [4 4];
probMethod.Waves    = [11 12];
probMethod.HBN      = [11 12];

FORMstart.MHW       = [4 4];
FORMstart.QVar      = [4 4];
FORMstart.Waves     = [4 4];
FORMstart.HBN       = [4 4];

DSminIter.MHW       = [10000 10000];
DSminIter.QVar      = [3000 3000];
DSminIter.Waves     = [10000 10000];
DSminIter.HBN       = [10000 10000];
DSminIter.KW        = [10000 10000];

DSmaxIter.MHW       = [40000 40000];
DSmaxIter.QVar      = [20000 20000];
DSmaxIter.Waves     = [40000 40000];
DSmaxIter.HBN       = [40000 40000];
DSmaxIter.KW        = [20000 20000];

DesTabMinMax.Min_MHW      = [2.0 2.0];
DesTabMinMax.Min_QVar     = [10 10];
DesTabMinMax.Min_Waves    = [1.0 1.0];
DesTabMinMax.Min_HBN      = [2.0 2.0];

DesTabMinMax.Max_MHW      = [4.0 4.0];
DesTabMinMax.Max_QVar     = [50 50];
DesTabMinMax.Max_Waves    = [4.0 4.0];
DesTabMinMax.Max_HBN      = [4.0 4.0];


%% generate
GenerateSettingsMatFile(IDs, AreaVector, probMethod, FORMstart, DSminIter, DSmaxIter, timeIntegration, DesTabMinMax, 'matFileDir', matFileDir, 'matFileName', matFileName)
end