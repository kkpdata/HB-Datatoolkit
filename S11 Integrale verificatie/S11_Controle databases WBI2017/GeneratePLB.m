function GeneratePLB( path1, path2, traject_name, DatRes )
%Read file with dike normals and create .plb file
%

fid = fopen([path1,traject_name,'.csv'], 'r');
C = textscan(fid, '%s%f%f%f','Delimiter', ',', 'HeaderLines', 0);

for i = 1:size(C{1})
    j = find(strcmp(DatRes(5).name, C{1}(i)));
    if j>0
        arr(i).x = DatRes(5).x(j);
        arr(i).y = DatRes(5).y(j);
        arr(i).name = DatRes(5).name{j};
        arr(i).krh = 10;
        arr(i).ws = DatRes(5).WS(j);
        arr(i).dn = [C{4}(i)];
        arr(i).slp = 3;
        arr(i).is = 1;
        arr(i).ind = 0;
    else
        warning(['No location found for ', C{1}(i)]);
    end
end

if size(arr,2) ~= size(DatRes(5).name,2)
    warning('Nr of locations is not equal to nr of profiles');
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
        