function iret = ExtractWaterlevelData( fname, sourcedir, workdir)
%copy and extract waterleveldata to workdir

iret = 0;
cdir = cd;
cd(workdir);

if copyfile(strcat(sourcedir,fname,'.zip'),workdir)
    unzip(strcat(fname,'.zip'));
    gunzip(strcat('data_',fname,'_riv_001.tar.gz'));
    untar(strcat('data_',fname,'_riv_001.tar'));
    iret = 1;
end

cd(cdir);

end
