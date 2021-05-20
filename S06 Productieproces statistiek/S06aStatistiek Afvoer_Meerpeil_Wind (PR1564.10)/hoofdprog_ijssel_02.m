%==========================================================================
% Hoofdprogramma IJssel
% Door: Chris Geerse
%==========================================================================
clear
close all
%==========================================================================
% Uitvoer wegschrijven in
% padnaam_uit = '\\tsclient\D:\Users\geerse\Matlab\Stat_Rivieren_Meren_Wind\Uitvoer\'

padnaam_uit = '\\tsclient\D:\Users\geerse\Matlab\Stat_Rivieren_Meren_Wind\Uitvoer\';

clc;
% clear;
close all
addpath 'Hulproutines\' 'Invoer\' 'Uitvoer\' ;




%==========================================================================
%==========================================================================
%Invoerparameters
%==========================================================================
%Parameters voor selectie golven en opschaling
%==========================================================================
drempel = 800;        % variabele voor drempel waarde
zpot = 15;            % zichtduur voor selectie pieken
zB = 15;              %halve breedte van geselecteerde tijdreeks (default=zpot). NB zB>zpot
%kan soms crash geven bij aanpassing van golven tbv
%opschaling. Default zB = zpot.
ref_niv = 200;       %referentieniveau van waaraf wordt opgeschaald

basis_niv = 200;     %hoogte waarop trapezium begint (hoeft niet gelijk te zijn aan ref_niv). NB: in versie 1 ten onrechte 0 m3/s genomen

piekduur = 0.9999; %duur waarmee pieken/dalen worden verbreed, 0< piekduur <1; default 0.9999.
nstapv = 100;      %interval [0,1] wordt opgevuld met nstapv deelintervallen
fig_golven_verbreed = 0; %indien 1 wel plaatjes verbrede golven, indien 0 dan niet
fig_golven_rel = 0;      %indien 1 wel plaatje relatieve golven, indien 0 dan niet
fig_opschaling = 0;      %indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet
%parameters trapezia
B = 30;             %basisduur trapezia
topduur_inv = ...
    [basis_niv, 720;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
    800, 24;
    3000, 24]
%parameters afvoer
stapy = 5;      %stapgrootte voor kansvectoren (y is bijv piekafvoer of afvoerniveau)
ymax  = 6000;        %maximum van vector

ovkanspiek_inv = ...
    [basis_niv, 1;
    800, 0.16667;
    2720, 1.3333e-4];
%    3500, 7.3451e-6];    %laatste regel alleen tbv net plaatje werklijn
if (ovkanspiek_inv(1,1) ~= topduur_inv(1,1))
    display('FOUT: laagste waarde volgens topduur en ovkanspiek moet overeenstemmen!')
    display('Geef enter om door te gaan (dan met foute resultaten).')
    pause
end
c = 0.12;          % constante Gringorton in de formule voor de plotposities (werklijn)
d = 0.44;          % constante Gringorton in de formule voor de plotposities (werklijn)

%==========================================================================
% Tbv goede plaatjes in Word.
figformat = 'doc';
[ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)
close all

%==========================================================================
%Inlezen data
%==========================================================================
%[jaar,maand,dag,data] = textread('dagdebiet Olst 03jan60_23maa05.txt','%f %f %f %f','delimiter',' ','commentstyle','matlab');
%datum = datenum(jaar,maand,dag);        %seriële datum

%1. Hoogste piek in periode 1 jan 1981 t/m 23 maart 2005' valt op
%31 maart 1988, met q = 1907 m3/s. Deze wordt niet
%geselecteerd, omdat hij deels buiten het whj valt.
%
%2. Vervang periode 3 jan 1960 t/m 31 dec 1980 nog door andere waarden. Huidige
%omrekening uit lags Lobith door Vincent levert veel lagere waarden dan
%mijn oude keuze voor deze omrekening, die gebaseerd was op de DONAR data
%uit 1 jan 1981 t/m circa 2000. Nu dus een inhomogene dataset, wat niet
%netjes is om mee te werken.

[datuminlees,mp,qlob,qolst] = textread('Statistieken Geerse IJsm_Lob_Olst.txt','%f %f %f %f','delimiter',' ','commentstyle','matlab');

[jaar,maand,dag,datum] = datumconversiejjjjmmdd(datuminlees);

%data = qolst;      %data gelijk maken aan afvoer Olst
%clear mp qlob qolst;

% dagdebieten_Olst = [jaar, maand, dag, qolst];
% save([padnaam_uit,'dagdebieten_Olst_uit_Lobith_werkdoc036x.txt'],'dagdebieten_Olst','-ascii')
% save(['dagdebieten_Olst_uit_Lobith_werkdoc036x.txt'],'dagdebieten_Olst','-ascii');





%==========================================================================
%Bepalen Olst uit Lobith voor op te geven tijdvak
%==========================================================================

qloblag1 = circshift(qlob,1);
qloblag1(1) = -999;
qloblag2 = circshift(qlob,2);
qloblag2(1:2) = -999;
qloblag3 = circshift(qlob,3);   %alleen om een plaatje voor het rapport mee te maken
qloblag2(1:3) = -999;
qloblags = (circshift(qlob,1)+circshift(qlob,2))/2;   %gemiddelde van lags Lobith van 1 en 2 dagen eerder
qloblags(1:2) = qlob(1:2);   %eerste twee lags zijn niet te berekenen,
%vandaar dat qloblags dan gelijk wordt genomen aan de originele Lobith waarden.
%Op dit punt is qloblags berekend, met dezelfde lengte als de vectoren
%datuminlees, mp, qlob en qolst

%Geef hier aan welk (aansluitend) deel Olst uit Lobith moet worden berekend.
bejOL = 1901; bemOL = 1; bedOL = 1;
eijOL = 1980; eimOL = 12; eidOL = 31;
bedatumOL = datenum(bejOL,bemOL,bedOL);
eidatumOL = datenum(eijOL,eimOL,eidOL);
FOL = find(datum >= bedatumOL & datum <= eidatumOL);
%Lineair verband Olst uit lags Lobith: qolst = A*qloblags + B
A1 = 0.16;
B1 = 0.0;
qolst(FOL) = A1*qloblags(FOL) + B1; %Hier is qolst deels vervangen door uit Lobith berekende waarden
qolstuitlob = A1*qloblags + B1;    %tbv testen ook deze variabele berekenen

data = qolst;      %data gelijk maken aan afvoer Olst
%clear mp qlob qolst qloblag1 qloblag2 qloblags;


%==========================================================================
%Inlezen WAQUA golven HR 2006 (met Waqua doorgerekend van Lobith
%naar Olst). Bovenste rij bevat de terugkeertijden.
%==========================================================================

waq_inv = load('-ascii', 'golven Olst Stolken_HR2006.txt');
s = size(waq_inv);
Nwaq = s(1,2)-1;    %aantal WAQUA golven
Lwaq = s(1,1)-1;    %lengte golven (aantal tijdstappen)

%Structure waq vullen met golfgegevens
treeks = waq_inv(2:Lwaq+1,1);               %tijdreeks uit invoer (zelfde voor alle golven)
for i = 1:Nwaq
    waq(i).ttijd = waq_inv(1,i+1);          %terugkeertijd golven
    waq(i).data  = waq_inv(2:Lwaq+1,i+1);   %afvoerreeks in m3/s
    [mx, tmx] = max(waq(i).data);
    waq(i).tijd  = waq_inv(2:Lwaq+1,1)-treeks(tmx);     %tijdreeks golven in dagen, met piek bij t = 0.
    waq(i).piek  = max(waq(i).data);        %maximum in m3/s
end

%==========================================================================
%geef hier de gewenste selectie voor de analyses aan:
%==========================================================================
bej = 1981; %      1981;
bem = 1;
bed = 1;
eij = 2005;
eim = 3;
eid = 31;

bedatum = datenum(bej,bem,bed);
eidatum = datenum(eij,eim,eid);
selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 |...
    maand == 2 | maand == 3)&(datum >= bedatum & datum <= eidatum));


% selectie = find(datum >= bedatum & datum <= eidatum);

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
qloblag3    = qloblag3(selectie);
qloblags    = qloblags(selectie);
qolstuitlob = qolstuitlob(selectie);
qolst       = qolst(selectie);
datum       = datenum(jaar,maand,dag);
dagnr       = (1:numel(data))';

%==========================================================================
%Saven data Lobith en Olst en plaatjes data en Olst versus Lobith
%==========================================================================

%Saven databestand tbv Sabine
%dagdebieten_Lobith_Olst = [jaar, maand, dag, qlob, qolst];
%save([padnaam_uit,'dagdebieten_Lobith_Olst_1jan1901_31maa2005.txt'],'dagdebieten_Lobith_Olst','-ascii')

% figure
% plot(qlob,qolst,'.')
% hold on
% grid on
% ttxt  = ['Olst versus Lobith'];
% xtxt  = 'afvoer Lobith, m3/s';
% ytxt  = 'afvoer Olst, m3/s';
% fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% 
% figure
% plot(qloblags,qolst,'.')
% hold on
% grid on
% plot(qloblags,qolstuitlob,'r-')
% ttxt  = ['Olst versus Lobith'];
% xtxt  = 'afvoer Lobith 1.5 dag vooraf aan Olst, m3/s';
% ytxt  = 'afvoer Olst, m3/s';
% fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% 
% figure
% plot(qloblag1,qolst,'.')
% hold on
% grid on
% ttxt  = ['Olst versus Lobith'];
% xtxt  = 'afvoer Lobith 1 dag vooraf aan Olst, m3/s';
% ytxt  = 'afvoer Olst, m3/s';
% fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% 
% figure
% plot(qloblag2,qolst,'.')
% hold on
% grid on
% ttxt  = ['Olst versus Lobith'];
% xtxt  = 'afvoer Lobith 2 dagen vooraf aan Olst, m3/s';
% ytxt  = 'afvoer Olst, m3/s';
% fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% 
% figure
% plot(qloblag3,qolst,'.')
% hold on
% grid on
% ttxt  = ['Olst versus Lobith'];
% xtxt  = 'afvoer Lobith 3 dagen vooraf aan Olst, m3/s';
% ytxt  = 'afvoer Olst, m3/s';
% fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

figure
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
%

%==========================================================================
%Aanpassen van golven: piek/dal-verbreding en monotone voor- en
%achterflanken maken door nevenpieken tegen hoofdpiek te plakken.
%Resultaat: aangepaste golven (stijgende voor- en dalende achterflank) en (gemiddelde)
%standaard(norm)golfgegevens.

[golven_aanpas, standaardvorm] = opschaling(...
    golven,ref_niv,piekduur,nstapv,fig_golven_verbreed,fig_golven_rel,fig_opschaling);

%close all
%Discrete versie opschalingsmethode
%[golven_aanpas, standaardvorm] = opschaling_discreet(...
%    golven,ref_niv,nstapv,fig_golven_rel,fig_opschaling);


%golven_aanpas =
%1*aantal_golven struct array with fields:
%    nr
%    jaa
%    mnd
%    dag
%    piek
%    rang
%    tijd
%    data

%standaardvorm =
%          v: [11x1 double]
%      tvoor: [11x1 double]
%    tachter: [11x1 double]
%         fv: [11x1 double]

%[standaardvorm.v standaardvorm.tvoor standaardvorm.tachter standaardvorm.fv]

%==========================================================================
% Plotten van geselecteerde golven en trapezium.
%==========================================================================
% plot_IJsselgolven(golven, basis_niv, B, topduur_inv);


%==========================================================================
% Plotten van standaardvorm en trapezium.
%==========================================================================

%close all

aantal_golven = max([golven.nr]);
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



%==========================================================================
% Diverse plaatjes golven
%==========================================================================
%close all
figure
for i = 1:aantal_golven
    plot(golven(i).tijd, golven(i).data,'b-')
    hold on
    grid on
end
ltxt  = [];
ttxt  = 'Gemeten golven Olst';
xtxt  = 'tijd, dagen';
ytxt  = 'IJsselafvoer Olst, m3/s';
Xtick = -15:5:15;
Ytick = 0:250:2000;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

figure
for i = 1:aantal_golven
    plot(golven_aanpas(i).tijd, golven_aanpas(i).data,'b-')
    hold on
    grid on
end
ltxt  = [];
ttxt  = 'Aangepaste golven Olst';
xtxt  = 'tijd, dagen';
ytxt  = 'IJsselafvoer Olst, m3/s';
Xtick = -15:5:15;
Ytick = 0:250:2000;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%nu golven op 1 genormeerd
figure
for i = 1:aantal_golven
    plot(golven_aanpas(i).tijd, golven_aanpas(i).data./max(golven_aanpas(i).data),'b-')
    hold on
    grid on
end
ltxt  = [];
ttxt  = 'Aangepaste golven Olst na normering op 1';
xtxt  = 'tijd, dagen';
ytxt  = 'relatieve afvoer Olst, [-]';
Xtick = -15:5:15;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)



%==========================================================================
% Plotten van golven HR 2006 en trapezia.
%==========================================================================

Ntraject = numel(topduur_inv(:,1));

%close all
figure
for n = 1:Nwaq
    plot(waq(n).tijd, waq(n).data);
    hold on
    grid on

    %toevoegen trapezia
    piek = waq(n).piek;
    b = btop(topduur_inv, piek);
    x = [-B/2, -b/(2*24), b/(2*24), B/2]';
    y = [ref_niv, piek, piek, ref_niv]';
    plot(x,y,'r')
end
ttxt  = 'Waquagolven en trapezia Olst';
xtxt  = 'tijd, dagen';
ytxt  = 'IJsselafvoer Olst, m3/s';
Xtick = -B/2-1:2:B/2+1;
Ytick = [];
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)



%==========================================================================
% Momentane ov.kans volgens berekening met trapezia
%==========================================================================
%[berek_trap] = grootheden_kniktrap(stapy, ymax, basis_niv, B, av, ah, topduur_inv, ovkanspiek_inv)

[berek_trap] = grootheden_trap(stapy, ymax, basis_niv, B, topduur_inv, ovkanspiek_inv);
%         y: [13x1 double]
%         by: [13x1 double]
%    fy_piek: [13x1 double]
%    Gy_piek: [13x1 double]
%     fy_mom: [13x1 double]
%     Gy_mom: [13x1 double]

%[berek_trap.y,berek_trap.by, berek_trap.fy_piek, ...
%    berek_trap.Gy_piek, berek_trap.fy_mom, berek_trap.Gy_mom]

%wegschrijven onderschrijdingskans IJssel tbv correlatiemodel
%onderschrijdkans_IJssel = [berek_trap.y, 1-berek_trap.Gy_piek];
%save([padnaam_uit,'F_IJssel.txt'],'onderschrijdkans_IJssel','-ascii')


% %Saven van momentane kansen naar een tabel
% k_kolom = [0:25:4000]';   %Deze stapgroottes bij voorkeur niet veranderen
% tabelmomkans = [k_kolom, interp1(berek_trap.y, berek_trap.Gy_mom, k_kolom)];
% save([padnaam_uit,'momkans_Olst_berekend_met_stapy',num2str(stapy),'_ymax',num2str(ymax),'.txt'],'tabelmomkans','-ascii')


%close all
figure
plot(berek_trap.y,berek_trap.by, 'b')
grid on
hold on
ltxt  = []
ttxt  = 'Topduur trapezia Olst';
xtxt  = 'piekafvoer Olst, m3/s';
ytxt  = 'topduur, uur';
Xtick = 0:500:3000;
Ytick = 0:100:800;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)



%==========================================================================
% Momentane ov.kans volgens de metingen (observaties)
%==========================================================================
yturf = [(0: stapy : ovkanspiek_inv(1,1))'; berek_trap.y];
[mom_obs] = turven_metingen(yturf, data);
%mom_obs =
%     y: [13x1 double]       %vector met afvoerniveaus (= berek_trap.y)
%    Gy: [13x1 double]       %momentane ov.kansen
%    fy: [13x1 double]       %momentane kansdichtheid

%[mom_obs.y mom_obs.Gy mom_obs.fy ]



%==========================================================================
% Plotposities met werklijn
%==========================================================================
obs = golfkenmerken(:,5);   %piekwaarde
r = golfkenmerken(:,6);     %rang van piekwaarde
n = max(r);                 % aantal meegenomen extreme waarden
t_per = numel(data)/182; % aantal meetjaren, gebruikt in de formule voor de plotposities (werklijn)



figure
plotpos = zeros(n,1);      %initialisatie
for i = 1:n
    plotpos(i) = ((n+c)*t_per)/((r(i)+c+d-1)*n);
end
p1 = semilogx(plotpos,obs,'r*');
hold on
grid on

%toevoegen wlijn: k1 = piekafvoer, k2 = T
wlijn = [ovkanspiek_inv(:,1), 1./(6*ovkanspiek_inv(:,2))];
plot(wlijn(:,2),wlijn(:,1)),'b';

%toevoegen Waqua 2006 golven uit spreadsheet [Stolken, 2005].
%piekafvoer en terugkeertijd WAQUA golven HR 2006:
waq2006(:,1) = max([waq.data])';
waq2006(:,2) = [waq.ttijd]';
plot(waq2006(:,2),waq2006(:,1),'ko');
cltxt  = {'data','overschrijdingsfrequentie','Waquagolven'};
ltxt  = char(cltxt);
ttxt  = ['Gegevens werklijn Olst'];
xtxt  = 'terugkeertijd, jaar';
ytxt  = 'IJsselafvoer Olst, m3/s';
Xtick = []
Ytick = 0:500:4000;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


close all

%==========================================================================
% Plaatjes momentane kansen volgens de metingen en volgens de integratie
%==========================================================================

figure
plot(mom_obs.y,mom_obs.Gy,'g-',berek_trap.y,berek_trap.Gy_mom,'b-.')
grid on
hold on
cltxt  = {'observatie','integratie (trapezia)'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Olst';
xtxt  = 'IJsselafvoer Olst, m3/s';
ytxt  = 'momentane overschrijdingskans, [-]';
Xtick = 0:250:2500;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%close all
figure
plot(mom_obs.y,log(mom_obs.Gy),'g-',berek_trap.y,log(berek_trap.Gy_mom),'b-.')
grid on
hold off
cltxt  = {'observatie','integratie (trapezia)'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Olst';
xtxt  = 'IJsselafvoer Olst, m3/s';
ytxt  = 'ln momentane overschrijdingskans, [-]';
Xtick = 0:250:2500;
Ytick = -10:1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%==========================================================================
% Plaatjes overschrijdingsduur per top
%==========================================================================

kGrid     = [berek_trap.y];

PovK      = exp( interp1(ovkanspiek_inv(:,1) ,log(ovkanspiek_inv(:,2)), kGrid, 'linear', 'extrap') );
PovQ      = [berek_trap.Gy_mom];
ovDuurTop = 30*PovQ./PovK;


figure%als check op de berekeningen!
% plot(mom_obs.y,log(mom_obs.Gy),'g-',berek_trap.y,log(berek_trap.Gy_mom),'b-.')
semilogy(mom_obs.y,mom_obs.Gy,'g-')
hold on
semilogy(kGrid, PovQ,'k')
grid on
cltxt  = {'observatie','integratie (trapezia)'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Olst';
xtxt  = 'IJsselafvoer Olst, m3/s';
ytxt  = 'Momentane overschrijdingskans, [-]';
Xtick = 0:250:2500;
% Ytick = -10:1:1;
Ytick = [];
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

% Figuur ovduur per top.
figure
plot(kGrid, ovDuurTop, 'b.')
grid on
xlabel('Afvoer, m^3/s')
ylabel('Overschrijdingsduur, dag')
xlim([1000, 3500])
ylim([0,10])
title('Overschrijdingsduur per top voor IJssel te Olst')



%gemiddelden
gem_data = mean(data)
gem_trap = sum(berek_trap.fy_mom.*berek_trap.y)*stapy
