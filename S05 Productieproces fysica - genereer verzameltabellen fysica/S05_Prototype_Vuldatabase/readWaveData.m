function [Hs, Tm1, oeverStat] = readWaveData( fname, n_oever, oeverStat)
%find the nearest Swan output location for each oever location

fid = fopen(fname, 'r');

for i=1:7
    tline=fgets(fid);
end

C = textscan(fid, '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f', 'Delimiter',  'MultipleDelimsAsOne' );

fclose(fid);

for i = 1:n_oever

    if C{4}(oeverStat(i).waveloc) == -9.0
        oeverStat(i).drywave = 1;
        Hs(i) = 0.;
        Tm1(i) = 0.;
    else
        oeverStat(i).drywave = 0;
%%        oeverStat(i).Hs = C{4}(oeverStat(i).waveloc);
%%        oeverStat(i).Tp = C{5}(oeverStat(i).waveloc);
        Hs(i) = C{4}(oeverStat(i).waveloc);
        Tm1(i) = C{7}(oeverStat(i).waveloc);
    end
end

end
