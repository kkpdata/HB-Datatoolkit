function Stat = setStationProperty( nc_name, n_stat, n_allStat, allStat, Stat, wetdry)
%find n,m indices of locations and check if location is dry
%find n,m of as-stations
for i = 1:n_stat
    dlmin=100000;
    Stat(i).n = 0;
    Stat(i).station_name = [];
    for j = 1:n_allStat
        dl = (Stat(i).x-allStat(j).x)^2 + (Stat(i).y-allStat(j).y)^2;
        dlmin = min(dl,dlmin);
        if abs(dl) < 2500.0   % afstand < 50 m
%%        if strcmp(strtrim(asStat(i).name), strtrim(allStat(j).name))
            Stat(i).n = allStat(j).n;
            Stat(i).m = allStat(j).m;
            Stat(i).station_name = allStat(j).name;
            break;
        end
    end
    if Stat(i).n == 0 || isempty(Stat(i).station_name) 
        dlmin
        disp(strcat('Error in finding (n,m) of station ', Stat(i).name));
    end
%    disp(i);
end

% check if station is dry
Stat = SetDryCodeSignal(nc_name, n_stat, Stat, wetdry);

end