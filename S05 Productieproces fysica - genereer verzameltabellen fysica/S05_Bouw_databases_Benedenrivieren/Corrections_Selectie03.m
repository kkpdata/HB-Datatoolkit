trajectname = 'Selectie03_corr';
location_table = ['..\testdata\OeverLoc_tabel', trajectname, '.csv'];
adminfile = ['..\testdata\workspace_', trajectname, '.mat'];

load ..\testdata\workspace_Selectie03.mat;
oeverStat(260).ind_as = 1708;    %NW_60m_L_VB9_5
oeverStat(260).backstation_id=11225;
oeverStat(261).ind_as = 1708;    %NW_60m_L_VB9_4
oeverStat(261).backstation_id=11225;
oeverStat(329).ind_as = 1177;    %NM_80m_L_17_220
oeverStat(329).backstation_id=11754;
oeverStat(328).ind_as = 1177;    %NM_80m_L_17_221
oeverStat(328).backstation_id=11754;
oeverStat(327).ind_as = 1177;    %NM_80m_L_17_222
oeverStat(327).backstation_id=11754;
oeverStat(325).ind_as = 1177;    %NM_80m_L_17_223
oeverStat(325).backstation_id=11754;
oeverStat(324).ind_as = 1177;    %NM_80m_L_17_224
oeverStat(324).backstation_id=11754;
oeverStat(322).ind_as = 1177;    %NM_80m_L_17_225
oeverStat(322).backstation_id=11754;
oeverStat(319).ind_as = 1177;    %NM_80m_L_17_226
oeverStat(319).backstation_id=11754;
oeverStat(86).ind_as = 1816;    %OM_60m_L_20_522
oeverStat(86).backstation_id=12786;
oeverStat(87).ind_as = 1816;    %OM_60m_L_20_523
oeverStat(87).backstation_id=12786;
oeverStat(88).ind_as = 1816;    %OM_60m_L_20_524
oeverStat(88).backstation_id=12786;
oeverStat(89).ind_as = 1816;    %OM_60m_L_20_525
oeverStat(89).backstation_id=12786;

WriteLocationsInfo(location_table, n_oever, oeverStat, asStat);

save(adminfile, 'n_as', 'asStat', 'n_oever', 'oeverStat');
