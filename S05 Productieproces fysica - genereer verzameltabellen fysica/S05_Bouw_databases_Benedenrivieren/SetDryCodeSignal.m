function Stat = SetDryCodeSignal( fname, n_stat, Stat, wetdry)
%set drycod in station struct (drycod=0 station is wet; drycod=1 station is
%dry; drycod=2 station is not defined in schematisation);

ncid = netcdf.open(fname, 'NOWRITE');
l_window = 60;

id_namwl = netcdf.inqVarID(ncid, 'NAMWL');
namwl = netcdf.getVar(ncid, id_namwl);
id_zwl = netcdf.inqVarID(ncid, 'ZWL');
zwl = netcdf.getVar(ncid, id_zwl);

id_time = netcdf.inqVarID(ncid, 'TIME');
time_arr = netcdf.getVar(ncid, id_time);
ntimes = size(time_arr,1);
tihisi = time_arr(2)-time_arr(1);
nwindow = l_window/tihisi;
nhalf   = nwindow/2;
nhalf   = max(1,nhalf);

for i = 1:n_stat
    if ~isempty(Stat(i).station_name)
        for j = 1:size(namwl,2)
            if strcmp(strtrim(Stat(i).station_name), strtrim(namwl(:,j)'))
                Stat(i).station_id = j;
                break;
            end
        end
        [WL(i), iret] = MaxWL(nhalf, ntimes, Stat(i).station_id, zwl);
        Stat(i).drycod = iret;
    else 
        Stat(i).drycod = 2;
    end
end

netcdf.close(ncid);
end