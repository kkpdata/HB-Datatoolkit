function GenerateDefPLB( path1, path2, traject_name )
%Read file with dike normals and create .plb file with defaults for
%toetspeil
%

fid = fopen([path1,traject_name,'.csv'], 'r');
%%C = textscan(fid, '%s%f%f%f','Delimiter', ',', 'HeaderLines', 0);
C = textscan(fid, '%s%f%f%f%f','Delimiter', ',', 'HeaderLines', 0);

for i = 1:size(C{1})
        arr(i).x = C{2}(i);
        arr(i).y = C{3}(i);
        arr(i).name = char(C{1}{i});
        arr(i).krh = [C{5}(i)];   %%10;
        arr(i).ws = .999;
        arr(i).dn = [C{4}(i)];
        arr(i).slp = 3;
        arr(i).is = 1;
        arr(i).ind = 0;
end

fod = fopen([path2,traject_name,'.plb'], 'w');

fprintf(fod, '%d\r\n', size(arr,2));
for i = 1:size(arr,2)
    fprintf(fod, '%8.2f %8.2f "%s" %8.2f %8.4f %8.2f %6.3f %d  %d\r\n', arr(i).x, arr(i).y, arr(i).name, arr(i).krh, arr(i).ws, arr(i).dn, arr(i).slp, arr(i).is, arr(i).ind); 
end
%%csvwrite([path2,traject_name,'.plb'], arr)
fclose(fod);
fclose(fid);
end
