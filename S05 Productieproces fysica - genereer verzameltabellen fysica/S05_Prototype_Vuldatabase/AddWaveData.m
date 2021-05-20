function AddWaveData( fname, fresult, flog, sourcedir, workdir, n_oever, oeverStat)
%add wave data to records with location and waterlevel data
%fname - csvfile with waterlevel data
%fresult - csvfile with resulting records with waterlevel and wave data
%sourcedir - directory where zipfiles with waedata are stored
%workdir - directory used to extract a zipfile

wcod = ['S01'; 'S02'; 'S03'; 'S04'; 'S05'; 'S06'; 'S07'; 'S08'; 'S09'];
ws0 = [ -1, 0, 1, 2, 3, 4, 5, 7, 9];

fid = fopen(fname, 'r');
fid_csv = fopen(fresult, 'w');
fid_log = fopen(flog, 'w');

C = textscan(fid, '%s%s%s%f%d', 'Delimiter', ',');
fclose(fid);

fn_old = '';
for i=1:n_oever
    names(i) = strtrim(oeverStat(i).name);
end

for i=1:size(C{1},1)
    filecod = C{1}{i};
    uc = filecod(9:11);
    if ~strcmp(uc, 'U00')
        dc = filecod(12:15);
        wlev = C{4}(i);
        j = find((wlev-ws0)<0,1);
        if isempty(j)
            fprintf(fid_log,'%s%s%s%s\n', 'Error - waterlevel not in range wave data; computation: ',strcat(filecod,C{2}{i}),' waterlevel ', num2str(wlev));    
            j = size(ws0,1);
            fac = 0.;
        elseif j < 2 
            fprintf(fid_log,'%s%s%s%s\n', 'Error - waterlevel not in range wave data; computation: ',strcat(filecod,C{2}{i}),' waterlevel ', num2str(wlev));    
            j = 2;
            fac = 0.;
        else
            fac = (wlev-ws0(j-1))/(ws0(j)-ws0(j-1));
        end
        fn1_wve = strcat('RMM-',uc,dc,wcod(j-1,:));
        fn2_wve = strcat('RMM-',uc,dc,wcod(j,:));
        if ~strcmp(fn1_wve, fn_old)
            fn_old = fn1_wve;
            iret1 = ExtractWaveData(fn1_wve,sourcedir,strcat(workdir,'01'));
            iret2 = ExtractWaveData(fn2_wve,sourcedir,strcat(workdir,'02'));
            if iret1 ~= 1 
                fprintf(fid_log,'%s%s%s%s\n', 'Error in processing wave data ', fn1_wve, ' computation: ',strcat(filecod,C{2}{i}));    
            elseif iret2 ~= 1 
                fprintf(fid_log,'%s%s%s%s\n', 'Error in processing wave data ', fn2_wve, ' computation: ',strcat(filecod,C{2}{i}));    
            else
                fn1_tab = strcat(workdir,'01\RES\',fn1_wve(5:end), '_11.tab');
                fn2_tab = strcat(workdir,'02\RES\',fn2_wve(5:end), '_11.tab');
                [Hs_1, Tm1_1, oeverStat] = readWaveData( fn1_tab, n_oever, oeverStat);
                [Hs_2, Tm1_2, oeverStat] = readWaveData( fn2_tab, n_oever, oeverStat);
            end
        end
        loc_ind = strmatch(strtrim(C{3}{i}),names);
        Hs = Hs_1(loc_ind) + fac * (Hs_2(loc_ind)-Hs_1(loc_ind));
        Tm1 = Tm1_1(loc_ind) + fac * (Tm1_2(loc_ind)-Tm1_1(loc_ind));
        fprintf(fid_csv,'%s,%s,%s,%8.4f,%d,%8.4f,%8.4f\n',filecod, C{2}{i}, C{3}{i},C{4}(i),C{5}(i),Hs,Tm1);
    else
        fprintf(fid_csv,'%s,%s,%s,%8.4f,%d,%8.4f,%8.4f\n',filecod, C{2}{i}, C{3}{i},C{4}(i),C{5}(i),0.0,0.0);
    end
end
    
fclose(fid_csv);
fclose(fid_log);

end