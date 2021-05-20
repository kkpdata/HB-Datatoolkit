%==========================================================================
% Programma om pieken te selecteren (feitelijk een onderdeel uit een heel
% ander programma, vandaar dat het
% Door: Chris Geerse

%==========================================================================
clear
close all
%==========================================================================


%==========================================================================
%==========================================================================
%Invoerparameters
%==========================================================================
%Parameters voor selectie golven
%==========================================================================
drempel = 8000;        % variabele voor drempel waarde
zpot = 15;            % zichtduur voor selectie pieken
zB = 15;              %halve breedte van geselecteerde tijdreeks (default zB = zpot). 

%==========================================================================
%Inlezen data
%==========================================================================
[datuminlees,mp,qlob,qolst] = textread('Statistieken Geerse IJsm_Lob_Olst.txt','%f %f %f %f','delimiter',' ','commentstyle','matlab');

[jaar,maand,dag,datum] = datumconversiejjjjmmdd(datuminlees);

data = qlob;      %data gelijk maken aan afvoer Lobith

%==========================================================================
%geef hier de gewenste selectie voor de data-analyses aan:
%==========================================================================
bej = 1901;
bem = 1;
bed = 1;
eij = 2006;
eim = 3;
eid = 31;

bedatum = datenum(bej,bem,bed);
eidatum = datenum(eij,eim,eid);
selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 |...
    maand == 2 | maand == 3)&(datum >= bedatum & datum <= eidatum));
%selectie = find(datum >= bedatum & datum <= eidatum);

%==========================================================================
%Berekenen van algemene (globaal te gebruiken) variabelen
%==========================================================================

jaar        = jaar(selectie);
maand       = maand(selectie);
dag         = dag(selectie);
data        = data(selectie);
datum       = datenum(jaar,maand,dag);

%==========================================================================
%Selecteren van (niet aangepaste) golven uit datareeks
%==========================================================================
[golfkenmerken, golven] = golfselectie(drempel,zpot,zB,jaar,maand,dag,data);

%golfkenmerken: matrix met gegevens van de golven
%golven =
%1xaantal_golven struct array with fields:
%    nr
%    jaa
%    mnd
%    dag
%    piek
%    rang
%    tijd
%    data