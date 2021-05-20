function [jaar,maand,dag,datum,qDalfsen] = inlezen_Dalfsen(invoerpad, infile_data);

% Door: Chris Geerse

%==========================================================================
% Inlezen waterstanddata
%==========================================================================

filenaam_data                = fullfile(invoerpad, infile_data);
[jaar, maand, dag, qDalfsen] = textread(filenaam_data,'%u %u %u %f','delimiter','','commentstyle','matlab');

datum                        = datenum(jaar,maand,dag); 

%==========================================================================
%geef hier de gewenste selectieperiode voor Vecht aan:
%==========================================================================
bej = 1960;
bem = 1;
bed = 1;
eij = 1983; %Vechtdata na 1983 zijn incompleet, met status onbetrouwbaar
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
qDalfsen    = qDalfsen(selectie);

