[datum,tijd,richting,qdd,snelheid,upd] = textread('s240.asc','%u %u %u %u %u %u','delimiter',',','headerlines',22);
v = snelheid;
index_tot = [1:length(snelheid)]';
n = 1;
storm(1,1) = 0;
while e<=length(snelheid)
    vmax = max(v(b:e,1));
    i = find(v(b:e,1) == vmax);
    if i == ((e-b)/2)+1 & vmax > v_max
        index_all(:,n) = index_tot(b:e,1);
        n = n+1;
    end
    b = b+1;
    e = e+1;
end
storm_snelheid = (snelheid(index_all))/10;
storm_snelheid(end+1,:) = 0;
storm_snelheid = reshape(storm_snelheid,numel(storm_snelheid),1);
storm_richting = richting(index_all);
storm_richting(end+1,:) = 0;
storm_richting = reshape(storm_richting,numel(storm_richting),1);
storm_datum = datum(index_all);
storm_datum(end+1,:) = 0;
storm_datum = reshape(storm_datum,numel(storm_datum),1);
storm_tijd = tijd(index_all);
storm_tijd(end+1,:) = 0;
storm_tijd = reshape(storm_tijd,numel(storm_tijd),1);
storm_data = [storm_datum storm_tijd storm_snelheid storm_richting];
storm_data = [0 0 0 0;storm_data];
save stormdata.txt storm_data -ascii


    