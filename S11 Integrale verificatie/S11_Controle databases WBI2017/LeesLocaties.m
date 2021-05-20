function S=LeesLocaties( traject_name )
%Read location table from .csv file
%Create struct

fid = fopen([traject_name,'.csv'], 'r');
C = textscan(fid, '%f%d%s%f%f%f%f', 'HeaderLines', 1, 'Delimiter', ',');

%%S(1:size(C),5).name = C{3}';
%%S(1:size(C),5).x = C{4}';
%%S(1:size(C),5).y = C{5}';
S(5).name = C{3}';
S(5).x = C{4}';
S(5).y = C{5}';

fclose(fid);

end