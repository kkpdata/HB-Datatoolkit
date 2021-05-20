function [jaar,maand,dag,uur,datum, m] = inlezen_HvH(invoerpad, infile_data);

% Door: Chris Geerse

%==========================================================================
% Inlezen waterstanddata
%==========================================================================

filenaam_data                        = fullfile(invoerpad, infile_data);
[datuminlees, uur, m] = textread(filenaam_data,'%u %u %f','headerlines',15);

% Betreft 3-uurswaarden.
% m = waterstand in cm+NAP.


% omzetten datuminlees
[jaar,maand,dag,datum]      = datumconversiejjjjmmdd(datuminlees);






% NB: met onderstaande code gaat het inlezen fout. Waarom????
% Vanwege 3-uurswaarden??

% %==========================================================================
% %geef hier de gewenste selectieperiode voor Schiphol aan:
% %==========================================================================
% bej = 1939; 
% bem = 1;
% bed = 1;
% beu = 1;
% 
% eij = 1970; 
% eim = 12;
% eid = 31;
% eiu = 23;   
% 
% %==========================================================================
% %Bepaal de data voor de geldige periode
% %==========================================================================
% 
% bedatum     = datenum(bej,bem,bed,beu,0,0);
% eidatum     = datenum(eij,eim,eid,eiu,0,0);
% 
% selectie    = find(datum >= bedatum & datum <= eidatum);
% jaar        = jaar(selectie);
% maand       = maand(selectie);
% dag         = dag(selectie);
% uur         = uur(selectie);
% m           = m(selectie);
% datum       = datenum(jaar,maand,dag,uur,0,0);
% 
