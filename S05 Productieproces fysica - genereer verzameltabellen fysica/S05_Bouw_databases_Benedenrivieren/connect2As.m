function oeverStat = connect2As( n_oever, n_as, oeverStat, asStat)
%find nearest axis station which is not dry to location

for i = 1:n_oever
    dmin = 1.e10;
    for j = 1:n_as
        if asStat(j).drycod == 0
            dl = (oeverStat(i).x-asStat(j).x)^2 + (oeverStat(i).y-asStat(j).y)^2;
            if dl<dmin 
                dmin = dl;
                jmin = j;
            end
        end
    end
    oeverStat(i).ind_as = jmin;
end

end