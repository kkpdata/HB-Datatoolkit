function [jaar,maand,dag,datum,qlith] = inlezen_Lith(invoerpad, infile_data);

% Door: Chris Geerse

%==========================================================================
% Inlezen waterstanddata
%==========================================================================

filenaam_data        = fullfile(invoerpad, infile_data);
[datuminlees, qlith] = textread(filenaam_data,'%f %f','delimiter',' ','commentstyle','matlab');

% omzetten datuminlees
[jaar,maand,dag,datum]      = datumconversiejjjjmmdd(datuminlees);

%==========================================================================
%geef hier de gewenste selectieperiode voor Lith aan:
%==========================================================================
bej = 1911;
bem = 1;
bed = 1;
eij = 1998; %laat beginmaanden 1999 weg om geheel aantal jaren te krijgen
eim = 12;
eid = 31;

%==========================================================================
%Enkele hiaatwaarden (999999999) pragmatisch aanpassen
%==========================================================================

qlith(30203:30206)   = 50;
qlith(31964)         = 100;

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
qlith       = qlith(selectie);

