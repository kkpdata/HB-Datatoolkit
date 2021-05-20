function GetLocationData( fname, fresult, location_name)
%find the nearest Swan output location for each oever location

fid = fopen(fname, 'r');

fid_prt = fopen(fresult, 'w');

C = textscan(fid, '%s%s%s%f%d', 'Delimiter', ',');

ind = strmatch(location_name,C{3},  'exact');
    
Rs{1} = C{1}(ind);
Rs{2} = C{2}(ind);
Rs{3} = C{3}(ind);
Rs{4} = C{4}(ind);
Rs{5} = C{5}(ind);

for i = 1: size(Rs{1},1)
        fprintf(fid_prt, '%s,%s,%s,%8.4f,%d\n', Rs{1}{i}, Rs{2}{i}, Rs{3}{i}, Rs{4}(i), Rs{5}(i));
end

fclose(fid);
fclose(fid_prt);

end