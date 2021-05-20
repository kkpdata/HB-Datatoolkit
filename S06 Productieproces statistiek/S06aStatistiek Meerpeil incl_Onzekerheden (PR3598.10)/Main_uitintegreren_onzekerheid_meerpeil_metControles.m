%==========================================================================
% Script uitintegreren onzekerheid meerpeilen
%
% De invoer is hier in de vorm van een tabel gegeven.
%
% Door: Chris Geerse
% PR3216.10
% Datum: november 2015.
% Aanpassing voor PR3598, aug 2017. VZM naar B = 30 dagen.
%
% Zie als toelichting par. 3.2 en par. 3.6.3 uit het rapport [Geerse, 2016]:
% Werkwijze uitintegreren onzekerheden basisstochasten voor Hydra-NL.
% Afvoeren, meerpeilen, zeewaterstanden en windsnelheden – Update februari 2016.
% C.P.M. Geerse. PR3216.10. HKV Lijn in Water, februari 2016. In opdracht van RWS - WVL.
%
%==========================================================================

%% Invoer

clc
clear
close all
addpath 'Hulproutines\' 'Invoer\';

% Bestand met overschijdingskansen (tabelvorm):
infileIJsselmeer = 'Water level IJssel lake.txt';
infileMarkermeer = 'Water level Marker lake.txt';
infileVRM        = 'Ovkans_Veluwerandmeer_piekmeerpeil_v01.txt';

%infileVZM        = 'Ovkans_Volkerakzoommeer_piekmeerpeil_PR3598.10.txt';   %in rapport 17 aug
infileVZM        = 'Ovkans_VZM_piekmeerpeil_BER-VZM.txt';                   % geeft exact dezelfde lijn als in rapport 17 aug

infileGRV        = 'Ovkans_Grevelingenmeer_piekmeerpeil_v01.txt';

%% In dit programma alleen keuze 4 gebruiken,
% Geef gewenste meer op:
% 1 = IJsselmeer
% 2 = Markermeer
% 3 = Veluwerandmeer (VRM)
% 4 = Volkerak-Zoommeer (VZM)
% 5 = Grevelingen
keuzeStation = 4;   %alleen keuze 4 nemen!!!!

switch keuzeStation
    case 1   % IJM, B = 30 dagen
        OmrekeningKansNaarFreq = 6;
    case 2   % MM,  B = 60 dagen
        OmrekeningKansNaarFreq = 3;
    case 3   % VRM, B = 60 dagen, zie PR1322.30
        OmrekeningKansNaarFreq = 3;
    case 4   % VZM, B = 30 dagen,          PR3598.10
                                           OmrekeningKansNaarFreq = 6;
    case 5   % GRV, B = 10 dagen, zie PR1564.14
        OmrekeningKansNaarFreq = 18;
end

% Inlezen invoer bij gekozen richting (laat zeespiegelstijging weg):
[sNaam, typeVerdeling, TgrensOnzHeid, ovkansenMeerpeil, sSt, sMax, pCI]= bepaalStationGegevensMeerpeil(...
    keuzeStation, infileIJsselmeer, infileMarkermeer, infileVRM, infileVZM, infileGRV);

disp(['Analyse voor ',sNaam]);

sInv    = ovkansenMeerpeil(:,1);
sPovInv = ovkansenMeerpeil(:,2);

% Grid voor s-waarden
sMin    = min(sInv);
sGrid   = [sMin : sSt: sMax]';

% Bepaal ovkansen op sGrid
sPov    = exp( interp1( sInv, log(sPovInv), sGrid, 'linear', 'extrap') );

%% Uitintegreren onzekerheid (additief model)

% Model (V = inclusief onzekerheid):
% V = M + Y.
% Y ~ ln N(mMuNormaal, mSigNormaal), wel met nog een verschuivingsterm daarbij.

% Grid voor v-waarden (met onzekerheid); kies in dit programma dus sGrid
% zelfde als vGrid
vGrid = sGrid;

% Bepaal mu, sigma en Eps als functie van s (A is hulpgrootheid):
% sMu, sSig, sEps zijn de parameters van de verdeling Y uit par 3.6.3 van
% rapport [Geerse, 2016], PR3262.10.
%
% Ook een verbrede versie van sig om onzekerheid in streefpeil pragmatisch
% mee te nemen.
[sMu, sSig, sSigBreed, sEps, A, Abreed] = bepaalOnzekerheidMeerpeil(keuzeStation, sGrid);

% Forceer dat sEps niet >= 0 kan worden.
Ind       = find(sEps > -1e-8);
sEps(Ind) = -1e-8;

figure
plot(A(:,1),A(:,3),'b-')
hold on; grid on
plot(Abreed(:,1),Abreed(:,3),'r-')
xlabel('Meerpeil, m+NAP')
ylabel('Standaarddeviatie lognormale verd.')
legend('Default', 'Verbreed')

% sNaam
% disp('Info A')
% disp('A: meerpeilen en sigma bij T = 10 t/m 10^5')
% [A(:,1), A(:,3)]
sNaam
disp('Info Abreed')
disp('Abreed: meerpeilen en sigma bij T = 10 t/m 10^5')
[Abreed(:,1), Abreed(:,3)]


% Bereken overschrijdingskansen incl. onzekerheid:
[vPov]   = bepaalUitgeintegreerdeOvkansen(sGrid, sPov, typeVerdeling, sMu, sSig,      sEps, vGrid);
[vPovBr] = bepaalUitgeintegreerdeOvkansen(sGrid, sPov, typeVerdeling, sMu, sSigBreed, sEps, vGrid);

%% Zorg dat je met onzekerheid niet lager uitkomt dan zonder onzekerheid:
vPov(vPov < sPov)     = sPov(vPov < sPov);
vPovBr(vPovBr < sPov) = sPov(vPovBr < sPov);



%% Bepaal onzekerheidsbanden
[bandOnder,   bandBoven]   = bepaalOnzekerheidsbanden(sGrid, typeVerdeling, sSig,      sEps, pCI);
[bandOnderBr, bandBovenBr] = bepaalOnzekerheidsbanden(sGrid, typeVerdeling, sSigBreed, sEps, pCI);

%% Figuren zonder verbrede banden

% Figuur overschrijdingskans, zonder en met onzekerheid:
figure
semilogy(sGrid, sPov,'b-','LineWidth',1.5);
grid on
title(['Overschrijdingskans ', sNaam]);
xlabel('Meerpeil [m+NAP]');
ylabel('Overschrijdingskans [-]');
% ylim([1e-8, 1]);
% xlim([-0.3,0.3])

figure
semilogy(sGrid, sPov,'b-','LineWidth',1.5);
grid on; hold on
semilogy(vGrid, vPov,'r-','LineWidth',1.5);
semilogy(bandOnder, sPov,'k--','LineWidth',1.5);
semilogy(bandBoven, sPov,'k--','LineWidth',1.5);
semilogy(sEps +sGrid, sPov,'k--','LineWidth',1.5);  %als check dat de verdeling bij streefpeil begint
title(['Overschrijdingskans ', sNaam]);
xlabel('Meerpeil [m+NAP]');
ylabel('Overschrijdingskans [-]');
legend('Zonder onzekerheid', 'Incl. onzekerheid',['Betrouwbaarheidsbanden ',num2str(100*pCI),'%'] );
ylim([1e-10, 1]);
xlim([-0.4,2.5])

% Figuur overschrijdingsfrequentie/jaar, zonder en met onzekerheid:
figure
semilogx(1./(OmrekeningKansNaarFreq*sPov),sGrid,'b-','LineWidth',1.5);
grid on; hold on
title(['Overschrijdingsfrequentie ', sNaam]);
xlabel('Terugkeertijd [jaar]')
ylabel('Meerpeil [m+NAP]');
xlim([1, 1e5]);
ylim([-0.1, 0.3])

% close all

figure
semilogx(1./(OmrekeningKansNaarFreq*sPov),sGrid,'b-','LineWidth',1.5);
grid on; hold on
semilogx(1./(OmrekeningKansNaarFreq*vPov),vGrid,'r-','LineWidth',1.5);
semilogx(1./(OmrekeningKansNaarFreq*sPov),bandOnder,'k--','LineWidth',1.5);
semilogx(1./(OmrekeningKansNaarFreq*sPov),bandBoven,'k--','LineWidth',1.5);
title(['Overschrijdingsfrequentie ', sNaam]);
xlabel('Terugkeertijd [jaar]')
ylabel('Meerpeil [m+NAP]');
legend('Zonder onzekerheid', 'Incl. onzekerheid',['Betrouwbaarheidsbanden ',num2str(100*pCI),'%'],'location', 'NorthWest');
xlim([1, 1e5]);
ylim([-0.40, 1.6])



%% Figuren met verbrede banden

% Figuur overschrijdingskans, zonder en met onzekerheid (incl. banden):
figure
semilogy(sGrid,       sPov,    'b-','LineWidth',1.5);
grid on; hold on
semilogy(bandOnder,   sPov,    'r--','LineWidth',1.5);
semilogy(vGrid,       vPov,    'r-','LineWidth',1.5);
semilogy(bandOnderBr, sPov,    'g--','LineWidth',1.5);
semilogy(vGrid,       vPovBr,  'g-','LineWidth',1.5);
semilogy(bandBoven,   sPov,    'r--','LineWidth',1.5);
semilogy(bandBovenBr, sPov,    'g--','LineWidth',1.5);
% Als check dat de verdeling bij streefpeil begint:
semilogy(sEps +sGrid, sPov,    'k--','LineWidth',1.5);  
title(['Overschrijdingskans ', sNaam]);
xlabel('Meerpeil [m+NAP]');
ylabel('Overschrijdingskans [-]');
legend('Zonder onzekerheid', ['Betrouwbaarheidsbanden ',num2str(100*pCI),'%'],'Incl. onzekerheid', 'Verbrede banden','Incl. onzheid brede banden');
ylim([1e-10, 1]);
xlim([-0.4,3.5])








%close all
% 
% % Figuur overschrijdingsfrequentie/jaar, zonder en met onzekerheid (incl. banden):
figure
semilogx(1./(OmrekeningKansNaarFreq*sPov),   sGrid,      'b-','LineWidth',1.5);
grid on; hold on
semilogx(1./(OmrekeningKansNaarFreq*sPov),   bandOnder,  'r--','LineWidth',1.5);
semilogx(1./(OmrekeningKansNaarFreq*vPov),   vGrid,      'r-','LineWidth',1.5);
semilogx(1./(OmrekeningKansNaarFreq*sPov),   bandOnderBr,'g--','LineWidth',1.5);
semilogx(1./(OmrekeningKansNaarFreq*vPovBr), vGrid,      'g-','LineWidth',1.5);
semilogx(1./(OmrekeningKansNaarFreq*sPov),   bandBoven,  'r--','LineWidth',1.5);
semilogx(1./(OmrekeningKansNaarFreq*sPov),   bandBovenBr,'g--','LineWidth',1.5);
title(['Overschrijdingsfrequentie ', sNaam]);
xlabel('Terugkeertijd [jaar]')
ylabel('Meerpeil [m+NAP]');
legend('Zonder onzekerheid',['Betrouwbaarheidsbanden ',num2str(100*pCI),'%'], 'Incl. onzekerheid', 'Verbrede banden','Incl. onzheid brede banden','location', 'NorthWest');
xlim([1, 1e5]);
ylim([-0.20, 1.6])


%% Bepaal effect van de verbreding in meters

% als functie van sPov:
Extrabreedte = (bandBovenBr - bandBoven) + (bandOnder - bandOnderBr);

figure
semilogx(sPov, Extrabreedte,  'k--','LineWidth',1.5);
grid on; hold on
title(['Extra breedte van de banden ', sNaam]);
xlabel('Overschrijdingskans [-]');
ylabel('Extra breedte')
xlim([1e-6,1])

figure
semilogx(1./(OmrekeningKansNaarFreq*sPov), Extrabreedte,  'k--','LineWidth',1.5);
grid on; hold on
title(['Extra breedte van de banden ', sNaam]);
xlabel('Terugkeertijd [jaar]');
ylabel('Extra breedte')
xlim([0.05, 10^6])


%==========================================================================
%% Wegschrijven van gegevens in termen van terugkeertijden 
% (tbv handleiding schematisatie door Robert Slomp)
%==========================================================================
% Met onzekerheden:

Treeks  = [10,25,50:50:1250, 1500, 1750, 2000:1000:20000, 30000:10000:100000]'; 
mpReeks = interp1( log(1./(OmrekeningKansNaarFreq*vPovBr)),vGrid, log(Treeks), 'linear', 'extrap');

Tabel = [Treeks, mpReeks];

figure
semilogx(Tabel(:,1),Tabel(:,2),'r--','LineWidth',1.5);
hold on
grid on
title(['Overschrijdingsfrequentie met onzekerheid', sNaam])
xlabel('Terugkeertijd, jaar')
ylabel('Meerpeil, m+NAP')
xlim([1, 1e5])
ylim([-0.20, 1.6])

%==========================================================================
%% Wegschrijven van gegevens in termen van overschrijdingskansen 
% (tbv invoer Hydra-NL)
%==========================================================================
% Met onzekerheden:

switch keuzeStation
    case 1   % IJM
        MpReeks  = [min(sInv): 0.01: 2.0]';
    case 2   % MM
        MpReeks  = [min(sInv): 0.01: 2.0]';
    case 3   % VRM
        MpReeks  = [-0.3, -0.27, -0.22,-0.1, -0.07, -0.05, 0 : 0.1: 1.8]';
    case 4   % VZM
%         MpReeks  = [-0.1, 0.07, 0.22, 0.3 : 0.1: 1.8]';
        MpReeks  = [0.05, 0.12, 0.22, 0.3 : 0.1: 1.8]';

    case 5   % GRV
        MpReeks  = [-0.23, -0.12, -0.11, -0.1 : 0.1 : 0.8]';
end

PovReeks     = exp(interp1( vGrid, log(vPovBr),MpReeks, 'linear', 'extrap'));

TabelHydraNL = [MpReeks, PovReeks]

% close all

% Figuur overschrijdingskans, zonder en met onzekerheid (incl. banden):
figure
semilogy(sGrid,       sPov,    'b-','LineWidth',1.5);
grid on; hold on
semilogy(vGrid,       vPovBr,  'go','LineWidth',1.5);
semilogy(MpReeks,     PovReeks,'k--','LineWidth',1.5);
% Als check dat de verdeling bij streefpeil begint:
semilogy(sEps +sGrid, sPov,    'k-','LineWidth',1.5);  
title(['Overschrijdingskans ', sNaam]);
xlabel('Meerpeil [m+NAP]');
ylabel('Overschrijdingskans [-]');
legend('Zonder onzekerheid','Incl. onzekerheid verbreed' ,'Invoerbestand (verbreed)');
ylim([1e-8, 1]);
xlim([-0.4,1.6])

close all


%% Inlezen 'oude' Hydra-Zoet gegevens inclusief onzekerheid
OvkansHydraNL_metOnzHeid2017 = load('Ovkans_Volkerakzoommeer_piekmeerpeil_2017_metOnzHeid.txt');

%% Inlezen 'oude' Hydra-Zoet gegevens inclusief onzekerheid (als check op reproduceerbaarheid)
OvkansHydraNL_metOnzHeid2017           = load('Ovkans_Volkerakzoommeer_piekmeerpeil_2017_metOnzHeid.txt');
BandenVerbreed_Basisduur20dagen_PR3280 = load('VZM_BandenVerbreed_Basisduur20dagen_PR3280.20.txt');
bandOnderBr3280     = BandenVerbreed_Basisduur20dagen_PR3280(:,1);
PovBandBreedOnder   = BandenVerbreed_Basisduur20dagen_PR3280(:,2);
bandBovenBr3280     = BandenVerbreed_Basisduur20dagen_PR3280(:,3);
PovBandBreedBoven   = BandenVerbreed_Basisduur20dagen_PR3280(:,4);


% % Figuur overschrijdingsfrequentie/jaar, zonder en met onzekerheid (incl. banden):
figure
semilogx(1./(OmrekeningKansNaarFreq*sPov),              sGrid,          'b-','LineWidth',1.5);
grid on; hold on
semilogx(1./(OmrekeningKansNaarFreq*vPovBr),            vGrid,          'g-','LineWidth',1.5);
semilogx(1./(OmrekeningKansNaarFreq*sPov),              bandOnderBr,    'g-','LineWidth',1);
semilogx(1./(9*OvkansHydraNL_metOnzHeid2017(:,2)),      OvkansHydraNL_metOnzHeid2017(:,1),      'k--','LineWidth',2.5);
semilogx(1./(OmrekeningKansNaarFreq*PovBandBreedOnder), bandOnderBr3280, 'k--','LineWidth',1);
% vanaf hier niet in legenda:
semilogx(1./(OmrekeningKansNaarFreq*sPov),              bandBovenBr,    'g-','LineWidth',1);
semilogx(1./(OmrekeningKansNaarFreq*PovBandBreedBoven), bandBovenBr3280,'k--','LineWidth',1);
title(['Overschrijdingsfrequentie ', sNaam]);
xlabel('Terugkeertijd [jaar]')
ylabel('Meerpeil [m+NAP]');
legend('Excl. onz.heid BER-VZM = PR1564',...
       'Incl. onz.heid  BER-VZM',...
       ['Banden BER-VZM ',num2str(100*pCI),'%'],...
       'Incl. onzekerheid huidige statistiek',...      %huidige = PR3280
       ['Banden huidige statistiek 95%'], 'location', 'NorthWest');
xlim([1, 1e6]);
ylim([0, 2.0])

%% Weergave uiteindelijke keuze banden
figure
plot(A(:,1),A(:,3),'b-')
hold on; grid on
plot(Abreed(:,1),Abreed(:,3),'r-')
xlabel('Meerpeil, m+NAP')
ylabel('Standaarddeviatie lognormale verd.')
legend('Default', 'Verbreed')

%% Nieuwe invoer + check met figuur

mReeks = [...
    0.05 
    0.12 
    0.22 
    0.30 
    0.40 
    0.50 
    0.60 
    0.70 
    0.80 
    0.90 
    1.00 
    1.10 
    1.20 
    1.30 
    1.40 
    1.50 
    1.60 
    1.70 
    1.80
    1.90
    2.00
    2.10
    2.20
    2.3
    2.4
    2.6
    2.7
    2.8
    2.9
    3.0];

PovOnzInvoerHNL = exp(interp1( vGrid, log(vPovBr), mReeks, 'linear', 'extrap') );

figure
semilogy(vGrid, vPovBr, 'b-','LineWidth',1.5);
grid on; hold on
semilogy(mReeks, PovOnzInvoerHNL, 'r--','LineWidth',1.5);
title(['Overschrijdingskans B = 30 dagen ', sNaam]);
ylabel('Ovkans')
xlabel('Meerpeil [m+NAP]');
legend('Alle mp','Hydra-NL invoer', 'location', 'southWest');
% xlim([0.1, 1e7]);

tabelHNL_nw = [mReeks, PovOnzInvoerHNL]
% ylim([-.10, 2.2])

