function GenerateSettingsMatFiles_Veluwerandmeren(IDsFile, matFileDir)

WaterSystem = 20;

NNUM = xlsread('p:\1230087-hydraulische-belastingen\1. Hydraulische Randvoorwaarden\4. MakingSummaryTables\MetaInfo\MetaInfo_Veluwerandmeren.xlsx');


for iWaterSystem = 1:numel(WaterSystem)
    
    if WaterSystem(iWaterSystem) < 10
        matFileName = ['0' num2str(WaterSystem(iWaterSystem)) '_settings.mat'];
    else
        matFileName = [num2str(WaterSystem(iWaterSystem)) '_settings.mat'];
    end
   
    IDs = NNUM(:,1);
    Xs = NNUM(:,3);
    Ys = NNUM(:,4);
    
    idx = isort(IDs);
    IDs = IDs(idx);
    Xs = Xs(idx);
    Ys = Ys(idx);
    
    %% Veessen Wapenveld polygons
    polyX_Meerpeil1 = [1.71e5 1.69e5 1.6e5 1.6e5 1.71e5 1.71e5];
    polyY_Meerpeil1 = [4.855e5 4.875e5 4.875e5 4.70e5 4.70e5 4.855e5];
    
    inPoly_Meerpeil1 = inpolygon(Xs, Ys, polyX_Meerpeil1, polyY_Meerpeil1);
    
    
    AreaVector                   = ones(numel(IDs),1);
    AreaVector(inPoly_Meerpeil1) = 2;

    
    %% Settings 1 = WindDom, 2 = MeerpeilDom
    timeIntegration.MHW     = [3 1];
    timeIntegration.QVar    = [1 1];
    timeIntegration.Waves   = [1 1];
    timeIntegration.HBN     = [1 1];
    timeIntegration.KW      = [1 1];
    timeIntegration.KW_FBC  = [1 1];
    
    probMethod.MHW      = [11 11];
    probMethod.QVar     = [4 4];
    probMethod.Waves    = [11 11];
    probMethod.HBN      = [11 11];
    
    FORMstart.MHW       = [8 4];
    FORMstart.QVar      = [8 4];
    FORMstart.Waves     = [8 4];
    FORMstart.HBN       = [8 4];
    
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
end