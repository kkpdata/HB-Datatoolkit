%==========================================================================
% Script uitintegreren onzekerheid zeewaterstand
%
% De invoer is hier in de vorm van een tabel gegeven.
%
% Door: Chris Geerse
% PR3216.10
% Datum: november 2015.
%
%==========================================================================

%% Invoer

clc
clear all
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

% Bestand met condionele overschijdingskansen ZW t/m N (tabelvorm):
%infile_PovInv = 'ConditionelePovZeestandenMM_12u_1985.txt';
infile_PovInv = 'CondPovMaasmond_12u_zichtjaar1985_2017.txt';

mTabel        = load(infile_PovInv);

% Geef naam van locatie op:
sNaam         = 'Maasmond';
disp(['Analyse voor ',sNaam]);

% Richtingskansen uit Hydra-NL:
infile_Pr     = 'Richtingskansen_Schiphol_2017.txt';

mInv  = mTabel(:, 1);

% Grid voor m-waarden (zonder onzekerheid):
mMin  = min(mInv);
mSt   = 0.005;   %Moet heel klein (<= 0.01) zijn voor nauwkeurig uitintegreren.
mMax  = 8;
mGrid = [mMin : mSt: mMax]';

% Grid voor v-waarden (met onzekerheid):
vSt   = mSt;
vMin  = mMin;
vMax  = mMax;
vGrid = [vMin : vSt: vMax]';

%% Analyse voor 7 windrichtingen

for r = 1:7

    % Inlezen invoer bij richting r (laat zeespiegelstijging weg)
    
    % Inlezen overschrijdingskansen:
    mPovInv{r} = mTabel(:, r + 1);

    % Maak mPovInv strikt dalend, om latere interpolatieproblemen te voorkomen.
    mPovInv{r} = mPovInv{r} + [numel(mPovInv{r}) : -1 : 1]'* 1e-13/numel(mPovInv{r});
    mPovInv{r} = mPovInv{r}/mPovInv{r}(1);   %Maak maximum gelijk aan 1

    % Bepaal richtingskans:
    PrInv      = load(infile_Pr);
    Pr{r}      = PrInv(r + 9, 2);

    [rLab{r}]  = bepaalLabelRichting(r);

    % Uitintegreren onzekerheid (additief model)
    
    % Model (V = inclusief onzekerheid):
    % V = M + Y.
    % Y ~ N(mMu, mSig).

    % Bepaal mu en sigma als functie van m:
    [mMu, mSig] = bepaalOnzekerheidNormaal(mGrid);
    
    % Bepaal ovkansen op mGrid:
    mPov{r}     = exp( interp1(mInv, log(mPovInv{r}), mGrid, 'linear', 'extrap') );

    % Bereken overschrijdingskansen van zeewaterstanden incl. onzekerheid:
    typeVerdeling = 'normaal';
    mEps          = 0;
    [vPov{r}]     = bepaalUitgeintegreerdeOvkansen(mGrid, mPov{r}, typeVerdeling, mMu, mSig, mEps, vGrid);
    
%     % Figuur overschrijdingskans, zonder en met onzekerheid:
%     figure
%     semilogy(mGrid, mPov{r},'b-','LineWidth',1.5);
%     grid on; hold on
%     semilogy(vGrid, vPov{r},'r-','LineWidth',1.5);
%     title(['Conditionele overschrijdingskans zeewaterstand ', sNaam, ', r = ', rLab{r}]);
%     xlabel('Zeewaterstand [m+NAP]');
%     ylabel('Overschrijdingskans [-]');
%     legend('Zonder onzekerheid', 'Incl. onzekerheid');
%     ylim([1e-7, 1]);
%     print(gcf,'-dpng',['Figuren\',sNaam,'_',rLab{r},'_12uur.png']);

%    close all

    % Figuur overschrijdingsfrequentie/jaar, zonder en met onzekerheid:
    figure
    semilogx(1./(360*Pr{r}*mPov{r}), mGrid,'b-','LineWidth',1.5);
    grid on; hold on
    semilogx( 1./(360*Pr{r}*vPov{r}), vGrid, 'r-','LineWidth',1.5);
    title(['Conditionele overschrijdingsfrequentie zeewaterstand ', sNaam, ', r = ', rLab{r}]);
    ylabel('Zeewaterstand [m+NAP]');
    xlabel('Terugkeertijd [jaar]');
    legend('Zonder onzekerheid', 'Incl. onzekerheid','location', 'SouthEast');
    xlim([1, 1e6]);
    ylim([1, 7])
    print(gcf,'-dpng',['Figuren\',sNaam,'_',rLab{r},'_jaar.png']);
    
end

% vPov = cell2mat(vPov);
% 
% %% Export data naar Hydra-NL format
% 
% for r = 1:7
%     
%     vPov_kort(:,r) = interp1(mGrid,vPov(:,r),mInv);
%     
% end
% 
% X = [mInv,vPov_kort];
% 
% wegschrijven_data('zeewaterstand_Tabel',sNaam,X);