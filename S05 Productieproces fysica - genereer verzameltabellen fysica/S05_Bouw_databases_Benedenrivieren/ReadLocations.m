function [stat, n_stat] =ReadLocations( fname)
%read as locations from .csv file name, x,y, code

fid = fopen(fname, 'r');

C = textscan(fid, '%s%f%f%d', 'Delimiter', ',');

for i = 1:size(C{1},1)
    stat(i).name = C{1}(i);
    stat(i).x = C{2}(i);
    stat(i).y = C{3}(i);
    stat(i).loccod = C{4}(i);
end
n_stat = size(C{1},1);

fclose(fid);

end