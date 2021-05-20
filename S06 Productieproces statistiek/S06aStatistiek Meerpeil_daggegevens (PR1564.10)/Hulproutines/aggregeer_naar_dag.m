function [daggegevens] = aggregeer_naar_dag(jaar, maand, dag, meting);

% Door: Chris Geerse
% Datum: april 2012


%==========================================================================
% Aggregeer van uur- naar daggegevens.
%==========================================================================

% INPUT:
% jaar
% maand
% dag
% meting (kan uurwaarde zijn, maar ook iets anders, bijvoorbeeld 10-minuten
% waarde)

% OUTPUT:
% daggegevens
% Deze variabele bevat (per dag): jaar, maand, dag, min, max, mean, median, mode,
% std, aantal.

%==========================================================================

%Maak een uniek dagnummer
dagnr        = 10000*jaar + 100*maand + dag;
dagnr_uniek  = unique(dagnr);
n            = numel(dagnr_uniek);
dagnr_uniek1 = (1:n)';    %laat dit nummer beginnen bij 1

%Initialisatie
daggegevens     = [dagnr_uniek1, zeros(n,7)];

for j =  1 : max(dagnr_uniek1)

    %Zoek meting voor elk uniek dagnr
    x = meting(dagnr == dagnr_uniek(j));
    
    %Bereken de dagvariabelen
    daggegevens(j,2)  = min(x);
    daggegevens(j,3)  = max(x);
    daggegevens(j,4)  = mean(x);
    daggegevens(j,5)  = median(x);
    daggegevens(j,6)  = mode(x);
    daggegevens(j,7)  = std(x);
    daggegevens(j,8)  = numel(x);
end

%Vervang de eerste kolom met uniek dagnr door jaar, maand en dag:
jaar_uniek     = floor(dagnr_uniek/10000);
maand_uniek    = floor( (dagnr_uniek - 10000*jaar_uniek)/100 );
dag_uniek      = dagnr_uniek - 10000*jaar_uniek - 100*maand_uniek;

daggegevens    = [jaar_uniek, maand_uniek, dag_uniek, daggegevens(: , 2:8)];


