function Arr =ReadGridfile( fname)

fid = fopen(fname, 'r');

tline = '*';
while (tline(1:1)=='*')
    tline = fgets(fid);
end
tline=fgets(fid);

nm = fscanf(fid, '%d', 2);
shift = fscanf(fid, '%f \n', 3);
%tline=fgets(fid);
%keyw = sscanf(tline, '%6s');
%x-coordinate
for irow=1:nm(2)
    icol = fscanf(fid, 'ETA= %d', 1);
    cl = fscanf(fid, '%f \n', nm(1));
    Arr(1:nm(1),icol,1) = cl;
end
%y-coordinate
for irow=1:nm(2)
    icol = fscanf(fid, 'ETA= %d', 1);
    cl = fscanf(fid, '%f \n', nm(1));
    Arr(1:nm(1),icol,2) = cl;
end

fclose(fid);

end
