function WriteAxisConnection( dbname, resfile, DatRes )
%Schrijf de resultaten naar file

fid=fopen(resfile, 'r');

if fid < 0
    fid=fopen(resfile, 'a');
    fprintf(fid, '%s,%s,%s,%s,%s,%s\n', 'Database', 'Location', 'x_loc', 'y_loc',  'x_as', 'y_as');
else
    fclose(fid);
    fid=fopen(resfile, 'a');
end

for i = 1:size(DatRes(5).x,2)
    if abs(DatRes(5).x_as(i) + 999999) > 1
        dlm = sqrt((DatRes(5).x(i)-DatRes(5).x_as(i))^2 +(DatRes(5).y(i)-DatRes(5).y_as(i))^2);
        fprintf(fid, '%s,%s,%8.2f,%8.2f,%8.2f,%8.2f,%s,%8.2f\n', dbname, char(DatRes(5).name(i)), DatRes(5).x(i), DatRes(5).y(i),  DatRes(5).x_as(i), DatRes(5).y_as(i), char(DatRes(5).as_name(i)), dlm); 
    end
end

fclose(fid);

end