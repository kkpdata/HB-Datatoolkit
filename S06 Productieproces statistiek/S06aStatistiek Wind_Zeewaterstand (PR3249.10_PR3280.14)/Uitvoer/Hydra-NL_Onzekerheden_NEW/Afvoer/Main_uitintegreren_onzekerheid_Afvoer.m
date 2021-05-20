%==========================================================================
% Script uitintegreren onzekerheid van de piekafvoer in de basisduur (B = 30 dagen),
% als onzekerheid normaal is verdeeld (additief model).
%
% Door: Chris Geerse
% PR3216.10
% Datum: november 2015.
%
%
%==========================================================================

%% Invoer

clc
clear
close all
addpath 'Hulproutines\' 'Invoer\';

% Bestand overschrijdingskansen basisduur:
% Bron: gegevens uit directory:
% "WTI2017 Stochastic data deliveries_via Karolina verkregen".
% Deze gegevens zijn nog voorlopig!
infileLobith     = 'Discharge Lobith.txt';
infileOlst       = 'Discharge Olst.txt';    
infileBorgharen  = 'Discharge Borgharen.txt';
infileLith       = 'Discharge Lith.txt';    %Overstroombare Maaskades?
infileDalfsen    = 'Discharge Dalfsen.txt';    

% Hierin staat de toegeleverde werklijn, met en zonder onzekerheid
% (toegeleverd door Jan Stijnen aan mij).
infileLobithSpreadsheet    = 'Lobith_gegevens_spreadsheet3nov2015.txt';
infileBorgharenSpreadsheet = 'Borgharen_gegevens_spreadsheet3nov2015.txt';

% Geef gewenste station op:
% 1 = Lobith
% 2 = Olst
% 3 = Borgharen
% 4 = Lith
% 5 = Dalfsen

keuzeStation = 1;

% Inlezen invoer, bepalen afvoergrid en ovkansen op dit grid
[sNaam, typeVerdeling, ovkansenAfvoer, kSt, kMax]= bepaalStationGegevens(...
    keuzeStation, infileLobith, infileOlst, infileBorgharen, infileLith, infileDalfsen );

disp(['Analyse voor ',sNaam]);

kInv    = ovkansenAfvoer(:,1);
kPovInv = ovkansenAfvoer(:,2);

% Grid voor k-waarden
kMin    = min(kInv);
kGrid   = [kMin : kSt: kMax]';

% Bepaal ovkansen op kGrid
kPov    = exp( interp1( kInv, log(kPovInv), kGrid, 'linear', 'extrap') );

%% Uitintegreren onzekerheid (additief model)

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
[kMu, kSig, kEps] = bepaalOnzekerheidAfvoer(keuzeStation, kGrid);

[vPov] = bepaalUitgeintegreerdeOvkansen(kGrid, kPov, typeVerdeling, kMu, kSig, kEps, vGrid);
%[vPov] = bepaalUitgeintegreerdeOvkansen(kGrid, kPov, kMu, kSig, vGrid);

%% Figuren

% Figuur overschrijdingskans, zonder en met onzekerheid:
figure
semilogy(kGrid, kPov,'b-','LineWidth',1.5);
grid on; hold on
semilogy(vGrid, vPov,'r-','LineWidth',1.5);
title(['Overschrijdingskans basisduur ', sNaam]);
xlabel('Afvoer [m^3/s]');
ylabel('Overschrijdingskans [-]');
legend('Zonder onzekerheid', 'Incl. onzekerheid','Location', 'Southwest');
ylim([1e-7, 1]);
print(gcf,'-dpng',['Figuren\afvoer_',sNaam,'_maand.png']);

close all

% Figuur overschrijdingsfrequentie, zonder en met onzekerheid:
figure
semilogx( 1./(6*kPov), kGrid,'b-','LineWidth',1.5);
grid on; hold on
semilogx(1./(6*vPov),vGrid, 'r-','LineWidth',1.5);
title(['Overschrijdingsfrequentie ', sNaam]);
ylabel('Afvoer [m^3/s]')
xlabel('Terugkeertijd [jaar]')
legend('Zonder onzekerheid', 'Incl. onzekerheid','Location', 'Southeast')
xlim([1, 1e5])
%ylim([0, 25000])
print(gcf,'-dpng',['Figuren\afvoer_',sNaam,'_jaar.png']);

% Voor Lobith of Borgharen dezelfde figuur, maar nu met toegeleverde gegevens:
if keuzeStation == 1
    AA = load(infileLobithSpreadsheet);
    Treeks = AA(:,1);    Kreeks = AA(:,2);    Vreeks = AA(:,3);
elseif keuzeStation == 3
    AA = load(infileBorgharenSpreadsheet);
    Treeks = AA(:,1);    Kreeks = AA(:,2);    Vreeks = AA(:,3);
end

if keuzeStation == 1 || keuzeStation == 3
    
    figure
    semilogx( 1./(6*kPov), kGrid,'b-');
    grid on; hold on
    semilogx(1./(6*vPov),vGrid, 'r-');
    semilogx(Treeks, Kreeks, 'k-.', 'Linewidth', 2)
    semilogx(Treeks, Vreeks, 'g-.', 'Linewidth', 2)
    title(['Overschrijdingsfrequentie ', sNaam]);
    ylabel('Afvoer [m^3/s]')
    xlabel('Terugkeertijd [jaar]')
    legend('Zonder onzekerheid', 'Incl. onzekerheid', 'Toegeleverd zonder onz.','Toegeleverd incl. onz.','Location', 'Southeast')
    xlim([1, 1e5])
%     ylim([5000, 25000])
    print(gcf,'-dpng',['Figuren\afvoer_',sNaam,'_jaar_vergelijking.png']);
    
end

%% Export data naar Hydra-NL format

addpath('..\');

vPov_kort = exp(interp1(vGrid,log(vPov),kInv));
X         = [kInv,vPov_kort];

wegschrijven_data('afvoer',sNaam,X);