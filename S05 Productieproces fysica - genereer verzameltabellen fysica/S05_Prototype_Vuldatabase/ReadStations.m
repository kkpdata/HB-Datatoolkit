function [stat, n_stat] =ReadStations( fname)
%read stations info from Simona include file
%store grid indices and name

fid = fopen(fname, 'r');

tline = fgets(fid);
j = 1;

while ~feof(fid)
    i1 = findstr(tline,'(m=');
    stat(j).m = sscanf(tline(i1+3:end),'%d');
    i1 = findstr(tline,', n=');
    stat(j).n = sscanf(tline(i1+4:end),'%d');
    i1 = findstr(tline,'name=');
    stat(j).name = sscanf(tline(i1+6:end-4),'%s');
    tline = fgets(fid);
    j = j+1;
end
n_stat = j-1;

fclose(fid);

end