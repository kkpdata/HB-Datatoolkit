%==========================================================================
% Script uitintegreren onzekerheid zeewaterstand
%
% De invoer is hier in de vorm van een tabel gegeven.
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

% Kies gewenste richting:
% 1	 =	ZW
% 2	 =	WZW
% 3	 =	W
% 4	 =	WNW
% 5	 =	NW
% 6	 =	NNW
% 7	 =	N
% 8  =  omni
rKeuze = 8;

% Bestand met condionele overschijdingskansen ZW t/m N (tabelvorm):
infile_PovInv = 'CondPovMaasmond_12u_zichtjaar1985_2017.txt';

% Geef naam van locatie op:
sNaam         = 'Maasmond';
disp(['Analyse voor ',sNaam]);

% Richtingskansen uit Hydra-NL:
infile_Pr     = 'Richtingskansen_Schiphol_2017.txt';    

% Inlezen invoer bij gekozen richting (laat zeespiegelstijging weg)

% Inlezen overschrijdingskansen
mTabel  = load(infile_PovInv);
mInv    = mTabel(:, 1);
mPovInv = mTabel(:, rKeuze + 1);

% Maak mPovInv strikt dalend, om latere interpolatieproblemen te voorkomen.
mPovInv = mPovInv + [numel(mPovInv) : -1 : 1]'* 1e-13/numel(mPovInv);

% Bepaal richtingskans
PrInv   = load(infile_Pr);
if rKeuze <=7
    Pr      = PrInv(rKeuze + 9, 2);
elseif rKeuze == 8  %omni
    Pr = 1;
    %PrInv(10,2)+PrInv(11,2)+PrInv(12,2)+PrInv(13,2)+PrInv(14,2)+PrInv(15,2)+PrInv(16,2);
end
[rLab]  = bepaalLabelRichting(rKeuze);

%% Uitintegreren onzekerheid (additief model)

% Model (V = inclusief onzekerheid):
% V = M + Y.
% Y ~ N(mMu, mSig).

% Grid voor m-waarden (zonder onzekerheid)
mMin  = min(mInv);
mSt   = 0.005;   %Moet heel klein (<= 0.01) zijn voor nauwkeurig uitintegreren.
mMax  = 8;
mGrid = [mMin : mSt: mMax]';

% Grid voor v-waarden (met onzekerheid)
vSt   = mSt;
vMin  = mMin;
vMax  = mMax;
vGrid = [vMin : vSt: vMax]';

% Bepaal mu en sigma als functie van m:
[mMu, mSig] = bepaalOnzekerheidNormaal(mGrid);

% Bepaal ovkansen op mGrid
mPov        = exp( interp1(mInv, log(mPovInv), mGrid, 'linear', 'extrap') );

% Bereken overschrijdingskansen van zeewaterstanden incl. onzekerheid:

typeVerdeling = 'normaal';
mEps          = 0;
[vPov]        = bepaalUitgeintegreerdeOvkansen(mGrid, mPov, typeVerdeling, mMu, mSig, mEps, vGrid);

%% Figuren


% Figuur overschrijdingskans, zonder en met onzekerheid:
figure
semilogy(mGrid, mPov,'b-','LineWidth',1.5);
grid on; hold on
semilogy(vGrid, vPov,'r-','LineWidth',1.5);
title(['Conditionele overschrijdingskans zeewaterstand ', sNaam, ', r = ', rLab]);
xlabel('Zeewaterstand [m+NAP]');
ylabel('Overschrijdingskans [-]');
legend('Zonder onzekerheid', 'Incl. onzekerheid');
ylim([1e-8, 1]);

close all

% Figuur overschrijdingsfrequentie/jaar, zonder en met onzekerheid:
figure
semilogy(mGrid, 360*Pr*mPov,'b-','LineWidth',1.5);
grid on; hold on
semilogy(vGrid, 360*Pr*vPov,'r-','LineWidth',1.5);
%TreeksChbab
title(['Conditionele overschrijdingsfrequentie zeewaterstand ', sNaam, ', r = ', rLab]);
xlabel('Zeewaterstand [m+NAP]');
ylabel('Overschrijdingsfrequentie [1/jaar]');
legend('Zonder onzekerheid', 'Incl. onzekerheid');
ylim([1e-7, 1]);


% Figuur terugkeertijd, zonder en met onzekerheid voor omni:
[TreeksChbab, ovkansenZeeExOnzHeidChbab, ovkansenZeeMetOnzHeidChbab]= bepaalGegevensChbab2015();

if rKeuze == 8
    figure
    semilogx(1./(360*Pr*mPov), mGrid, 'b-','LineWidth',1.5);
    grid on; hold on
    semilogx(1./(360*Pr*vPov), vGrid, 'r-','LineWidth',1.5);
    semilogx(TreeksChbab, ovkansenZeeMetOnzHeidChbab, 'k--','LineWidth',1.5);
    title(['Omnidirectionele zeewaterstand ', sNaam, ', r = ', rLab]);
    ylabel('Zeewaterstand [m+NAP]');
    xlabel('Terugkeertijd [jaar]');
    legend('Zonder onzekerheid', 'Incl. onzekerheid','Incl. onzekerheid [Chbab, 2015]','location', 'SouthEast');
    xlim([1, 1e5]);

end