function [golven_HB] = data_golven_HB(max_golven_HB, t_golven_HB, q_golven_HB);

%opslaan Hydra-B golven in structure
%Door: Chris Geerse
%Datum 21 april 2009

maxima_golven_HB = unique(max_golven_HB);
aantal_golven_HB = numel(maxima_golven_HB);

for i = 1:aantal_golven_HB;
    golven_HB(i).nr   = i;
    golven_HB(i).piek = maxima_golven_HB(i);
    Fi                = find(max_golven_HB == maxima_golven_HB(i));     %indices golf i
    golven_HB(i).tijd = t_golven_HB(Fi);                                %tijdstippen golf i in structure
    golven_HB(i).afv  = q_golven_HB(Fi);                                %afvoeren golf i in structure
end
