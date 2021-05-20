%==========================================================================
% Hoofdprogramma Rijn
% Door: Chris Geerse
% Datum: 23 april 2009

% Bepalen van trapeziumparameters voor PR1564.10 voor Lobith.
% Uitgevoerd in het kader van vergelijkingen Hydra-B met Hydra-Zoet.
% Afvoergegevens volgens HR2006.

% Opmerking 1:
% De opschalingsmethode, aan de hand van metingen, maakt ook deel uit van
% de code, maar is strikt genomen niet nodig voor PR1564.10.

% Opmerking 2:
% Werklijn is afgeleid op basis van gehomogeniseerde piekwaarden. Deze zijn volgens
% RIZA-werkdoc 2001.121x Bijlage C2 circa 250 m3/s hoger dan niet
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
drempel = 8000;        % variabele voor drempel waarde
zpot = 15;            % zichtduur voor selectie pieken
zB = 15;              %halve breedte van geselecteerde tijdreeks (default=zpot). NB zB>zpot
%kan soms crash geven bij aanpassing van golven tbv
%opschaling. Default zB = zpot.
ref_niv = 750;       %referentieniveau van waaraf wordt opgeschaald

basis_niv = 750;     %hoogte waarop trapezium begint (meestal gelijk aan ref_niv).

piekduur = 0.9999; %duur waarmee pieken/dalen worden verbreed, 0< piekduur <1; default 0.9999.
nstapv = 100;      %interval [0,1] wordt opgevuld met nstapv deelintervallen
fig_golven_verbreed = 0; %indien 1 wel plaatjes verbrede golven, indien 0 dan niet
fig_golven_rel = 0;      %indien 1 wel plaatje relatieve golven, indien 0 dan niet
fig_opschaling = 0;      %indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet

%parameters trapezia
B = 30;             %basisduur trapezia (mag alleen 30 dagen zijn, anders soms foute resultaten)

% Oude keuze topduur afvoer
% topduur_inv = ...
%     [750, B*24;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
%     6000, 24;
%     30000, 24]

% Nieuwe keuze topduur afvoer (kies voor hoge afvoeren duur 12 uur)
topduur_inv = ...
    [750, B*24;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
    6000, 12;
    30000, 12]

%% Oude keuze ovkans piekafvoer
% ovkanspiek_inv = ...
%   [  750.0     1.0000
%    5893.3     1.6667E-01       %T = 1 jaar
%    7017.0     8.3333E-02       %T = 2 jaar
%   10850.0     6.6667E-03       %T = 25 jaar
%   16000.0     1.3333E-04];     %T = 1250 jaar

%Nieuwe keuze ovkans piekafvoer: geeft goede mom ovkans HR2006 in
%combinatie met nieuwe keuze topduur (vanaf 6000 m3/s dus 12 uur0
ovkanspiek_inv = ...
    [  750.0     1.0000
    1000       0.97
    1500       0.8
    3500      0.3
    4500      0.22
    5893.3     1.6667E-01       %T = 1 jaar
    7017.0     8.3333E-02       %T = 2 jaar
    10850.0     6.6667E-03       %T = 25 jaar
    16000.0     1.3333E-04];     %T = 1250 jaar

%    3500, 7.3451e-6];    %laatste regel alleen tbv net plaatje werklijn
if (ovkanspiek_inv(1,1) ~= topduur_inv(1,1))
    display('FOUT: laagste waarde volgens topduur en ovkanspiek moet overeenstemmen!')
    display('Geef enter om door te gaan (dan met foute resultaten).')
    pause
end

stapy = 25;      %stapgrootte voor kansvectoren (y is bijv piekafvoer of afvoerniveau)
ymax = 25000;        %maximum van vector

c = 0.12;          % constante Gringorton in de formule voor de plotposities (werklijn)
d = 0.44;          % constante Gringorton in de formule voor de plotposities (werklijn)

%==========================================================================
% Tbv goede plaatjes in Word.
figformat = 'doc';
[ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)
close

%==========================================================================
%Inlezen data
%==========================================================================
[datuminlees,mp,qlob,qolst] = textread('Statistieken Geerse IJsm_Lob_Olst.txt','%f %f %f %f','delimiter',' ','commentstyle','matlab');

[jaar,maand,dag,datum] = datumconversiejjjjmmdd(datuminlees);

data = qlob;      %data gelijk maken aan afvoer Lobith
%clear mp qlob qolst qloblag1 qloblag2 qloblags;

%==========================================================================
%Inlezen van Hydra-B momentane overschrijdingskans HR2006 (bijlage D2 uit
%[Kalk et al, 2001]. afkomstig uit PR379) en van overschrijdingsfrequentie.
%==========================================================================

%m3/s, overschrijdingskans
[q_HB, qmom_HB] = textread('ov_qdag_lobith_HR2006.txt','%f %f','delimiter',' ','commentstyle','matlab');

[k_HB, kovfreq_HB] = textread('ov_freq_lobith_volledig_HR2006.txt','%f %f','delimiter',' ','commentstyle','matlab');

%==========================================================================
%Inlezen Hydra-B golven en opslaan golven in structure:
%==========================================================================

[max_golven_HB, t_golven_HB, q_golven_HB] = textread('afvoergolvenLobith_uitgebreid_HR2006.txt','%f %f %f','delimiter',' ','commentstyle','matlab');
[golven_HB]                               = data_golven_HB(max_golven_HB, t_golven_HB, q_golven_HB);

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
plot_Rijngolven(golven, basis_niv, B, topduur_inv);


%==========================================================================
% Plotten van standaardvorm en trapezium.
%==========================================================================
figuur_standaardvorm_trapezium_Lob;

%==========================================================================
% Diverse plaatjes golven
%==========================================================================
diverse_plaatjes_golven_Lob;

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

%wegschrijven onderschrijdingskans Rijn tbv correlatiemodel
%onderschrijdkans_Rijn = [berek_trap.y, 1-berek_trap.Gy_piek];
%save([padnaam_uit,'F_Rijn.txt'],'onderschrijdkans_Rijn','-ascii')

%Saven van momentane kansen naar een tabel
k_kolom = [750:250:22000]';   %Deze stapgroottes bij voorkeur niet veranderen
tabelmomkans = [k_kolom, interp1(berek_trap.y, berek_trap.Gy_mom, k_kolom)];
save([padnaam_uit,'momkans_Lobith_berekend_met_stapy',num2str(stapy),'_ymax',num2str(ymax),'.txt'],'tabelmomkans','-ascii')

%figuur topduur trapezia
figuur_topduur_trapezia_Lob;

%==========================================================================
% Momentane ov.kans volgens de metingen (observaties)
%==========================================================================
yturf = [(0: stapy : ovkanspiek_inv(1,1))'; berek_trap.y];
[mom_obs] = turven_metingen(yturf, data);
%mom_obs =
%     y: [13x1 double]       %vector met afvoerniveaus (= berek_trap.y)
%    Gy: [13x1 double]       %momentane ov.kansen
%    fy: [13x1 double]       %momentane kansdichtheid


% %==========================================================================
% % Plotposities met werklijn
% %==========================================================================
% figuur_plotpos_werklijn_Lob;

%==========================================================================
% Plaatjes momentane kansen volgens de metingen en volgens de integratie
%==========================================================================
figuur_momkans_meting_integratie_Lob;

%==========================================================================
% Enkele gemiddelden
%==========================================================================
gem_data = mean(data)
gem_trap = sum(berek_trap.fy_mom.*berek_trap.y)*stapy

disp('gemiddelde van mom. ovkans Hydra-B HR2006')
gemiddelde_kolomvector_met_ovkans(q_HB, qmom_HB)

%==========================================================================
% Plaatje ovfreq basisduur
%==========================================================================
figuur_ovfreq_basisduur_Lob;


close all

%==========================================================================
% Plaatjes momentane kansen volgens Hydra-B HR2006 en volgens de integratie
%==========================================================================
figuur_momkans_HB_integratie_Lob;

figuur_momkans_HB_integratie_Lob_English;



% %==========================================================================
% % Plaatje MA-golf met trapezium
% %==========================================================================
% figuur_MAgolf_trapezium_Lob;
% 
% %==========================================================================
% % Plaatje HB-golven met trapezia
% %==========================================================================
% figuur_HBgolven_trapezia_Lob;