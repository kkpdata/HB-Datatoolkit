function Err = ProcessComputation( compName, compCode, fid_log, fid_prt, n_stat, Stat, sourcedir, workdir)

Err = 0;
compName
if ExtractWaterlevelData( compName, sourcedir, workdir)
    [WL, idry, Err] = ProcessCondition( compName, compCode, fid_log, n_stat, Stat, workdir);
    for i=1:n_stat
        fprintf(fid_prt, '%s,%s,%s,%8.4f,%d\n', compName, compCode, Stat(i).name{1}, WL(i), idry(i));
    end
else
    Err = 3;
end
if Err>0
    fprintf(fid_log,'%s%s\n', 'Error in processing computation: ',strcat(compName,compCode));    
end

%check for condition closed barrier
cdir = cd;
cd(workdir);
for i=2:20
    fname = strcat('data_',compName);
    compCode = strcat('_riv_',num2str(i,'%03d'));
    if exist(strcat(fname,compCode,'.tar.gz')) > 0
        gunzip(strcat(fname,compCode,'.tar.gz'))
        untar(strcat(fname,compCode,'.tar'))
     
        cd(cdir);
        [WL, idry, Err] = ProcessCondition( compName, compCode, fid_log, n_stat, Stat, workdir);
        if Err>0
            fprintf(fid_log,'%s%s\n', 'Error in processing computation: ',strcat(compName,compCode));    
        end
        break;
    end
end

%if not found print same waterlevels as for open barrier
if Err==0
    for i=1:n_stat
        fprintf(fid_prt, '%s,%s,%s,%8.4f,%d\n', compName, compCode, Stat(i).name{1}, WL(i), idry(i));
    end
end
%clean the workdir
cd(workdir);
success=rmdir('barriers','s');
success=rmdir('output_csv','s');
success=rmdir('output_figuren_2Dplots_mfig','s');
success=rmdir('output_figuren_2Dplots_png','s');
success=rmdir('output_figuren_max13_mfig','s');
success=rmdir('output_figuren_max13_png','s');
success=rmdir('output_figuren_tijdreeks','s');
delete *.*;
cd(cdir);

end