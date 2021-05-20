function [WL, dry] =MaxWL( nhalf, ntimes, target_id, zwl)
% determine the maximum waterlevel in station target_id.
% in case the station is dry the maximum waterlevel of a backup station is
% used (back1_id or back2_id)
% dry = 0 - no dryfall; WL is maximum of target_id
% dry = 1 - dryfall; WL is maximum of back1_id
% dry = 2 - dryfall; WL is maximum of back2_id

Wsi(1:ntimes)=0;

for i=nhalf:ntimes-nhalf
    Wsi(i) = sum(zwl(target_id,i-nhalf+1:i+nhalf))/(2.*nhalf); %waterstand gemiddeld over venster (-nhalf,nhalf)
%%    Wsmax = max(Wsi,Wsmax);
end
[Wsmax, Imax] = max(Wsi(130+nhalf:ntimes-nhalf));
Wsmin = min(Wsi(130+nhalf:ntimes-nhalf));
Wsm_r = min(zwl(target_id,Imax+130+nhalf:ntimes));
%%    if Wsi > Wsmax
%%        Wsmax = Wsi;
%%        imax = i;
%%    end
%%    Wsmin = min(Wsi,Wsmin);
%%end
if abs(Wsmax-Wsmin) < .10
    dry = 1;
    WL = 9999;
elseif Wsmax - Wsm_r < .005 && Imax+130+nhalf < ntimes-nhalf-5    %na maximum geen daling 
%%elseif size(find(diff(Wsi(Imax+130+nhalf:ntimes-nhalf))<-0.00001),2)== 0 && Imax+130+nhalf < ntimes-nhalf-5    %na maximum geen daling 
    dry = 1;
    WL = 9999;
else
    dry = 0;
    WL = Wsmax;
end

end