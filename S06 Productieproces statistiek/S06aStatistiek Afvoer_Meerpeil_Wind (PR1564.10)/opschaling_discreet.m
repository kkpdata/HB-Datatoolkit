function [golven_aanpas, standaardvorm, tvoor, tachter] = opschaling_discreet(...
    golven,ref_niv,nstapv,fig_golven_rel,fig_opschaling);
%
% Door Chris Geerse
% De opschalingsmethode wordt in dit programma iets anders uitgevoerd dan
% met de functie 'opschaling'. Nu vindt geen piek/dal verbreding plaats. Er
% wordt simpelweg geturfd hoeveel uren boven een niveau v uitkomen (antwoord is
% steeds geheel aantal). Dit kan worden gezien als een andere aanpak om een
% continuïteitscorrectie uit te voeren.
%
%
%==========================================================================
%
%Input:
%golven: structure berekend door functie golfselectie.m met geselecteerde golven
%referentieniveau van waaraf wordt opgeschaald
%nstapv is aantal deelintervallen verticale discretisatie;
%   interval [0,1] wordt opgevuld met nstapv deelintervallen
%fig_golven_rel: indien 1 wel plaatje relatieve golven, indien 0 dan niet
%fig_opschaling: indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet
%
%Output:
%golven_aanpas is een structure met de aangepaste golven;
%   velden: v, tvoor, tachter
%standaardvorm is een structure met de standaardvormgegevens (gemiddelde
%   van aangepaste golven);
%   velden: v, tvoor, tachter, fv (duur op niveau v)
%tvoor is matrix met 1e kolom v, volgende kolommen geven bijbehorende
%tijdstippen waarop de voorflanken van de aangepaste golven beginnen
%(aantal kolommen = 1 + aantal golven.
%tachter is matrix met 1e kolom v, volgende kolommen geven bijbehorende
%tijdstippen waarop de achterflanken van de aangepaste golven eindigen
%(aantal kolommen = 1 + aantal golven.
%
%Calls:
%geen


%Golven moeten moeten op equidistant tijdrooster zijn gegeven, met
%piek in t = 0. (Denk ik)

%{
%==========================================================================
%Oude invoer tbv testen.
%==========================================================================

close all;
clear;
drempel = 800;        % variabele voor drempel waarde
zpot = 15;            % zichtduur voor selectie pieken
zB = 15;              %halve breedte van geselecteerde tijdreeks (default=zpot). NB zB>zpot
%kan soms crash geven bij aanpassing van golven tbv
%opschaling. Default zB = zpot.
ref_niv = 400;       %referentieniveau van waaraf wordt opgeschaald
basis_niv = 0;     %hoogte waarop trapezium begint (meestal gelijk aan ref_niv).
nstapv = 10;      %interval [0,1] wordt opgevuld met nstapv deelintervallen
fig_golven_verbreed = 0; %indien 1 wel plaatjes verbrede golven, indien 0 dan niet
fig_golven_rel = 0;      %indien 1 wel plaatje relatieve golven, indien 0 dan niet
fig_opschaling = 1;      %indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet
%parameters trapezia
B = 30;             %basisduur trapezia

%==========================================================================
% inlezen van de data welke aangeleverd moet zijn in het voorgeschreven
% format
%==========================================================================
[datuminlees,mp,qlob,qolst] = textread('Statistieken Geerse IJsm_Lob_Olst.txt','%f %f %f %f','delimiter',' ','commentstyle','matlab');

jaar = floor(datuminlees/10000);
maand = floor((datuminlees-jaar*10000)/100);
dag = floor(datuminlees-jaar*10000-maand*100);
datum = datenum(jaar,maand,dag);        %seriële datum

data = qolst;      %data gelijk maken aan afvoer Olst
%clear mp qlob qolst;

%geef hier de gewenste selectie aan:
bej = 1981;
bem = 1;
bed = 1;
eij = 2005;
eim = 3;
eid = 31;
bedatum = datenum(bej,bem,bed);
eidatum = datenum(eij,eim,eid);
selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 |...
    maand == 2 | maand == 3)&(datum >= bedatum & datum <= eidatum));

jaar        = jaar(selectie);
maand       = maand(selectie);
dag         = dag(selectie);
data        = data(selectie);
mp          = mp(selectie);
%qolst       = qolst(selectie);
datum       = datenum(jaar,maand,dag);
dagnr       = (1:numel(data))';


%==========================================================================
% Tbv goede plaatjes in Word.
figformat = 'doc';
[ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)
close all

[golfkenmerken, golven] = golfselectie(drempel,zpot,zB,jaar,maand,dag,data);
%golfkenmerken: matrix met gegevens van de golven
%golven =
%1xNgolven struct array with fields:
%    nr
%    jaa
%    mnd
%    dag
%    piek
%    rang
%    tijd
%    data

%}

%==========================================================================
%Begin van de eigenlijke functie
%==========================================================================

golven_aanpas = []; %init
standaardvorm = []; %init
tvoor = []; %init
tachter = []; %init
Ngolven = max([golven.rang]);

%checken of sprake is van geldige golven voor opschalingsprocedure
geldig = 1; %init; geldig = 1 als alle golven geldig zijn, en 0 indien er niet-geldige golven zijn.
for i = 1:Ngolven
    if max([golven(i).data]) > golven(i).piek
        geldig = 0;
        display('FOUT: Nevenpiek is hoger dan de centrale piek.');
        display(['Betreft o.a. piek ',num2str(golven(i).jaa)...
            ,'-',num2str(golven(i).mnd),'-',num2str(golven(i).dag)]);
    end
end
if geldig == 0
    display('Opschaling kan niet worden uitgevoerd!!');
end

%Volgende betreft de geldige golven.
if geldig ==1;
    %grootheden voor piekwaarden, lengte vectoren is aantal golven
    %initialisaties
    jaarp = zeros(Ngolven,1);
    maandp = zeros(Ngolven,1);
    dagp = zeros(Ngolven,1);

    for i = 1:Ngolven
        jaarp(i) = golven(i).jaa;
        maandp(i) = golven(i).mnd;
        dagp(i) = golven(i).dag;
    end

    %==========================================================================
    %interval [0,1] opvullen met nstapv deelintervallen met lengte stapv
    v = linspace(0,1,nstapv+1)';
    stapv = 1/(nstapv);

    tijdas = [golven(1).tijd(1):golven(1).tijd(end)]';    %NB golven moeten allemaal zelfde tijdstappen hebben
    z = (numel(tijdas)-1)/2;
    duurv = zeros(length(v),Ngolven); %init matrix met duurgegevens voorflank van alle golven
    duura = zeros(length(v),Ngolven); %init matrix met duurgegevens achterflank van alle golven

    for i = 1:Ngolven;
        DG = golven(i).data - ref_niv;   %data binnen actuele golf tov referentieniveau, vector 1dim
        ind = find(DG < 0);
        DG(ind) = 0;     %negatieve waarden verhogen naar 0

        for j = 1:length(v)
            %duren op niveau v(j); het topuur wordt 0.5/0.5 verdeeld over voor
            %en achterflank
            duurv(j,i) = numel(find(DG(1:z) >= v(j)*(golven(i).piek-ref_niv))) + 0.5;  %duur in voorflank (ecxlusief t = 0)
            duura(j,i) = numel(find(DG(z+2:2*z+1) >= v(j)*(golven(i).piek-ref_niv))) + 0.5;  %duur in achterflank (ecxlusief t = 0)
        end
    end
end

%Voor lage niveaus wordt de duur mogelijk z+0.5; breng deze terug naar z.
F1 = find(duurv > z);
duurv(F1) = z;
F2 = find(duura > z);
duura(F2) = z;

%==========================================================================
%Per niveau v voor elke golf de duur in de voorflank en de duur in de
%achterflank bepalen als tijdstip.

tvoor = [v, -duurv];    %NB duur_stap is een complete matrix (geen vector 1dim)
tachter = [v, duura];

%==========================================================================
%Vullen van structure 'golven_aanpas' met allerlei velden:
%==========================================================================

for i = 1:Ngolven
golven_aanpas(i).nr = golven(i).nr;
golven_aanpas(i).jaa = golven(i).jaa;
golven_aanpas(i).mnd = golven(i).mnd;
golven_aanpas(i).dag = golven(i).dag;
golven_aanpas(i).piek = golven(i).piek;
golven_aanpas(i).rang = golven(i).rang;
golven_aanpas(i).tijd = [tvoor(:,i+1); flipud(tachter(:,i+1))];   %tijdsverloop ongenormeerde golven
golven_aanpas(i).data = [v; flipud(v)]*(golven(i).piek - ref_niv) + ref_niv;  %data corresponderend met tijdsverloop
end

%==========================================================================
%PLAATJES met aangepaste golven
%==========================================================================
%Tijdsverlopen 'monotone' genormeerde golven in één plaatje
%close all;
if fig_golven_rel == 1
figure;
for i = 1:Ngolven
plot(golven_aanpas(i).tijd, (golven_aanpas(i).data-ref_niv)/(max([golven_aanpas(i).data])-ref_niv), 'b');
grid on;
hold on;
xlim([tijdas(1) tijdas(end)]);
ylim([0 1]);
xlabel('tijd, dagen');
ylabel('relatieve hoogte, [-]');
end
elseif  fig_golven_rel == 0
end


%==========================================================================
% Bepalen gemiddelde vorm (opschalingsmethode)
%==========================================================================

standaardvorm.v = v;
standaardvorm.tvoor = mean(tvoor(:,2:Ngolven+1),2);  %mean(A,2) geeft gemiddelde per rij uit matrix A
standaardvorm.tachter = mean(tachter(:,2:Ngolven+1),2);
standaardvorm.fv = standaardvorm.tachter - standaardvorm.tvoor;

%Tijdsverloop opgeschaalde golf in plaatje
%close all;
if fig_opschaling == 1
figure;
plot(standaardvorm.tvoor,v,'b',standaardvorm.tachter,v,'b');
grid on
xlabel('tijd, dagen');
ylabel('relatieve hoogte, [-]');
title('standaardgolf uit opschaling (discrete versie)');
elseif  fig_opschaling == 0
end
display('Procedure ''opschaling'' is gerund');

%{
%==========================================================================
% Plotten van standaardvorm en trapezium.
%==========================================================================
close all

Ngolven = max([golven.nr]);
v = standaardvorm.v;
figure
plot(standaardvorm.tvoor,v,'b',standaardvorm.tachter,v,'b');
hold on
grid on

%Toevoegen trapezium aan plot.
bpiek = 1;  %topduur trapezium wordt hier tbv plaatje ingesteld.
x = [-B/2, -bpiek/2, bpiek/2, B/2]';
y = [0, 1, 1, 0]';
plot(x,y,'r');

ltxt  = [];
ttxt  = 'Gemiddelde golf Olst met trapezium';
xtxt  = 'tijd, dagen';
ytxt  = 'relatieve afvoer, [-]';
Xtick = -15:5:15;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%}


