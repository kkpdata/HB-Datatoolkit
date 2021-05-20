function GenerateSettingsMatFiles_BOR(IDsFile, matFileDir)

WaterSystem = [1 2 18];

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
    polyX_VeeWap = [2.031e5 2.00e5 2.018e5 2.021e5 2.05e5 2.037e5 2.031e5];
    polyY_VeeWap = [4.948e5 4.86e5 4.869e5 4.875e5 4.92e5 4.9455e5 4.948e5];
    
    inPoly = inpolygon(Xs, Ys, polyX_VeeWap, polyY_VeeWap);
    
    
    AreaVector          = ones(numel(IDs),1);
    AreaVector(inPoly)  = 2;
    
    %% Settings 1: Rest of area, 2: inside Veessen-Wapenveld
    timeIntegration.MHW     = [1 1];
    timeIntegration.QVar    = [1 1];
    timeIntegration.Waves   = [1 1];
    timeIntegration.HBN     = [1 1];
    timeIntegration.KW      = [1 1];
    timeIntegration.KW_FBC  = [1 1];
    
    probMethod.MHW      = [12 12];
    probMethod.QVar     = [4 4];
    probMethod.Waves    = [12 12];
    probMethod.HBN      = [12 12];
    
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
end