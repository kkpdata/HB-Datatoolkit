c%==========================================================================
% Hoofdprogramma Markermeer (versie met geknikte trapezia)
% Door: Chris Geerse
% Tbv: PR1322

%==========================================================================
%==========================================================================
% Algemene zaken
%==========================================================================

clc; clear all; close all
addpath 'Hulproutines\'

%==========================================================================
% Algemene invoer(parameters)
%==========================================================================
%Invoerparameters
invoerpad               =   'Invoer\';
uitvoerpad              =   'Uitvoer\';
uitvoerpad_figuren      =   'Figuren\';

%Data bestanden
infile_ovdag_VM         = 'VM_mpdag.dat';
infile_ovfreq_VM        = 'VM_mptop.dat';
infile_data_VM          = 'mp_dagmaxima_VM_1987_maart2008.txt';


%==========================================================================
%==========================================================================
%Invoerparameters
%==========================================================================
%Parameters voor selectie golven en opschaling
%==========================================================================

stationsnaam = 'Veerse Meer';

%homogenisatieparameters
zichtjaar = 2007;         %homogenisatie naar 1 jan van zichtjaar
stijging_per_jaar = 0.00; %aangenomen stijging per jaar in m 

%geef hier de gewenste selectie aan:
bej = 1987; bem = 1;  bed = 1;
eij = 2007; eim = 12; eid = 31;   

%Overige parameters
% origineel
drempel        = - 0.445;  % variabele voor drempel waarde; kies -0.426 en middelste wintermaanden voor afleiden trapezia.

% tijdelijk
drempel        = - 0;

ref_niv        = - 0.70;   %referentieniveau van waaraf wordt opgeschaald
basis_niv      = ref_niv;   %hoogte waarop trapezium begint (meestal gelijk aan ref_niv).
piekduur       = 0.9999; %duur waarmee pieken/dalen worden verbreed, 0< piekduur <1; default 0.9999.
nstapv         = 100;    %interval [0,1] wordt opgevuld met nstapv deelintervallen
fig_golven_verbreed = 0; %indien 1 wel plaatjes verbrede golven, indien 0 dan niet
fig_golven_rel = 0;      %indien 1 wel plaatje relatieve golven, indien 0 dan niet
fig_opschaling = 0;      %indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet

%parameters trapezia
B         = 20;             %basisduur trapezia (B = 10 geeft (ook) geen goede overeenstemming met PR1322, vermoedelijk door andere selectie in flankmaanden.
zpot      = floor(B/2);     % zichtduur voor selectie pieken;
zB        = floor(B/2);     %halve breedte van geselecteerde tijdreeks (default=zpot) NB zB>zpot kan soms crash geven

av        = 1;          %niveau insnoering in verticale richting NB (0.001<= av <=1): av=0 geeft rare antwoorden (av = 0.001 niet)
ah        = 1;          %factor insnoering in horizontale richting (ah = 1 is geen insnoering)


if (ah > 1/(1-av+eps))
    disp(['ah      = ', num2str(ah)])
    hulp = 1/(1-av); disp(['1/(1-av = ', num2str(hulp)])
    disp('FOUT: Er dient voldaan te zijn aan ah <= 1/(1-av)!')
    disp('Geef enter om door te gaan (dan met foute resultaten).')
    pause
end

Ntrapezia = 180/B;

% Invoeren overschrijdingskansen piekwaarden in basisduur
% Keuze vanaf T = 1 jaar volgens rapportage PR1322.
% NB: als ovkanspiek te abrupte sprongen maakt, kan dat onnauwkeurigheden
% opleveren! Die zie je terug in het feit dat de normeringen in
% grootheden_kniktrap dan een som van de kansen hebben die duidelijk afwijkt
% van 1.0.
ovkanspiek_inv = ...       
    [ref_niv, 1;
      -0.20  3.3/Ntrapezia;      %LET OP: MOET > DAN ref_niv zijn!!!
      -0.02  1/Ntrapezia;
       0.36, 1e-4/Ntrapezia;
       0.4532, 1e-5/Ntrapezia]; %laatste alleen toegevoegd voor beter plaatje
 
% Invoeren piekduren trapezia
topduur_inv = ...       
    [ref_niv, B*24;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
       -0.46, 48
        1.4,  48];

Nrijen      = numel(topduur_inv(:,1));

c = 0.12;          % constante Gringorton in de formule voor de plotposities (werklijn)
d = 0.44;          % constante Gringorton in de formule voor de plotposities (werklijn)

%parameters meerpeil
stapy = 0.01;      %stapgrootte voor kansvectoren (y is bijv piekafvoer of afvoerniveau)
ymax  = 1.4;        %maximum van vector


%==========================================================================
%Inlezen van Promovera statistiek
%==========================================================================

%Inlezen statistiek, respectievelijk:
%m, m+NAP; OD, dag/whjaar; ODwest, dag/whjaar; ODoost, dag/whjaar.
filenaam_ovdag_VM                  = fullfile(invoerpad, infile_ovdag_VM);
[m_PROM, OD_PROM, OD_PROMwest, OD_PROMoost] = ...
    textread(filenaam_ovdag_VM, '%f %f %f %f','delimiter',' ','commentstyle','matlab');


%m, m+NAP; OF, 1/whjaar. NB: rij meerpeilen moet wel precies hetzelfde zijn
%voor ovfreq en ovdag!
filenaam_ovfreq_VM                 = fullfile(invoerpad, infile_ovfreq_VM);
[m_PROM, OF_PROM]                       = ...
    textread(filenaam_ovfreq_VM,'%f %f','delimiter',' ','commentstyle','matlab');

%NB: tov rapport PR1322 is in Promovera 0.3 m bij de meerpeilen opgeteld
% vanwege een verwacht hoger streefpeil.
% Voor de analyses moet deze o.3 m er weer worden afgetrokken.
shift_PROM  = -0.30;     
m_PROM      = m_PROM + shift_PROM;

%--------------------------------------------------------------------------
%Inlezen data
filenaam_data_VM         = fullfile(invoerpad, infile_data_VM);
[jaar, maand, dag, data] = textread(filenaam_data_VM,'%f %f %f %f','delimiter',' ','commentstyle','matlab');
datum                    = datenum(jaar,maand,dag); 

% Omrekenen van cm naar m:
data        = data/100;

% Ontbrekende waarden zijn weergegeven als -999 (periode 3 juni - 31 december 1981)
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

% % % % Hele winterhalfjaar (voor als je alle data uit het whjaar wilt laten
% % % % zien.
selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 |...
    maand == 2 | maand == 3)&(datum >= bedatum & datum <= eidatum));

% % % % Maanden 11 t/m 2: GEBRUIK DEZE VOOR AFLEIDEN GOLVEN OM ZOMERPEILEN IN
% % % % FLANKMAANDEN TE VERMIJDEN
% % % selectie = find((  maand == 11 | maand == 12 | maand == 1 |...
% % %     maand == 2 )&(datum >= bedatum & datum <= eidatum));

% % Maanden 12 t/m 1
% selectie = find((  maand == 12 | maand == 1) ...
%    &(datum >= bedatum & datum <= eidatum));

% % Zomermaanden + flankmaanden 3 t/m 10
% selectie = find((  maand >= 3 & maand <=10) ...
%    &(datum >= bedatum & datum <= eidatum));


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

% max_trapeziumplotjes = -0.1;    %maximum voor trapezia in subplotjes; keuze middelste wintermaanden
max_trapeziumplotjes = 1.0;    %maximum voor trapezia in subplotjes; keuze middelste wintermaanden
plot_golven(golven, ref_niv, B, topduur_inv, ah, av, max_trapeziumplotjes)

%==========================================================================
% Plotten van geselecteerde golven, standaardvorm en trapezium.
%==========================================================================

Figuur_GemiddeldeGolf_Trapezium;

 
%==========================================================================
% Momentane ov.kans volgens berekening met trapezia
%==========================================================================

[berek_trap] = grootheden_kniktrap(stapy, ymax, basis_niv, B, av, ah, topduur_inv, ovkanspiek_inv);
%         y: [Nx1 double]
%         by: [Nx1 double]
%    fy_piek: [Nx1 double]
%    Gy_piek: [Nx1 double]
%     fy_mom: [Nx1 double]
%     Gy_mom: [Nx1 double]

% [berek_trap.y berek_trap.Gy_piek]
% NB: deze uitvoer klopt precies!

% [berek_trap.y berek_trap.Gy_mom]



Figuur_Topduur;

%==========================================================================
% Diverse plaatjes golven
%==========================================================================

% Gemeten golven
Figuur_GemetenGolven;

% Aangepaste golven
Figuur_AangepasteGolven;

%nu golven op 1 genormeerd
Figuur_GenormeerdeGolven;

%==========================================================================
% Momentane ov.kans volgens de metingen (observaties)
%==========================================================================
yturf = [(-0.5: stapy : ovkanspiek_inv(1,1))'; berek_trap.y];
[mom_obs] = turven_metingen(yturf, data);
%mom_obs =
%     y: [Nx1 double]       %vector met afvoerniveaus (= berek_trap.y)
%    Gy: [Nx1 double]       %momentane ov.kansen
%    fy: [Nx1 double]       %momentane kansdichtheid


close all

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

hoogste_mp_tabel = 0.65; %NB: moet ruim onder ymax liggen.
Feind            = find(x1 == hoogste_mp_tabel);

% Situatie met peilverhoging
tabel = [-shift_PROM + x1(1:Feind)'; x2(1:Feind)'; x2(1:Feind)'];
fid = fopen([uitvoerpad,'Veersemeer_momentane_ovkansen_v01.txt'],'wt');
fprintf(fid,'%12.2f           %1.3E           %1.3E\n', tabel);
fclose(fid);

% Situatie zonder peilverhoging
tabel = [x1(1:Feind)'; x2(1:Feind)'; x2(1:Feind)'];
fid = fopen([uitvoerpad,'Veersemeer_momentane_ovkansen_excl_peilverhoging.txt'],'wt');
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
