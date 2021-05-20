function Arr =ReadBlockfile( fname)

fid = fopen(fname, 'r');

tline = '#';
while (tline(1:1)=='#')
    tline = fgets(fid);
%%    term = fgets(fid);
end
while ~feof(fid)
    if ~isempty(findstr(tline, 'BOX'))
        i1 = findstr(tline,'(');
        indices = sscanf(tline(i1+1:end),'%d,%d;%d,%d');
   
        row = [];
        for i = indices(1):indices(3)
            row = fscanf(fid, '%f', indices(4)-indices(2)+1);
            Arr(i,indices(2):indices(4)) = row;
        end
    end
    tline = fgets(fid);
end

fclose(fid);

end