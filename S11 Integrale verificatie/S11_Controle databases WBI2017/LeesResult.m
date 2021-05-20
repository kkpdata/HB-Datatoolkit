function DatRes=LeesResult( path, type, traject_name, DatRes )
%Read result table from .xls file
%Create struct

fid = fopen([path,type,'\',type, '_',traject_name,'.xls'], 'r');
if fid >0 
    C = textscan(fid, '%s%s%f%f%s%s%s%s%s%f%9.3f%s%s%s%s', 'Delimiter', '\t', 'HeaderLines', 1, 'TreatAsEmpty', {'Infinity' '-Infinity', '*******'});
end

switch upper(type)   %set default values to result field
    case 'WS',
        for i = 1:6
            DatRes(i).WS(1:size(DatRes(5).x,2)) = -99;
        end
    case 'HS'   %%'HSIG',
        for i = 1:6
            DatRes(i).HS(1:size(DatRes(5).x,2)) = -99;
        end
    case 'TM',
        for i = 1:6
            DatRes(i).TM(1:size(DatRes(5).x,2)) = -99;
        end
    case 'HBN',
        for i = 1:6
            DatRes(i).HB1(1:size(DatRes(5).x,2)) = -99;
            DatRes(i).HB2(1:size(DatRes(5).x,2)) = -99;
        end
end

if fid < 0 
    return
end

for i = 1:6:size(C{2})
    j = find(strcmp(DatRes(5).name, C{2}(i)));
    if j>0
        switch upper(type)
            case 'WS',
                DatRes(1).WS(j) = C{11}(i);
                DatRes(2).WS(j) = C{11}(i+1);
                DatRes(3).WS(j) = C{11}(i+2);
                DatRes(4).WS(j) = C{11}(i+3);
                DatRes(5).WS(j) = C{11}(i+4);
                DatRes(6).WS(j) = C{11}(i+5);
            case 'HS'    %%'HSIG',
                DatRes(1).HS(j) = C{11}(i);
                DatRes(2).HS(j) = C{11}(i+1);
                DatRes(3).HS(j) = C{11}(i+2);
                DatRes(4).HS(j) = C{11}(i+3);
                DatRes(5).HS(j) = C{11}(i+4);
                DatRes(6).HS(j) = C{11}(i+5);
            case 'TM',
                DatRes(1).TM(j) = C{11}(i);
                DatRes(2).TM(j) = C{11}(i+1);
                DatRes(3).TM(j) = C{11}(i+2);
                DatRes(4).TM(j) = C{11}(i+3);
                DatRes(5).TM(j) = C{11}(i+4);
                DatRes(6).TM(j) = C{11}(i+5);
            case 'HBN',
                if isempty(findstr(char(C{5}(i)), 'damwand'))
                    DatRes(1).HB1(j) = C{11}(i);
                    DatRes(2).HB1(j) = C{11}(i+1);
                    DatRes(3).HB1(j) = C{11}(i+2);
                    DatRes(4).HB1(j) = C{11}(i+3);
                    DatRes(5).HB1(j) = C{11}(i+4);
                    DatRes(6).HB1(j) = C{11}(i+5);
                else
                    DatRes(1).HB2(j) = C{11}(i);
                    DatRes(2).HB2(j) = C{11}(i+1);
                    DatRes(3).HB2(j) = C{11}(i+2);
                    DatRes(4).HB2(j) = C{11}(i+3);
                    DatRes(5).HB2(j) = C{11}(i+4);
                    DatRes(6).HB2(j) = C{11}(i+5);
                end
        end
    end
end

fclose(fid);

end