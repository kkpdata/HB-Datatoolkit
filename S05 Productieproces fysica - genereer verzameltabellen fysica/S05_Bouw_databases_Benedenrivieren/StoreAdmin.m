function StoreAdmin(trajectname)
rgfFile = '..\testdata\grid-rmmriv40m_5-v5.rgf';
allStations = '..\testdata\uitvloc_hr2017_01.beno14_wti2017'   %%uitvloc_hr2017.beno14_wti2017';
asStations = '..\testdata\rivkmp.beno14';
asloc = '..\testdata\Aslocaties_01_selectie04.csv';
oeverloc = ['..\testdata\OeverLoc_', trajectname, '.csv'];
wetmax = '..\testdata\wRMM-Q01U00D360ZP116_riv_001_WETMAXVAL';
%%wavedata = '..\testdata\Golven\Res\U11D022S01.MAT';
wavelocations = '..\testdata\Golven\Uitvoerlocaties_RMM_tab_10.csv';  %%'..\testdata\Golven\Uitvoerlocaties_RMM_chk.csv';
waveTabFile =  '..\testdata\Golven\Res\U11D022S01_10.TAB';            %%'..\testdata\Golven\Res\U11D022S01_11.TAB';
location_table = ['..\testdata\OeverLoc_tabel', trajectname, '.csv'];
nc_file = '..\testdata\wRMM-Q01U00D360ZP116_riv_001_treeks_zwl.nc';
adminfile = ['..\testdata\workspace_', trajectname, '.mat'];

gridXY = ReadGridfile(rgfFile);
[allStat, n_stat] = ReadStations(allStations);
[exStat, n_ex] = ReadStations(asStations);
wetdry = ReadBlockfile(wetmax);

allStat(n_stat+1:n_stat+n_ex) = exStat;
n_stat = n_stat + n_ex;

%find coordinates
for i=1:n_stat
    n = allStat(i).n;
    allStat(i).x = 0.5*(gridXY( allStat(i).m-1,allStat(i).n-1,1)+gridXY(allStat(i).m,allStat(i).n,1));
    allStat(i).y = 0.5*(gridXY( allStat(i).m-1,allStat(i).n-1,2)+gridXY(allStat(i).m,allStat(i).n,2));
end

[asStat, n_as] = ReadLocations(asloc);
[oeverStat, n_oever] = ReadLocations(oeverloc);

%find n,m of as-stations and check for dryfall
asStat = setStationProperty(nc_file, n_as, n_stat, allStat, asStat, wetdry);

%find n,m of oever-stations and check for dryfall
oeverStat = setStationProperty(nc_file, n_oever, n_stat, allStat, oeverStat, wetdry);

%connect location to nearest as station
oeverStat = connect2As( n_oever, n_as, oeverStat, asStat);

%find the wavedata at the locations
%%oeverStat = setWaveData( wavedata, n_oever, oeverStat);

oeverStat = findNearestWaveStation(wavelocations, n_oever, oeverStat);

[Hs, Tpm1, Dir,oeverStat] = readWaveData(waveTabFile, n_oever, oeverStat);

WriteLocationsInfo(location_table, n_oever, oeverStat, asStat);

oeverStat = GetStationIndices( nc_file, n_oever, oeverStat, asStat)

save(adminfile, 'n_as', 'asStat', 'n_oever', 'oeverStat');

disp('finish');