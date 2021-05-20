function WriteDryStatus( fname, n_stat, Stat)
%write location dat to .csv file

fid = fopen(fname, 'w');

for i = 1:n_stat
    fprintf(fid, '%s,%6.2f,%6.2f,%d\n', Stat(i).name{1}, Stat(i).x, Stat(i).y, Stat(i).drycod);
end

fclose(fid);

end