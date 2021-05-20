rgfFile = '..\testdata\grid-rmmriv40m_5-v5.rgf';
allStations = '..\testdata\uitvloc_alles.beno14';
asStations = '..\testdata\rivkmp.beno14';
prname = '..\testdata\asstations_SDS';

gridXY = ReadGridfile(rgfFile);
%%[allStat, n_stat] = ReadStations(allStations);
[allStat, n_stat] = ReadStations(asStations);
%%[exStat, n_ex] = ReadStations(asStations);

%%allStat(n_stat+1:n_stat+n_ex) = exStat;
%%n_stat = n_stat + n_ex;

%find coordinates
for i=1:n_stat
    n = allStat(i).n;
    allStat(i).x = 0.5*(gridXY( allStat(i).m-1,allStat(i).n-1,1)+gridXY(allStat(i).m,allStat(i).n,1));
    allStat(i).y = 0.5*(gridXY( allStat(i).m-1,allStat(i).n-1,2)+gridXY(allStat(i).m,allStat(i).n,2));
end

fid = fopen(prname, 'w');

for i = 1:n_stat
    fprintf(fid, '%s,%6.2f,%6.2f\n', allStat(i).name, allStat(i).x, allStat(i).y);
end

fclose(fid);
