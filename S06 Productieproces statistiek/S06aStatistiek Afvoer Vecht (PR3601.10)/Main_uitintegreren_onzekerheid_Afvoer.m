%==========================================================================
% Script uitintegreren onzekerheid van de piekafvoer in de basisduur (B = 30 dagen),
% als onzekerheid normaal is verdeeld (additief model).
%
% Door: Chris Geerse
% PR3257.20
% Datum: april 2016.
%
%
%==========================================================================
%==========================================================================
% Invoer
%==========================================================================

clc
clear
close all
addpath 'Hulproutines\' 'Invoer\';

% Bestand overschrijdingskansen basisduur uit HR2006:
infileDalfsen    = 'Discharge Dalfsen_invoerHZ.txt';

% Inlezen invoer, bepalen afvoergrid en ovkansen op dit grid
sNaam            = 'Dalfsen';
typeVerdeling    = 'lognormaal';
ovkansenAfvoer   = load(infileDalfsen);
kSt              = 1;   %Getallen uit rapportage denk ik bepaald met 10 m3/s; achteraf gezien is 1 m3/s beter
kMax             = 1200;

% Tbv onzekerheidsbanden:
pCI      = 0.95;    %1-pCI wordt gelijk verdeeld over onder- en bovenkant; default 0.95
%pCI      = normcdf(1) - normcdf(-1);    %van - sigma tot + sigma
%pCI = 0.001


%==========================================================================
disp(['Analyse voor ',sNaam]);
%==========================================================================

kInv    = ovkansenAfvoer(:,1);
kPovInv = ovkansenAfvoer(:,2);

% Grid voor k-waarden
kMin    = min(kInv);
kGrid   = [kMin : kSt: kMax]';

% Bepaal ovkansen op kGrid
kPov    = exp( interp1( kInv, log(kPovInv), kGrid, 'linear', 'extrap') );

%==========================================================================
% Uitintegreren onzekerheid (additief model)
%==========================================================================

% Model:
% V_incl = Vexcl + Y.
% Y ~ N(kMu, kSig).

% Grid voor v-waarden (met onzekerheid)
vSt   = kSt;
vMin  = kMin;
vMax  = kMax;
vGrid = [vMin : vSt: vMax]';

% Bepaal mu en sigma als functie van k:
%[kMu, kSig] = bepaalOnzekerheidNormaalAfvoer(keuzeStation, kGrid);
[kMu, kSig, kEps] = bepaalOnzekerheidAfvoer(kGrid);

% Forceer dat kEps niet >= 0 kan worden.
Ind       = find(kEps > -1e-8);
kEps(Ind) = -1e-8;

% Bereken overschrijdingskansen incl. onzekerheid:
[vPov] = bepaalUitgeintegreerdeOvkansen(kGrid, kPov, typeVerdeling, kMu, kSig, kEps, vGrid);


%% Zorg dat je met onzekerheid niet lager uitkomt dan zonder onzekerheid:
vPov(vPov < kPov)     = kPov(vPov < kPov);


%==========================================================================
% Figuren zonder en met onzekerheid
%==========================================================================
close all

Fig_MetEnZonderOnzekerheid;
% Betreft dus inmiddels 'sterk' verouderde onzekerheid zonder overstomingen!

%==========================================================================
% Verwerken overstroombare gebieden (gegevens uit PR3202.10)
% Nu met schatting voor zijleidingen erbij (keuze voor rapport en bestanden):
%==========================================================================
TF =[...
    0       0       %toegevoegd voor interpolatiedoeleinden
    420     420     %toegevoegd
    429.5	427.1
    625.9	595.2
    665.2	612.7
    704.2	627.3
    743.4	637.2
    782.4	643.4];



% Voer transformatie uit op ovkans zonder onzekerheid
kGridTF     = interp1(TF(:,1), TF(:,2), kGrid, 'linear', 'extrap');
kTF_PovHulp = kPov;
% Maak nu weer de kansverdeling op het originele grid:
kTF_Pov = exp( interp1(kGridTF, log(kTF_PovHulp), kGrid, 'linear', 'extrap') );

% Voer transformatie uit op ovkans met onzekerheid
vGridTF     = interp1(TF(:,1), TF(:,2), vGrid, 'linear', 'extrap');
vTF_PovHulp = vPov;
vTF_Pov     = exp( interp1(vGridTF, log(vTF_PovHulp), vGrid, 'linear', 'extrap') );



%% Figuren met en zonder overstroming (PR3257.10)
Fig_MetEnZonderOverstromen;



%% Bepalen invoerbestanden Hydra-NL
[InvoerNL_geenOnzheid_overstromen, InvoerNL_Onzheid_overstromen] =...
    bepalenEnCheckenVanInvoerbestanden(kGrid, kPov, kTF_Pov, vGrid, vTF_Pov, sNaam);


close all
%% Bepaal onzekerheidsbanden (zonder overstromen)
[bandOnder, bandMidden, bandBoven]   = bepaalOnzekerheidsbanden(kGrid, typeVerdeling, kSig, kEps, pCI);

Kans2Freq = 6;
Fig_MetEnZonderOnzekerheidPlusBanden;


close all

%% Bepaal onzekerheidsbanden inclusief overstromingen (OS)

bandOnderOS  = interp1(TF(:,1), TF(:,2), bandOnder,  'lineair', 'extrap');
bandMiddenOS = interp1(TF(:,1), TF(:,2), bandMidden, 'lineair', 'extrap');
bandBovenOS  = interp1(TF(:,1), TF(:,2), bandBoven,  'lineair', 'extrap');

Fig_UigebreideFigurenMetBanden;
Fig_UigebreideFigurenMetBanden_rapport;

% Figuur overschrijdingsKANS,  met onderdelen:
% - Zonder overstromen, zonder onzekerheid
% - Met overstromen, zonder onzekerheid
% - Zonder overstromen, met onzekerheid
% - Met overstromen, met onzekerheid
% - Banden zonder overstromen
% - Banden met overstromen

% Figuur overschrijdingsFREQUENTIE,  met onderdelen:
% - Zonder overstromen, zonder onzekerheid
% - Met overstromen, zonder onzekerheid
% - Zonder overstromen, met onzekerheid
% - Met overstromen, met onzekerheid
% - Banden zonder overstromen
% - Banden met overstromen

close all

%% Beknoptere figuren

% Figuur overschrijdingsKANS,  met onderdelen:
% - Met overstromen, zonder onzekerheid
% - Met overstromen, met onzekerheid
% - Banden met overstromen
figure
semilogy(kGrid, kTF_Pov,'b-.','LineWidth',1.5);
grid on; hold on
semilogy(vGrid, vTF_Pov,'r-.','LineWidth',1.5);
semilogy(bandOnderOS, kPov,'g-.','LineWidth',1.5);
semilogy(bandBovenOS, kPov,'g-.','LineWidth',1.5);
semilogy(kEps +kGrid, kPov,'k--','LineWidth',1.5);  %als check dat de verdeling bij streefpeil begint
title(['Overschrijdingskans ', sNaam]);
ylabel('Afvoer [m^3/s]')
ylabel('Overschrijdingskans [-]');
legend('Met overstromen, zonder onzekerheid',...
    'Met overstromen, met onzekerheid',...
    ['BI, met overstromen',     num2str(100*pCI),'%']);
ylim([1e-7, 1]);
xlim([0, 800])

% Figuur overschrijdingsFREQUENTIE,  met onderdelen:
% - Met overstromen, zonder onzekerheid
% - Met overstromen, met onzekerheid
% - Banden met overstromen
figure
semilogx(1./(Kans2Freq*kTF_Pov), kGrid, 'b-.','LineWidth',1.5);
grid on; hold on
semilogx(1./(Kans2Freq*vTF_Pov), vGrid, 'r-.','LineWidth',1.5);
semilogx(1./(Kans2Freq*kPov),    bandOnderOS,'g-.','LineWidth',1.5);
semilogx(1./(Kans2Freq*kPov),    bandBovenOS,'g-.','LineWidth',1.5);

title(['Overschrijdingsfrequentie ', sNaam]);
ylabel('Afvoer [m^3/s]')
xlabel('Terugkeertijd [jaar]')
legend('Met overstromen, zonder onzekerheid',...
    'Met overstromen, met onzekerheid',...
    ['BI, met overstromen',     num2str(100*pCI),'%']);
xlim([10, 1e6]);
ylim([200, 800])

%==========================================================================
% Nieuwe onzekerheidsverdeling construreren, met normale verdeling
%==========================================================================

% Bepaal (handgekozen) par's van normale verdeling
[kMuNorm, kSigNorm] = bepaalOnzekerheidAfvoerNieuw(kGrid);


% Bereken overschrijdingskansen incl. onzekerheid:
typeVerdeling    = 'normaal';
kEps             = 0*kMuNorm;   %geef deze een irrelevante waarde
[vPovNw] = bepaalUitgeintegreerdeOvkansen(kGrid, kTF_Pov, typeVerdeling, kMuNorm, kSigNorm, kEps, vGrid);

%% Zorg dat je met onzekerheid niet lager uitkomt dan zonder onzekerheid:
vPovNw(vPovNw < kTF_Pov)     = kTF_Pov(vPovNw < kTF_Pov);


[bandOnderNorm, bandMiddenNorm, bandBovenNorm] = bepaalOnzekerheidsbandenNormaal(kGrid, kMuNorm, kSigNorm, pCI);

close all

% Figuur met kansen
figure
semilogy(kGrid, kTF_Pov,'b-.','LineWidth',2);
grid on; hold on
semilogy(vGrid, vTF_Pov,'r-.','LineWidth',2);
semilogy(vGrid, vPovNw, 'k-','LineWidth',2);
semilogy(bandOnderNorm, kTF_Pov,'b-','LineWidth',1);
semilogy(bandBovenNorm, kTF_Pov,'b-','LineWidth',1);
semilogy(bandMiddenNorm, kTF_Pov,'b-','LineWidth',1);
title(['Overschrijdingskans ', sNaam]);
ylabel('Afvoer [m^3/s]')
ylabel('Overschrijdingskans [-]');
legend('Met overstromen, zonder onzekerheid',...
    'Met overstromen, met oude onzekerheid',...
    'Met overstromen, met nieuwe onzekerheid',...
    ['BI, met overstromen ',     num2str(100*pCI),'%']);
ylim([1e-7, 1]);
xlim([0, 800])


close all

% Figuur overschrijdingsFREQUENTIE,  met onderdelen:
figure
semilogx(1./(Kans2Freq*kTF_Pov), kGrid, 'b--','LineWidth',2);
grid on; hold on
semilogx(1./(Kans2Freq*vTF_Pov), vGrid, 'r--','LineWidth',2);
semilogx(1./(Kans2Freq*vPovNw), vGrid, 'b-','LineWidth',2);
semilogx(1./(Kans2Freq*kTF_Pov),    bandOnderNorm,'b-','LineWidth',1);
semilogx(1./(Kans2Freq*kTF_Pov),    bandBovenNorm,'b-','LineWidth',1);
semilogx(1./(Kans2Freq*kTF_Pov),    bandMiddenNorm,'b-','LineWidth',1);
title(['Overschrijdingsfrequentie ', sNaam]);
ylabel('Afvoer [m^3/s]')
xlabel('Terugkeertijd [jaar]')
legend('Met overstromen, zonder onzekerheid',...
    'Met overstromen, met oude onzekerheid',...
    'Met overstromen, met nieuwe onzekerheid',...
    ['BI, met overstromen ',     num2str(100*pCI),'%']);
xlim([10, 1e6]);
ylim([200, 800])

% Figuur overschrijdingsFREQUENTIE,  met onderdelen:
figure
semilogx(1./(Kans2Freq*kTF_Pov), kGrid, 'b--','LineWidth',2);
%semilogx(1./(Kans2Freq*vTF_Pov), vGrid, 'r--','LineWidth',2);
%semilogx(1./(Kans2Freq*vPovNw), vGrid, 'b-','LineWidth',2);
grid on; hold on
semilogx(1./(Kans2Freq*kTF_Pov),    bandMiddenNorm,'k-','LineWidth',1);
semilogx(1./(Kans2Freq*kTF_Pov),    bandOnderNorm,'b-','LineWidth',1);
semilogx(1./(Kans2Freq*kTF_Pov),    bandBovenNorm,'b-','LineWidth',1);
title(['Overschrijdingsfrequentie ', sNaam]);
ylabel('Afvoer [m^3/s]')
xlabel('Terugkeertijd [jaar]')
legend('Met overstromen, zonder onzekerheid',...
    'Met overstromen, 50%-band',...
    ['BI, met overstromen ',     num2str(100*pCI),'%']);
xlim([10, 1e6]);
ylim([200, 800])

% voor memo 3257.20
% Figuur overschrijdingsFREQUENTIE,  met onderdelen:
figure
semilogx(1./(Kans2Freq*kTF_Pov), kGrid, 'b--','LineWidth',2);
grid on; hold on
semilogx(1./(Kans2Freq*vTF_Pov), vGrid, 'r--','LineWidth',2);
title(['Overschrijdingsfrequentie ', sNaam]);
ylabel('Afvoer [m^3/s]')
xlabel('Terugkeertijd [jaar]')
legend('Met overstromen, zonder onzekerheid',...
    'Met overstromen, met onzekerheid uit PR3257.10')
xlim([10, 1e6]);
ylim([200, 800])

%==========================================================================
% Invoer Hydra-Ring
%==========================================================================

Tring = [2, 5, 10, 20, 50, 100, 250, 500, 1250, 2000, 4000, 10000, 20000, 50000, 1e5, 1e6]';

kRingOudZonz = interp1(1./(Kans2Freq*kPov),    kGrid, Tring, 'linear', 'extrap');
kRingNwZonz  = interp1(1./(Kans2Freq*kTF_Pov), kGrid, Tring, 'linear', 'extrap');
vRingNwMonz  = interp1(1./(Kans2Freq*vPovNw), vGrid, Tring, 'linear', 'extrap');


kMuNormRing  = interp1(kGrid, kMuNorm,  kRingNwZonz, 'linear', 'extrap');
kSigNormRing = interp1(kGrid, kSigNorm, kRingNwZonz, 'linear', 'extrap');

[Tring, kRingNwZonz, kMuNormRing, kSigNormRing, vRingNwMonz, kRingOudZonz];

%==========================================================================
% Invoer Hydra-NL
%==========================================================================


InvoerNL_Onzheid_overstromen_Nieuw = [vRingNwMonz, 1./(Kans2Freq*Tring)];
    
% Figuur overschrijdingsFREQUENTIE,  inclusief invoerbestand Hydra-NL
figure
semilogx(1./(Kans2Freq*kTF_Pov), kGrid, 'b--','LineWidth',2);
grid on; hold on
semilogx(1./(Kans2Freq*vTF_Pov), vGrid, 'r--','LineWidth',2);
semilogx(1./(Kans2Freq*vPovNw), vGrid, 'b-','LineWidth',2);
semilogx(1./(Kans2Freq*InvoerNL_Onzheid_overstromen_Nieuw(:,2)), InvoerNL_Onzheid_overstromen_Nieuw(:,1), 'm--','LineWidth',2.5);
semilogx(1./(Kans2Freq*kTF_Pov),    bandOnderNorm,'b-','LineWidth',1);
semilogx(1./(Kans2Freq*kTF_Pov),    bandBovenNorm,'b-','LineWidth',1);
title(['Overschrijdingsfrequentie ', sNaam]);
ylabel('Afvoer [m^3/s]')
xlabel('Terugkeertijd [jaar]')
legend('Met overstromen, zonder onzekerheid',...
    'Met overstromen, met oude onzekerheid',...
    'Met overstromen, met nieuwe onzekerheid',...
    'Invoer Hydra-NL (na omrekening naar terugkeertijd)',...
    ['BI, met overstromen ',     num2str(100*pCI),'%']);
xlim([10, 1e6]);
ylim([200, 800])

%% Nieuwe invoergegevens met onzekerheid

InvoerNL_Onzheid_overstromen_Nieuw

% Op basis van deze gegevens wordt Dalfsen incl onzekerheid bepaald 
% in Hydra-NL/Ring.
% Oftewel: de onzekerheidsbanden volgens HKV en Deltares stemmen volledig overeen.
% Zie Hydra-NL bestand: Ovkans_Dalfsen_piekafvoer_2017_metOnzHeid.txt), 
% Hydra-NL versie 2.2.1. 
% N.B. Dit bestand vervangt de oude versie uit PR3257.10.


close all

%% Toevoeging 18 sep 2017 voor Robert Slomp (Engelstalig)

% Figuur overschrijdingsFREQUENTIE,  met onderdelen:
figure
semilogx(1./(Kans2Freq*kTF_Pov), kGrid, 'b-','LineWidth',2);
grid on; hold on
semilogx(1./(Kans2Freq*kTF_Pov),    bandOnderNorm,'b--','LineWidth',1);
semilogx(1./(Kans2Freq*vPovNw), vGrid, 'r--','LineWidth',2);
semilogx(1./(Kans2Freq*kTF_Pov),    bandBovenNorm,'b--','LineWidth',1);
title(['Exceedance frequency ', sNaam]);
ylabel('Discharge [m^3/s]')
xlabel('Return period [year]')
legend('Exceedance frequency',...
     ['Confidence interval ',     num2str(100*pCI),'%'],...
     'Exceedance frequency including statistical uncertainty', 'location', 'NorthWest');
xlim([10, 1e4]);
ylim([200, 800])

% Figuur overschrijdingsFREQUENTIE,  met onderdelen:
figure
semilogx(1./(Kans2Freq*kTF_Pov), kGrid, 'b-','LineWidth',2);
grid on; hold on
semilogx(1./(Kans2Freq*kTF_Pov),    bandOnderNorm,'b--','LineWidth',1);
semilogx(1./(Kans2Freq*vPovNw), vGrid, 'r--','LineWidth',2);
semilogx(1./(Kans2Freq*kTF_Pov),    bandBovenNorm,'b--','LineWidth',1);
title(['Exceedance frequency ', sNaam]);
ylabel('Discharge [m^3/s]')
xlabel('Return period [year]')
legend('Exceedance frequency',...
     ['Confidence interval ',     num2str(100*pCI),'%'],...
     'Exceedance frequency including statistical uncertainty', 'location', 'NorthWest');
xlim([10, 1e5]);
ylim([200, 900])
