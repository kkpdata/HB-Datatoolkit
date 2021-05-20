function WriteLocationsInfo( fname, n_oever, oeverStat, asStat)
%write location dat to .csv file

fid = fopen(fname, 'w');

for i = 1:n_oever
    fprintf(fid, '%s,%6.2f,%6.2f,%d,%d,%s,%f,%f\n', oeverStat(i).name{1}, oeverStat(i).x, oeverStat(i).y, oeverStat(i).drycod, oeverStat(i).drywave, asStat(oeverStat(i).ind_as).name{1}, ...
           asStat(oeverStat(i).ind_as).x, asStat(oeverStat(i).ind_as).y);
end

fclose(fid);

end