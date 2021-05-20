%==========================================================================
% Hoofdprogramma Volkerak Zoommeer (versie met geknikte trapezia)
% Door: Chris Geerse
% Tbv: PR1322

%==========================================================================
%==========================================================================
% Algemene zaken
%==========================================================================

clc; clear all; close all
addpath 'Hulproutines\' 'Invoer\'

%==========================================================================
% Algemene invoer(parameters)
%==========================================================================
%Invoerparameters
invoerpad               =   'Invoer\';
uitvoerpad              =   'Uitvoer\';
uitvoerpad_figuren      =   'Figuren\';

infile_ovdag_VZM        = 'VZM_mpdag.dat';
infile_ovfreq_VZM       = 'VZM_mptop.dat';

infile_data_VZM         = 'mp_dagmaxima_VZM_1998_2011.txt';
%infile_data_VZM         = 'mp_daggemiddelde_VZM_1998_2011.txt';   %Niet gebruikt in PR1322

%==========================================================================
%==========================================================================
%Invoerparameters
%==========================================================================
%Parameters voor selectie golven en opschaling
%==========================================================================

stationsnaam = 'Volkerak-Zoommeer';

%homogenisatieparameters
zichtjaar = 2007;         %homogenisatie naar 1 jan van zichtjaar
stijging_per_jaar = 0.00; %aangenomen stijging per jaar in m 

%geef hier de gewenste selectie aan:
bej = 1998; bem = 1; bed = 1;
% eij = 2007; eim = 12; eid = 31;
eij = 2006; eim = 12; eid = 31;     %Volgens mij is dit de einddatum uit PR1322, en niet eind 2007 zoals dat in het rapport staat!

%Overige parameters
drempel        =   0.2;   % variabele voor drempel waarde (kies 0.2 voor pieken) -0.099
ref_niv        = - 0.10;   %referentieniveau van waaraf wordt opgeschaald
basis_niv      = ref_niv;   %hoogte waarop trapezium begint (meestal gelijk aan ref_niv).
piekduur       = 0.9999; %duur waarmee pieken/dalen worden verbreed, 0< piekduur <1; default 0.9999.
nstapv         = 100;    %interval [0,1] wordt opgevuld met nstapv deelintervallen
fig_golven_verbreed = 0; %indien 1 wel plaatjes verbrede golven, indien 0 dan niet
fig_golven_rel = 0;      %indien 1 wel plaatje relatieve golven, indien 0 dan niet
fig_opschaling = 0;      %indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet

%parameters trapezia
B         = 20;             %basisduur trapezia
zpot      = floor(B/2);     % zichtduur voor selectie pieken; NB: kies 15 dagen voor beoordelen werklijn (bij 30 dagen vallen er veel pieken weg)
zB        = floor(B/2);     %halve breedte van geselecteerde tijdreeks (default=zpot) NB zB>zpot kan soms crash geven

av        = 0.25;          %niveau insnoering in verticale richting NB (0.001<= av <=1): av=0 geeft rare antwoorden (av = 0.001 niet)
ah        = 1.2;          %factor insnoering in horizontale richting (ah = 1 is geen insnoering)

if (ah > 1/(1-av))
    disp(['ah      = ', num2str(ah)])
    hulp = 1/(1-av); disp(['1/(1-av = ', num2str(hulp)])
    disp('FOUT: Er dient voldaan te zijn aan ah <= 1/(1-av)!')
    disp('Geef enter om door te gaan (dan met foute resultaten).')
    pause
end
Ntrapezia = 180/B;

ovkanspiek_inv = ...       
    [ref_niv, 1;
      0.07,  8/Ntrapezia;    %traject van -0.22 tot 1.00 m+NAP volgens Hydra-M, wel gedeeld door aantal trapezia in whjaar
      0.22,  1/Ntrapezia;
      0.94,  1e-4/Ntrapezia
      1.113, 1e-5/Ntrapezia];    %laatste toegevoegd voor beter plaatje
topduur_inv = ...       
    [ref_niv, B*24;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
      0.1,    B*24
      0.18,    36
      1.80,   36];

  
Nrijen      = numel(topduur_inv(:,1));

c = 1;               %tbv rapport PR1322
d = 0;


%parameters meerpeil
stapy = 0.01;      %DEFAULT 0.01, stapgrootte voor kansvectoren (y is bijv piekafvoer of afvoerniveau)
ymax  = 1.8;        %maximum van vector


%==========================================================================
%Inlezen van Promovera statistiek
%==========================================================================

%Inlezen statistiek, respectievelijk:
%m, m+NAP; OD, dag/whjaar; ODwest, dag/whjaar; ODoost, dag/whjaar.
filenaam_ovdag_VZM                  = fullfile(invoerpad, infile_ovdag_VZM);
[m_PROM, OD_PROM, OD_PROMwest, OD_PROMoost] = ...
    textread(filenaam_ovdag_VZM, '%f %f %f %f','delimiter',' ','commentstyle','matlab');

%m, m+NAP; OF, 1/whjaar. NB: rij meerpeilen moet wel precies hetzelfde zijn
%voor ovfreq en ovdag!
filenaam_ovfreq_VZM                 = fullfile(invoerpad, infile_ovfreq_VZM);
[m_PROM, OF_PROM]                       = ...
    textread(filenaam_ovfreq_VZM,'%f %f','delimiter',' ','commentstyle','matlab');

%--------------------------------------------------------------------------
%Inlezen data
filenaam_data_VZM        = fullfile(invoerpad, infile_data_VZM);
[jaar, maand, dag, data] = textread(filenaam_data_VZM,'%f %f %f %f','delimiter',' ','commentstyle','matlab');
datum                    = datenum(jaar,maand,dag); 

% Omrekenen van cm naar m:
data        = data/100;

% Ontbrekende waarden zijn weergegeven als -999 (periode 3 juni - 31
% december 1981)
% Selecteer alleen geldige waarnemingen.
Fgeldig     = find(data > -3.99);
dag         = dag(Fgeldig);
maand       = maand(Fgeldig);
jaar        = jaar(Fgeldig);
data        = data(Fgeldig);
datum       = datum(Fgeldig);


%==========================================================================
%Selectie whjaren en berekenen van algemene (globaal te gebruiken) variabelen
%==========================================================================
bedatum = datenum(bej,bem,bed);
eidatum = datenum(eij,eim,eid);

selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 |...
    maand == 2 | maand == 3)&(datum >= bedatum & datum <= eidatum));

% % Hele jaar
% selectie = find(( maand >= 1 & maand <= 12) & (datum >= bedatum & datum <= eidatum));

% % Maanden 11 t/m 2
% selectie = find((  maand == 11 | maand == 12 | maand == 1 |...
%     maand == 2 )&(datum >= bedatum & datum <= eidatum));

jaar = jaar(selectie); maand = maand(selectie); dag = dag(selectie); data = data(selectie);
datum = datenum(jaar,maand,dag);
dagnr = (1:numel(data))';

%==========================================================================
% Figuren van data als functie van de tijd
%==========================================================================

Figuur_Tijdreeks;


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


%==========================================================================
%Aanpassen van golven: piek/dal-verbreding en monotone voor- en
%achterflanken maken door nevenpieken tegen hoofdpiek te plakken.
%Resultaat: aangepaste golven (stijgende voor- en dalende achterflank) en (gemiddelde)
%standaard(norm)golfgegevens.

[golven_aanpas, standaardvorm] = opschaling(...
golven,ref_niv,piekduur,nstapv,fig_golven_verbreed,fig_golven_rel,fig_opschaling);


%==========================================================================
% Plotten van geselecteerde golven tezamen met trapezium.
%==========================================================================

max_trapeziumplotjes = 0.4;
Ngolven = numel(golven);
if Ngolven <= 20
    plot_golven(golven, ref_niv, B, topduur_inv, ah, av,max_trapeziumplotjes)
end
% 

%==========================================================================
% Plotten van geselecteerde golven, standaardvorm en trapezium.
%==========================================================================

Figuur_GemiddeldeGolf_Trapezium;


%==========================================================================
% Momentane ov.kans volgens berekening met trapezia
%==========================================================================

%Versie zonder knikmogelijkheid
%[berek_trap] = grootheden_trap(stapy, ymax, basis_niv, B, topduur_inv, ovkanspiek_inv);

[berek_trap] = grootheden_kniktrap(stapy, ymax, basis_niv, B, av, ah, topduur_inv, ovkanspiek_inv);
%         y: [Nx1 double]
%         by: [Nx1 double]
%    fy_piek: [Nx1 double]
%    Gy_piek: [Nx1 double]
%     fy_mom: [Nx1 double]
%     Gy_mom: [Nx1 double]

Figuur_Topduur;


%==========================================================================
% Momentane ov.kans volgens de metingen (observaties)
%==========================================================================
yturf = [(-0.5: stapy : ovkanspiek_inv(1,1))'; berek_trap.y];
[mom_obs] = turven_metingen(yturf, data);
%mom_obs =
%     y: [Nx1 double]       %vector met afvoerniveaus (= berek_trap.y)
%    Gy: [Nx1 double]       %momentane ov.kansen
%    fy: [Nx1 double]       %momentane kansdichtheid

%==========================================================================
% Diverse plaatjes golven
%==========================================================================

% Gemeten golven
Figuur_GemetenGolven;

% Aangepaste golven
Figuur_AangepasteGolven;

%nu golven op 1 genormeerd
Figuur_GenormeerdeGolven;



%close all

%==========================================================================
% Gemiddelden en standaarddeviaties van: data, integratie, Promovera.
%==========================================================================

% Getoond op scherm:
Gemiddelden_en_Standdev_van_Data_Integratie_Promovera;


%==========================================================================
% Frequentielijnen Promovera, Hydra-Zoet en data
%==========================================================================
obs   = golfkenmerken(:,5);     %piekwaarde
r     = golfkenmerken(:,6);     %rang van piekwaarde
n     = max(r);                 %aantal meegenomen extreme waarden
t_per = numel(data)/182;        %aantal meetjaren, gebruikt in de formule voor de plotposities (werklijn)

plotpos = zeros(n,1);      %initialisatie
for i = 1:n
    plotpos(i) = ((n+c)*t_per)/((r(i)+c+d-1)*n);
end
wlijn = [ovkanspiek_inv(:,1), (Ntrapezia*ovkanspiek_inv(:,2))];


Figuur_Frequentielijnen_Data;

Figuur_Frequentielijnen_Data_TEMP
%==========================================================================
% Vergelijking Dagenlijnen Promovera, integratie en data
%==========================================================================

% Dagenlijn
Figuur_Dagenlijnen_Data;

%==========================================================================
% Plaatje overschrijdingsduur per top volgens Promovera en integratie
%==========================================================================

% Gemiddelde topduur als quotiënt van B*P(M>m)/P(S>s)

Figuur_OvDuurPerTop;

%==========================================================================
% Wegschrijven momentane overschrijdingskansen, t.b.v. splitsing Oost en
% West -sector. N.B. Beide kolmmen worden gelijk genomen.
%==========================================================================

x1 = berek_trap.y;
x2 = berek_trap.Gy_mom;

%Om er voor te zorgen dat de meerpeilen exact in centimeters zijn
%uitgedrukt:
x1 = round(10000*x1)/10000;

hoogste_mp_tabel = 1.5; %NB: moet ruim onder ymax liggen.
Feind            = find(x1 == hoogste_mp_tabel);

tabel = [x1(1:Feind)'; x2(1:Feind)'; x2(1:Feind)'];

fid = fopen([uitvoerpad,'Volkerakzoommeer_momentane_ovkansen_v01.txt'],'wt');
fprintf(fid,'%12.2f           %1.3E           %1.3E\n', tabel);
fclose(fid);

%==========================================================================
% Voor PR3280.20: Tabel Terugkeertijd - meerpeil
%==========================================================================

%Hydra-Zoet keuze (verschillen met Promovera, vanaf T=10 maximaal 0.5 cm
Treeks  = [10,25,50:50:1250, 1500, 1750, 2000:1000:20000, 30000:10000:100000]'; 
mpReeks = interp1(log(1./wlijn(:,2)), wlijn(:,1), log(Treeks), 'linear', 'extrap');

Tabel = [Treeks, mpReeks];


figure
semilogx(Tabel(:,1),Tabel(:,2),'r-');
hold on
grid on
title(['Overschrijdingsfrequentie ',stationsnaam])
xlabel('Terugkeertijd, jaar')
ylabel('Meerpeil, m+NAP')

close all

%% Hydra-Zoet gegevens inlezen (feitelijk Hydra-NL versie 2.3.0) om te checken dat
% oude gegevens niet zijn aangepast

OvkansPiekInv_HZ = load('Ovkans_Volkerakzoommeer_piekmeerpeil_2017.txt');
DagenlijnInv_HZ  = load('Dagenlijn VZM uit PR1564.10.txt');
OvduurPerTop_HZ  = load('OvduurPerTop VZM uit PR1564.10.txt');

Figuur_Frequentielijnen_Data_met_HZ_PR1564;
Figuur_Dagenlijnen_Data_met_HZ_PR1564;
Figuur_OvDuurPerTop_met_HZ_PR1564;
