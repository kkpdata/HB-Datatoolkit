function oeverStat = GetStationIndices( fname, n_oever, oeverStat, asStat)
%find indices of stations for oever locations

ncid = netcdf.open(fname, 'NOWRITE');

id_namwl = netcdf.inqVarID(ncid, 'NAMWL');
namwl = netcdf.getVar(ncid, id_namwl);

for i=1:n_oever
    as_name = asStat(oeverStat(i).ind_as).station_name;
    for j = 1:size(namwl,2)
        if strcmp(strtrim(oeverStat(i).station_name), strtrim(namwl(:,j)'))
            oeverStat(i).station_id = j;
            break;
        end
    end
    for j = 1:size(namwl,2)
        if strcmp(strtrim(as_name), strtrim(namwl(:,j)'))
            oeverStat(i).backstation_id = j;
            break;
        end
    end
end

netcdf.close(ncid);

end