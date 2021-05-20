function WriteResults( path, dbname, resfile, DatRes )
%Schrijf de resultaten naar file

fid=fopen([path,'Tables\',dbname, '.csv'],'w');

fres=fopen(resfile, 'a');

fprintf(fres, '%s,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n', dbname, size(DatRes(5).x,2), size(find(DatRes(5).Qcode ==1),2),size(find(DatRes(5).Qcode ==2),2), size(find(DatRes(5).Qcode ==3),2),  ...
        size(find(DatRes(5).Qcode ==4),2), size(find(DatRes(5).Qcode ==5),2), size(find(DatRes(5).Qcode ==6),2), size(find(DatRes(5).Qcode ==7),2),    ...
        size(find(DatRes(5).Qcode ==8),2), size(find(DatRes(5).Qcode ==9),2), size(find(DatRes(5).Qcode ==10),2), size(find(DatRes(5).Qcode ==11),2),    ...
        size(find(DatRes(5).Qcode ==12),2), size(find(DatRes(5).Qcode ==13),2));

fprintf(fid, '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n', 'Location', 'x_loc', 'y_loc',  'x_as', 'y_as',  'WS_as',   ...
                         'WS_loc', 'HS_loc',  'TM_loc',  'HBN1',  'HBN2',  'dHW1',  ...
                         'dHW2', 'dHW3', 'dHW', 'dHB1', 'dHB2', 'dl_WS', 'dl_HB1', 'dl_HB2', 'dl_HS', 'dl_TM', 'Qcod');
for i = 1:size(DatRes(5).x,2)
    if DatRes(5).Qcode(i) > 0
        fprintf(fid, '%s,%8.2f,%8.2f,%8.2f,%8.2f,%8.2f,%8.2f,%8.2f,%8.2f,%8.2f,%8.2f,%8.4f,%8.4f,%8.4f,%8.2f,%8.2f,%8.2f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%d\n', char(DatRes(5).name(i)), DatRes(5).x(i), DatRes(5).y(i),  DatRes(5).x_as(i), DatRes(5).y_as(i),  DatRes(5).WS_as(i),   ...
                         DatRes(5).WS(i), DatRes(5).HS(i),  DatRes(5).TM(i),  DatRes(5).HB1(i),  DatRes(5).HB2(i),  DatRes(5).dHW1(i),  ...
                         DatRes(5).dHW2(i), DatRes(5).dHW3(i), DatRes(5).dHW(i), DatRes(5).dHB1(i), DatRes(5).dHB2(i), ...
                         DatRes(5).dl_WS(i), DatRes(5).dl_HB1(i), DatRes(5).dl_HB2(i), DatRes(5).dl_HS(i), DatRes(5).dl_TM(i), DatRes(5).Qcode(i));
    end
end

fclose(fid);
fclose(fres);

matname = [path,'Matlab\',dbname];
save(matname, 'DatRes');

end