function iret = ExtractWaveData( fname, sourcedir, workdir)
%copy and extract wavedata to workdir

iret = 0;
cdir = cd;
cd(workdir);
success=rmdir('INP','s');
success=rmdir('LOG','s');
success=rmdir('RES','s');
delete *.*;

if copyfile(strcat(sourcedir,fname,'.zip'),workdir)
    unzip(strcat(fname,'.zip'));
    iret = 1;
end

cd(cdir);

end
