function [Hs, Tm1, Dir, oeverStat] = readWaveData( fname, n_oever, oeverStat)
%find the nearest Swan output location for each oever location

fid = fopen(fname, 'r');

for i=1:7
    tline=fgets(fid);
end

C = textscan(fid, '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f', 'Delimiter',  'MultipleDelimsAsOne' );

fclose(fid);
Hs(1:n_oever) = 0.;
Tm1(1:n_oever) = 0;
Dir(1:n_oever) = 0.;

for i = 1:n_oever
    if oeverStat(i).waveloc == -1
        oeverStat(i).drywave = -1;  %no waves available
    elseif C{4}(oeverStat(i).waveloc) == -9.0
        oeverStat(i).drywave = 1;
    else
        oeverStat(i).drywave = 0;
%%        oeverStat(i).Hs = C{4}(oeverStat(i).waveloc);
%%        oeverStat(i).Tp = C{5}(oeverStat(i).waveloc);
        Hs(i) = C{4}(oeverStat(i).waveloc);
        Tm1(i) = C{7}(oeverStat(i).waveloc);
        Dir(i) = C{10}(oeverStat(i).waveloc);
    end
end

end
