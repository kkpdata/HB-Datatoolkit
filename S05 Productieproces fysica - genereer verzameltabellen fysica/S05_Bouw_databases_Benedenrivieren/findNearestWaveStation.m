function oeverStat = findNearestWaveStation( fname, n_oever, oeverStat)
%find the nearest Swan output location for each oever location

fid = fopen(fname, 'r');

C = textscan(fid, '%f%f', 'Delimiter', ',');

for i = 1:size(C{1},1)
    x(i) = C{1}(i);
    y(i) = C{2}(i);
end
n_out = size(C{1},1);

fclose(fid);

for i = 1:n_oever
    xi = oeverStat(i).x;
    yi = oeverStat(i).y;
    dlmin = 1000000;
    jmin=-1;
    
    for j = 1:n_out
        dx = xi-x(j);
        dy = yi-y(j);
        dl = dx*dx + dy*dy;
        if dl < dlmin
            dlmin = dl;
            jmin = j;
        end
    end
    oeverStat(i).waveloc = jmin;
    if dlmin > 10000
        oeverStat(i).waveloc = -1;
        disp(['Minimum distance of location ' oeverStat(i).name num2str(sqrt(dlmin))]);
    end
end

end
