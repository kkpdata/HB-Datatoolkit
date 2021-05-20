function GenerateSettingsMatFiles_BER_04(IDsFile, matFileDir)

WaterSystem = 4;

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
    polyX_Afvoer = [1.24e5 2.00e5 2.00e5 1.20e5 1.21e5 1.22e5 1.24e5 1.24e5];
    polyY_Afvoer = [4.12e5 3.00e5 5.00e5 4.40e5 4.27e5 4.24e5 4.16e5 4.12e5];
    
    inPoly_Afvoer = inpolygon(Xs, Ys, polyX_Afvoer, polyY_Afvoer);
    
    polyX_Kering = [9.75e4 9.93e4 9.9e4 9.79e4 9.79e4 8.32e4 8.20e4 5e4 5e4 9.75e4];
    polyY_Kering = [4.40e5 4.366e5 4.357e5 4.354e5 4.30e5 4.312e5 4.307e5 4.307e5 4.70e5 4.40e5];
    
    inPoly_Kering = inpolygon(Xs, Ys, polyX_Kering, polyY_Kering);
    
    polyX_Berging = [8.20e4 5e4 5e4 1.162e5 1.1605e5 1.1605e5  1.12e5 1.113e5 1.1e5 1.027e5 1.025e5 1.028e5 1.028e5 1.024e5 8.22e4 8.22e4 8.17e4 8.04e4 7.99e4 7.99e4 7.9e4 7.93e4 8.20e4];
    polyY_Berging = [4.307e5 4.307e5 4e5 4e5 4.1345e5 4.135e5 4.17e5 4.22e5 4.22e5 4.193e5 4.193e5 4.184e5 4.177e5 4.177e5 4.253e5 4.254e5 4.254e5 4.25e5 4.245e5 4.243e5 4.244e5 4.249e5 4.307e5];
    
    inPoly_Berging = inpolygon(Xs, Ys, polyX_Berging, polyY_Berging);
    
    
    AreaVector                  = 4*ones(numel(IDs),1);
    AreaVector(inPoly_Afvoer)   = 1;
    AreaVector(inPoly_Kering)   = 2;
    AreaVector(inPoly_Berging)  = 3;
    
    %% Settings 1 = Afvoer, 2 = Kering, 3 = Berging, 4 = Overgangsgebied
    timeIntegration.MHW     = [3 3 3 3];
    timeIntegration.QVar    = [3 3 3 3];
    timeIntegration.Waves   = [3 3 3 3];
    timeIntegration.HBN     = [3 3 3 3];
    timeIntegration.KW      = [3 3 3 3];
    timeIntegration.KW_FBC  = [1 1 1 1];
    
    probMethod.MHW      = [12 12 12 12];
    probMethod.QVar     = [4  4  4 4];
    probMethod.Waves    = [12 12 12 12];
    probMethod.HBN      = [12 12 12 12];
    
    FORMstart.MHW       = [4 4 4 4];
    FORMstart.QVar      = [4 4 4 4];
    FORMstart.Waves     = [4 4 4 4];
    FORMstart.HBN       = [4 4 4 4];
    
    DSminIter.MHW       = [10000 10000 10000 10000];
    DSminIter.QVar      = [3000  3000  3000 3000];
    DSminIter.Waves     = [10000 10000 10000 10000];
    DSminIter.HBN       = [10000 10000 10000 10000];
    DSminIter.KW        = [10000 10000 10000 10000];
    
    DSmaxIter.MHW       = [40000 40000 40000 40000];
    DSmaxIter.QVar      = [20000 20000 20000 20000];
    DSmaxIter.Waves     = [40000 40000 40000 40000];
    DSmaxIter.HBN       = [40000 40000 40000 40000];
    DSmaxIter.KW        = [20000 20000 20000 20000];
    
    DesTabMinMax.Min_MHW      = [2.0 2.0 2.0 2.0];
    DesTabMinMax.Min_QVar     = [10 10 10 10];
    DesTabMinMax.Min_Waves    = [1.0 1.0 1.0 1.0];
    DesTabMinMax.Min_HBN      = [2.0 2.0 2.0 2.0];
    
    DesTabMinMax.Max_MHW      = [4.0 4.0 4.0 4.0];
    DesTabMinMax.Max_QVar     = [50 50 50 50];
    DesTabMinMax.Max_Waves    = [4.0 4.0 4.0 4.0];
    DesTabMinMax.Max_HBN      = [4.0 4.0 4.0 4.0];
    
    GenerateSettingsMatFile(IDs, AreaVector, probMethod, FORMstart, DSminIter, DSmaxIter, timeIntegration, DesTabMinMax, 'matFileDir', matFileDir, 'matFileName', matFileName)
end
end