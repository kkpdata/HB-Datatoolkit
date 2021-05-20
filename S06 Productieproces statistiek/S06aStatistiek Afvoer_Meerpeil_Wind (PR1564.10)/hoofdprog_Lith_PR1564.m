%==========================================================================
% Hoofdprogramma Lith
% Door: Chris Geerse

% Bepalen van trapeziumparameters voor PR1564.10 voor Lobith.
% Uitgevoerd in het kader van vergelijkingen Hydra-B met Hydra-Zoet.
% Afvoergegevens volgens HR2006.

% Opmerking 1:
% De opschalingsmethode, aan de hand van metingen, maakt ook deel uit van
% de code, maar is strikt genomen niet nodig voor PR1564.10.

% Opmerking 2:
% Werklijn is afgeleid op basis van gehomogeniseerde piekwaarden. Deze zijn volgens
% RIZA-werkdoc 2001.121x Bijlage C2 naar schatting circa 80 m3/s hoger dan niet
% gehomogeniseerde pieken.

%==========================================================================
clear
close all
%==========================================================================
% Uitvoer wegschrijven in
padnaam_uit = 'D:\Users\geerse\Matlab\Stat_Rivieren_Meren_Wind\'


%==========================================================================
%==========================================================================
%Invoerparameters
%==========================================================================
%Parameters voor selectie golven en opschaling
%==========================================================================
drempel = 1400;        % variabele voor drempel waarde
zpot = 15;            % zichtduur voor selectie pieken
zB = zpot;              %halve breedte van geselecteerde tijdreeks (default=zpot). NB zB>zpot
%kan soms crash geven bij aanpassing van golven tbv
%opschaling. Default zB = zpot.

homogenisatieWaarde = 0;   %waarde om hogere piekafvoeren te verlagen om pragmatisch effect homogenisatie te beoordelen.
ref_niv = 0;       %referentieniveau van waaraf wordt opgeschaald
basis_niv = 0;     %hoogte waarop trapezium begint (meestal gelijk aan ref_niv).
piekduur = 0.9999; %duur waarmee pieken/dalen worden verbreed, 0< piekduur <1; default 0.9999.
nstapv = 100;      %interval [0,1] wordt opgevuld met nstapv deelintervallen
fig_golven_verbreed = 0; %indien 1 wel plaatjes verbrede golven, indien 0 dan niet
fig_golven_rel = 0;      %indien 1 wel plaatje relatieve golven, indien 0 dan niet
fig_opschaling = 0;      %indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet

%parameters trapezia
B = 30;             %basisduur trapezia

%keuze topduur
topduur_inv = ...
    [0,     720;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
    1315.1, 12;
    6000,   12]


%parameters afvoer
%Oude keuze
ovkanspiek_inv = ...
  [  0.0     1.0000
     75      0.995
%     100      0.97
     200      0.88
     300      0.76
     500      0.55
   1315.1     1.6667E-01
   3652.0     1.3333E-04];    

stapy = 5;      %stapgrootte voor kansvectoren (y is bijv piekafvoer of afvoerniveau)
ymax = 5000;        %maximum van vector

%pragmatisch herberekenen om homogenisatie te simuleren
ovkanspiek_inv(2:3,1) =ovkanspiek_inv(2:3,1) - homogenisatieWaarde;

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
%Inlezen van Hydra-B momentane overschrijdingskans HR2006 (bijlage D2 uit
%[Kalk et al, 2001]. afkomstig uit PR379) en van overschrijdingsfrequentie.
%==========================================================================

%m3/s, overschrijdingskans
[q_HB, qmom_HB] = textread('ov_qdag_lith_HR2006.txt','%f %f','delimiter',' ','commentstyle','matlab');

[k_HB, kovfreq_HB] = textread('ov_freq_lith_volledig_HR2006.txt','%f %f','delimiter',' ','commentstyle','matlab');

%==========================================================================
%Inlezen maatgevende afvoergolf HR2006.
%==========================================================================

[t_MAgolf, q_MAgolf] = textread('MAgolf_Lith_HR2006.txt','%f %f','delimiter',' ','commentstyle','matlab');


%==========================================================================
%Inlezen data
%==========================================================================
[datuminlees,qlith] = textread('Dagafvoer Lith, 13-10-1999 (decim afgekapt) excl uurtijdstip.txt','%f %f','delimiter',' ','commentstyle','matlab');

[jaar,maand,dag,datum] = datumconversiejjjjmmdd(datuminlees);

data = qlith;      %data gelijk maken aan afvoer Lith

%Enkele hiaatwaarden (999999999) pragmatisch aanpassen
data(30203:30206)   = 50;
data(31964)         = 100;


%==========================================================================
%geef hier de gewenste selectie voor de analyses aan:
%==========================================================================
bej = 1911;
bem = 1;
bed = 1;
eij = 1999;
eim = 6;
eid = 30;

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
dagnr       = (1:numel(data))';

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
plot_Lithgolven(golven, basis_niv, B, topduur_inv);

% ==========================================================================
% Plotten van standaardvorm en trapezium.
% ==========================================================================

%close all

aantal_golven = max([golven.nr]);
v = standaardvorm.v;
figure
plot(standaardvorm.tvoor,v,'b',standaardvorm.tachter,v,'b');
hold on
grid on

%Toevoegen trapezium aan plot.
%bpiek = 1;  %topduur trapezium wordt hier tbv plaatje ingesteld.
bpiek = min(topduur_inv(:,2))/24;
x = [-B/2, -bpiek/2, bpiek/2, B/2]';
y = [0, 1, 1, 0]';
plot(x,y,'r');

ltxt  = [];
ttxt  = 'Gemiddelde golf Lith met trapezium';
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
ttxt  = 'Gemeten golven Lith';
xtxt  = 'tijd, dagen';
ytxt  = 'Maasafvoer Lith, m3/s';
Xtick = -15:5:15;
Ytick = 0:500:3000;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

figure
for i = 1:aantal_golven
    plot(golven_aanpas(i).tijd, golven_aanpas(i).data,'b-')
    hold on
    grid on
end
ltxt  = [];
ttxt  = 'Aangepaste golven Lith';
xtxt  = 'tijd, dagen';
ytxt  = 'Maasafvoer Lith, m3/s';
Xtick = -15:5:15;
Ytick = 0:500:3000;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%nu golven op 1 genormeerd
figure
for i = 1:aantal_golven
    plot(golven_aanpas(i).tijd, golven_aanpas(i).data./max(golven_aanpas(i).data),'b-')
    hold on
    grid on
end
ltxt  = [];
ttxt  = 'Aangepaste golven Lith na normering op 1';
xtxt  = 'tijd, dagen';
ytxt  = 'relatieve afvoer Lith, [-]';
Xtick = -15:5:15;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

 
%==========================================================================
% Momentane ov.kans volgens berekening met trapezia
%==========================================================================
[berek_trap] = grootheden_trap(stapy, ymax, basis_niv, B, topduur_inv, ovkanspiek_inv);
%         y: [13x1 double]
%         by: [13x1 double]
%    fy_piek: [13x1 double]
%    Gy_piek: [13x1 double]
%     fy_mom: [13x1 double]
%     Gy_mom: [13x1 double]

%[berek_trap.y,berek_trap.by, berek_trap.fy_piek, ...
%    berek_trap.Gy_piek, berek_trap.fy_mom, berek_trap.Gy_mom]

%wegschrijven onderschrijdingskans Rijn tbv correlatiemodel
%onderschrijdkans_Rijn = [berek_trap.y, 1-berek_trap.Gy_piek];
%save([padnaam_uit,'F_Rijn.txt'],'onderschrijdkans_Rijn','-ascii')


%Saven van momentane kansen naar een tabel
k_kolom = [75:25:5000]';   %Deze stapgroottes bij voorkeur niet veranderen
tabelmomkans = [k_kolom, interp1(berek_trap.y, berek_trap.Gy_mom, k_kolom)];
save([padnaam_uit,'momkans_Lith_berekend_met_stapy',num2str(stapy),'_ymax',num2str(ymax),'.txt'],'tabelmomkans','-ascii')

figure
plot(berek_trap.y,berek_trap.by, 'b')
grid on
hold on
ltxt  = []
ttxt  = 'Topduur trapezia Lith';
xtxt  = 'piekafvoer Lith, m3/s';
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

%==========================================================================
% Plotposities met werklijn
%==========================================================================
obs = golfkenmerken(:,5);   %piekwaarde
r = golfkenmerken(:,6);     %rang van piekwaarde
n = max(r);                 % aantal meegenomen extreme waarden
t_per = numel(data)/182; % aantal meetjaren, gebruikt in de formule voor de plotposities (werklijn)


%close all

labelHom = num2str(homogenisatieWaarde);

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
cltxt  = {['data, homog: ',labelHom,' m^3/s'],'overschrijdingsfrequentie'};
ltxt  = char(cltxt);
ttxt  = ['Gegevens werklijn Lith'];
xtxt  = 'terugkeertijd, jaar';
ytxt  = 'Maasafvoer Lith, m3/s';
Xtick = []
Ytick = 0:500:3000;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%==========================================================================
% Plaatjes momentane kansen volgens de metingen en volgens de integratie
%==========================================================================

figure
plot(mom_obs.y,mom_obs.Gy,'g-',berek_trap.y,berek_trap.Gy_mom,'b-.')
grid on
hold on
cltxt  = {['data, homog: ',labelHom,' m^3/s'],'integratie (trapezia)'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Lith';
xtxt  = 'Maasafvoer Lith, m3/s';
ytxt  = 'momentane overschrijdingskans, [-]';
Xtick = 0:500:3000;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


figure
plot(mom_obs.y,log(mom_obs.Gy),'g-',berek_trap.y,log(berek_trap.Gy_mom),'b-.')
grid on
hold off
cltxt  = {['data, homog: ',labelHom,' m^3/s'],'integratie (trapezia)'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Lith';
xtxt  = 'Maasafvoer Lith, m3/s';
ytxt  = 'ln momentane overschrijdingskans, [-]';
Xtick = 0:500:3000;
Ytick = -10:1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%gemiddelden
gem_data = mean(data)
gem_trap = sum(berek_trap.fy_mom.*berek_trap.y)*stapy

disp('gemiddelde van mom. ovkans Hydra-B HR2006')
gemiddelde_kolomvector_met_ovkans(q_HB, qmom_HB)


close all


%==========================================================================
% Plaatje ovfreq
%==========================================================================

figure
plot(ovkanspiek_inv(:,1),log(ovkanspiek_inv(:,2)),'r-')
grid on
hold on
plot(k_HB, log(kovfreq_HB/6),'k')
cltxt  = {'Hydra-Zoet','Hydra-B HR2006'};
ltxt  = char(cltxt);
ttxt  = 'Overschrijdingkans piekafvoer trapezium Lith';
xtxt  = 'Rijnafvoer Lith, m3/s';
ytxt  = 'ln overschrijdingskans, [-]';
Xtick = 0:1000:4000;
Ytick = -10:1:3;
legend('Location','SouthWestOutside')
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%==========================================================================
% Plaatjes momentane kansen volgens Hydra-B HR2006 en volgens de integratie
%==========================================================================


figure
plot(q_HB,qmom_HB,'g-',berek_trap.y,berek_trap.Gy_mom,'b-.')
grid on
hold on
cltxt  = {'Hydra-B HR2006','volgens P(K>k) en trapezia'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Lith';
xtxt  = 'Rijnafvoer Lith, m3/s';
ytxt  = 'momentane overschrijdingskans, [-]';
Xtick = 0:200:800;
Ytick = 0:0.1:1;
legend('Location','NorthEastOutside')
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


figure
plot(q_HB,log(qmom_HB),'g-',berek_trap.y,log(berek_trap.Gy_mom),'b-.')
grid on
hold off
cltxt  = {'Hydra-B HR2006','volgens P(K>k) en trapezia'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Lith';
xtxt  = 'Rijnafvoer Lith, m3/s';
ytxt  = 'ln momentane overschrijdingskans, [-]';
Xtick = 0:500:4000;
Ytick = -11:1:1;
legend('Location','NorthEastOutside')
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%==========================================================================
% Plaatje MA-golf met trapezium
%==========================================================================

MA              = 3650;
topduurMA       = interp1(topduur_inv(:,1),topduur_inv(:,2),MA);
fac_voorflank   = 0.5;
xx              = [-fac_voorflank*B, -0.5*topduurMA/24, 0.5*topduurMA/24, (1-fac_voorflank)*B]';
yy              = [basis_niv, MA, MA, basis_niv]';


figure
plot(t_MAgolf,MA/max(q_MAgolf)*q_MAgolf,'g-')
grid on
hold on
plot(xx,yy,'r')
cltxt  = {'Hydra-B HR2006 MA-golf','trapezium'};
ltxt  = char(cltxt);
ttxt  = 'Maatgevende afvoergolf Lith';
xtxt  = 'tijd, dagen';
ytxt  = 'afvoer, m^3/s';
%Xtick = [-20:5:30];
Xtick = [-10:5:10];
Ytick = [1750:250:3750];
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
