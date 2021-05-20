function DatRes=Connect2Axis( path, axis_name, DatRes )
%Connect each location to the closest axis location 

fid = fopen([path,axis_name,'.xls'], 'r');
C = textscan(fid, '%s%s%f%f%s%s%s%s%s%f%9.3f%s%s%s%s', 'Delimiter', '\t', 'HeaderLines', 1);

for iloc = 1:size(DatRes(5).x,2)
    xloc = DatRes(5).x(iloc);
    yloc = DatRes(5).y(iloc);
    dlmin = 999999;
    imin = 0;
    DatRes(5).x_as(iloc)=-999999;
    for i = 1:6:size(C{2})
        x = C{3}(i);
        y = C{4}(i);
        if abs(x-xloc) < 5000. && abs(y-yloc) < 5000.
            dl = sqrt((x-xloc)^2 + (y-yloc)^2);
            if dl < dlmin
                dlmin = dl;
                imin = i;
            end
        end
    end
    if imin > 0
        DatRes(5).x_as(iloc) = C{3}(imin);
        DatRes(5).y_as(iloc) = C{4}(imin);
        DatRes(5).WS_as(iloc) = C{11}(imin+4);
        DatRes(3).WS_as(iloc) = C{11}(imin+2);
        DatRes(5).as_name(iloc) = C{2}(imin)';
    else
%%        warning(['Geen as locatie gevonden voor ', DatRes(5).name(iloc)]);
    end
end

fclose(fid);
end