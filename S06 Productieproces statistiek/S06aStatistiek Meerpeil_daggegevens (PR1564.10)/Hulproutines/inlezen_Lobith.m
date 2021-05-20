function [jaar,maand,dag,datum,qlob] = inlezen_Lobith(invoerpad, infile_data);

% Door: Chris Geerse

%==========================================================================
% Inlezen waterstanddata
%==========================================================================

filenaam_data               = fullfile(invoerpad, infile_data);
[datuminlees,mp,qlob,qolst] = textread(filenaam_data,'%f %f %f %f','delimiter',' ','commentstyle','matlab');

% omzetten datuminlees
[jaar,maand,dag,datum]      = datumconversiejjjjmmdd(datuminlees);

%==========================================================================
%geef hier de gewenste selectieperiode voor Lobith aan:
%==========================================================================
bej = 1901;
bem = 1;
bed = 1;
eij = 2004; %laat beginmaanden 2005 weg om geheel aantal jaren te krijgen
eim = 12;
eid = 31;

%==========================================================================
%Bepaal de data voor de geldige periode
%==========================================================================

bedatum     = datenum(bej,bem,bed);
eidatum     = datenum(eij,eim,eid);
selectie    = find(datum >= bedatum & datum <= eidatum);

jaar        = jaar(selectie);
maand       = maand(selectie);
dag         = dag(selectie);
datum       = datenum(jaar,maand,dag);
qlob        = qlob(selectie);

