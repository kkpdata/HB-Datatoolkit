function GenerateSettingsMatFiles_Meren(IDsFile, matFileDir)

WaterSystem = [7 8];

NNUM = xlsread(IDsFile);


for iWaterSystem = 1:numel(WaterSystem)
    
    if WaterSystem(iWaterSystem) < 10
        matFileName = ['0' num2str(WaterSystem(iWaterSystem)) '_settings.mat'];
    else
        matFileName = [num2str(WaterSystem(iWaterSystem)) '_settings.mat'];
    end
    filter = NNUM(:,1) == WaterSystem(iWaterSystem);
    
    IDs = NNUM(filter,2);
    Xs = NNUM(filter,3);
    Ys = NNUM(filter,4);
    
    idx = isort(IDs);
    IDs = IDs(idx);
    Xs = Xs(idx);
    Ys = Ys(idx);
    
    %% Veessen Wapenveld polygons
    polyX_Meerpeil1 = [1.48e5 1.55e5 1.60e5 1.60e5 1.56e5 1.35e5 1.30e5 1.35e5 1.48e5];
    polyY_Meerpeil1 = [5.22e5 5.28e5 5.40e5 5.42e5 5.47e5 5.50e5 5.48e5 5.25e5 5.22e5];
    
    inPoly_Meerpeil1 = inpolygon(Xs, Ys, polyX_Meerpeil1, polyY_Meerpeil1);
    
    polyX_Meerpeil2 = [1.41e5 1.41e5 1.44e5 1.44e5 1.38e5 1.30e5 1.20e5 1.30e5 1.41e5];
    polyY_Meerpeil2 = [5.17e5 5.14e5 4.94e5 4.90e5 4.92e5 4.88e5 5.10e5 5.25e5 5.17e5];
    
    inPoly_Meerpeil2 = inpolygon(Xs, Ys, polyX_Meerpeil2, polyY_Meerpeil2);
    
    
    AreaVector                                      = ones(numel(IDs),1);
    AreaVector(inPoly_Meerpeil1 | inPoly_Meerpeil2) = 2;

    
    %% Settings 1 = WindDom, 2 = MeerpeilDom
    timeIntegration.MHW     = [3 1];
    timeIntegration.QVar    = [1 1];
    timeIntegration.Waves   = [1 1];
    timeIntegration.HBN     = [1 3];
    timeIntegration.KW      = [1 3];
    timeIntegration.KW_FBC  = [1 1];
    
    probMethod.MHW      = [1 11];
    probMethod.QVar     = [4 4];
    probMethod.Waves    = [11 11];
    probMethod.HBN      = [11 1];
    
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