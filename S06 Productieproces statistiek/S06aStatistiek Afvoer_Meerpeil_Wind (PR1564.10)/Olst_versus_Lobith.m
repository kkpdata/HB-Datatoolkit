%Dient nog van commentaar voorzien.


infile = 'Statistieken Geerse IJsm_Lob_Olst.txt';
[datuminlees,mp,qlob,qolst] = textread(infile,'%f %f %f %f','delimiter',' ','commentstyle','matlab');

%==========================================================================
%Berekening van Olst via lags Lobith.
%==========================================================================
%Berekening qloblags, zijnde gemiddelde van lags Lobith van 1 en 2 dagen
%eerder. qloblags heeft dezelfde lengte als de vectoren
%datuminlees, mp, qlob en qolst
qloblag1 = circshift(qlob,1);
qloblag1(1) = -999;
qloblag2 = circshift(qlob,2);
qloblag2(1:2) = -999;
qloblags = (circshift(qlob,1)+circshift(qlob,2))/2;   %gemiddelde van lags Lobith
qloblags(1:2) = qlob(1:2);   %eerste twee lags zijn niet te berekenen,
%vandaar dat qloblags dan gelijk wordt genomen aan de originele Lobith waarden.

jaar = floor(datuminlees/10000);
maand = floor((datuminlees-jaar*10000)/100);
dag = floor(datuminlees-jaar*10000-maand*100);
datum = datenum(jaar,maand,dag);        %seriële datum

%Geef hier aan welk (aansluitend) deel Olst uit Lobith moet worden berekend.
bejOL = 1901; bemOL = 1; bedOL = 1;
eijOL = 1980; eimOL = 12; eidOL = 31;
bedatumOL = datenum(bejOL,bemOL,bedOL);
eidatumOL = datenum(eijOL,eimOL,eidOL);
FOL = find(datum >= bedatumOL & datum <= eidatumOL);
%Lineair verband Olst uit lags Lobith: qolst = A*qloblags + B
A = 0.16;
B = 0.0;
qolst(FOL) = A*qloblags(FOL) + B; %Hier is qolst deels vervangen door uit Lobith berekende waarden

data = qolst;      %data gelijk maken aan afvoer Olst
%clear mp qlob qolst;

%==========================================================================
%geef hier de gewenste selectie voor de analyses aan:
bej = 1960;
bem = 1;
bed = 1;
eij = 2005;
eim = 3;
eid = 31;
bedatum = datenum(bej,bem,bed);
eidatum = datenum(eij,eim,eid);
selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 |...
    maand == 2 | maand == 3)&(datum >= bedatum & datum <= eidatum));       


%==========================================================================
% Tbv goede plaatjes in Word.
 figformat = 'doc';
 [ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)
close all
 
%==========================================================================
%Berekenen van algemene (globaal te gebruiken) variabelen
%==========================================================================

jaar        = jaar(selectie);
maand       = maand(selectie);
dag         = dag(selectie);
data        = data(selectie);
mp          = mp(selectie);
qlob        = qlob(selectie);
qloblag1    = qloblag1(selectie);
qloblag2    = qloblag2(selectie);
qloblags    = qloblags(selectie);
qolst       = qolst(selectie);
datum       = datenum(jaar,maand,dag);
dagnr       = (1:numel(data))';

plot(datum,data,'.');
grid on
hold on
ltxt  = []
ttxt  = 'Afvoeren Olst';
xtxt  = 'tijd, jaren';
ytxt  = 'IJsselafvoer Olst, m3/s';
datetick('x',10)
%datetick('x','keeplimits')
%datetick('x','keepticks')
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%==========================================================================
%Plaatjes verband Lobith en Olst
%==========================================================================
figure
plot(qlob,qloblags,'.')
hold on
grid on
ttxt  = ['Lob versus gem. van lags Lobith'];
xtxt  = 'afvoer Lobith, m3/s';
ytxt  = 'gem lags Lobith, m3/s';
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


figure
plot(qlob,qolst,'.')
hold on
grid on
ttxt  = ['Olst versus Lobith'];
xtxt  = 'afvoer Lobith, m3/s';
ytxt  = 'afvoer Olst (evt. deels via lags Lob), m3/s';
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

qolstuitlob = A*qloblags;
figure
plot(qloblags,qolst,'.')
hold on
grid on
plot(qloblags,qolstuitlob,'r.')
ttxt  = ['Olst versus Lobith'];
xtxt  = 'afvoer Lobith 1.5 dag vooraf aan Olst, m3/s';
ytxt  = 'afvoer Olst via lags Lob, m3/s';
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%}