function [data_maand] = aggregeer_naar_maand(data, jaar, maand)

%==========================================================================
% Aggregeren naar maandwaarden

% Van elke waarneming moet beschikbaar zijn:
% data
% jaar
% maand

% Nadien aanwezig: min, max, mean, median, mode, std, aantal.

%==========================================================================

%Maak een uniek maandnummer
maandnr        = 100*jaar + maand;
maandnr_uniek  = unique(maandnr);
n              = numel(maandnr_uniek);
maandnr_uniek1 = (1:n)';    %laat dit nummer beginnen bij 1


%Initialisatie
data_maand     = [maandnr_uniek1, zeros(n,7)];

for j =  1 : max(maandnr_uniek1)

    %Zoek data voor elk uniek maandnr
    x = data(maandnr == maandnr_uniek(j));
    
    %Bereken de maandvariabelen
    data_maand(j,2)  = min(x);
    data_maand(j,3)  = max(x);
    data_maand(j,4)  = mean(x);
    data_maand(j,5)  = median(x);
    data_maand(j,6)  = mode(x);
    data_maand(j,7)  = std(x);
    data_maand(j,8)  = numel(x);
end

%Vervang de eerste kolom met uniek maandnr door jaar en maand:

jaar_uniek     = floor(maandnr_uniek/100);
maand_uniek    = maandnr_uniek - 100*jaar_uniek;

data_maand     = [jaar_uniek, maand_uniek, data_maand(: , 2:8)];
