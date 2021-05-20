function [WL, dry] =MaxWL( nhalf, ntimes, target_id, zwl)
% determine the maximum waterlevel in station target_id.
% in case the station is dry the maximum waterlevel of a backup station is
% used (back1_id or back2_id)
% dry = 0 - no dryfall; WL is maximum of target_id
% dry = 1 - dryfall; WL is maximum of back1_id
% dry = 2 - dryfall; WL is maximum of back2_id

Wsmax = -100000.;
Wsmin = 100000.;

for i=nhalf:ntimes-nhalf
    Wsi = sum(zwl(target_id,i-nhalf+1:i+nhalf))/(2.*nhalf); %waterstand gemiddeld over venster (-nhalf,nhalf)
    Wsmax = max(Wsi,Wsmax);
    Wsmin = min(Wsi,Wsmin);
end
if abs(Wsmax-Wsmin) < .05
    dry = 1;
    WL = 9999;
else
    dry = 0;
    WL = Wsmax;
end

end