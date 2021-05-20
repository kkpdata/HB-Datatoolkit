function [WL, idry, Err] = ProcessCondition( compName, compCode, fid_log, n_stat, Stat, workdir)

l_window = 60;
Err = 0;

ncid = netcdf.open(strcat(workdir,compName, compCode, '_treeks_zwl.nc'), 'NOWRITE');
%get time info history data
id_time = netcdf.inqVarID(ncid, 'TIME');
time_arr = netcdf.getVar(ncid, id_time);
ntimes = size(time_arr,1);
tihisi = time_arr(2)-time_arr(1);
nwindow = l_window/tihisi;
nhalf   = nwindow/2;
nhalf   = max(1,nhalf);

id_zwl = netcdf.inqVarID(ncid, 'ZWL');
zwl = netcdf.getVar(ncid, id_zwl);
WL(1:n_stat)=0;
idry(1:n_stat)=0;

%%    wetmax = strcat(workdir,compName,compCode,'_WETMAXVAL'); 
%%    wetdry = ReadBlockfile(wetmax);

%%    Stat = SetDryCode( n_stat, Stat, wetdry);

for i=1:n_stat
%%        if Stat(i).drycod==0
    [WL(i), idry(i)] = MaxWL(nhalf, ntimes, Stat(i).station_id, zwl);
%%            if iret > 0
%%                Err = 1;
%%                fprintf(fid_log,'%s\n', 'Warning station signal gives dryfall while Wetmaxval gives wet; Computation: ',strcat(compName,compCode),' Station: ', Stat(i).name{1});
%%            end
%%        end
%%        if Stat(i).drycod==1 || iret > 0
    if idry(i) > 0
        [WL(i), iret] = MaxWL(nhalf, ntimes, Stat(i).backstation_id, zwl);
        if iret > 0
            Err = 2;
            fprintf(fid_log,'%s%s%s%s\n', 'Error correct waterlevel not found; Computation: ',strcat(compName,compCode),' Station: ', Stat(i).name{1});
        end                
    end
%%    nr = i
end

netcdf.close(ncid);
end