function Stat = SetDryCode( n_stat, Stat, wetdry)
%set drycod in station struct (drycod=0 station is wet; drycod=1 station is
%dry; drycod=2 station is not defined in schematisation);

for i = 1:n_stat
    if isempty(Stat(i).n) 
        Stat(i).drycod = 2;
    elseif wetdry(Stat(i).m+1, Stat(i).n+1) == -999.0000
        Stat(i).drycod = 1;
    else
        Stat(i).drycod = 0;
    end
end

end