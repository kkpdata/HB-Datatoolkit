function [jaar,maand,dag,uur,datum, r,qdd,u,qup] = inlezen_Schiphol(invoerpad, infile_data);

% Door: Chris Geerse

%==========================================================================
% Inlezen waterstanddata
%==========================================================================

filenaam_data                        = fullfile(invoerpad, infile_data);
[datuminlees,uur,r,qdd,snelheid,qup] = textread(filenaam_data,'%u %u %u %u %u %u','delimiter',',','headerlines',22);

u = snelheid/10;    %omrekening van dm/s naar m/s


% omzetten datuminlees
[jaar,maand,dag,datum]      = datumconversiejjjjmmdd(datuminlees);

%==========================================================================
%geef hier de gewenste selectieperiode voor Schiphol aan:
%==========================================================================
bej = 1951; %laat eind 1950 weg om geheel aantal jaren te krijgen
bem = 1;
bed = 1;
beu = 1;

eij = 2004; %laat beginmaanden 2006 weg om geheel aantal jaren te krijgen
eim = 12;
eid = 31;
eiu = 23;   %dit mag geen 24 zijn, anders pakt hij begin jan erbij. Waarom????

%==========================================================================
%Bepaal de data voor de geldige periode
%==========================================================================

bedatum     = datenum(bej,bem,bed,beu,0,0);
eidatum     = datenum(eij,eim,eid,eiu,0,0);

selectie    = find(datum >= bedatum & datum <= eidatum);
jaar        = jaar(selectie);
maand       = maand(selectie);
dag         = dag(selectie);
uur         = uur(selectie);
r           = r(selectie);
u           = u(selectie);
datum       = datenum(jaar,maand,dag,uur,0,0);

