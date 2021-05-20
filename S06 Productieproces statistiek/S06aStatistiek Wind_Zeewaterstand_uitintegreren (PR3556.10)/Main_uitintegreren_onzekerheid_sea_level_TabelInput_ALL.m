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
clear
close all
addpath 'Hulproutines\' 'Invoer\';



% Bestand met condionele overschijdingskansen NNO t/m N (tabelvorm):
infile_PovInv = 'CondPovOS11_16sectoren_12u_zichtjaar2017.txt';

mTabel        = load(infile_PovInv);

% Geef naam van locatie op:
sNaam         = 'OS11';
disp(['Analyse voor ',sNaam]);

% Richtingskansen uit Hydra-NL:
infile_Pr     = 'KansenWindrichting_16sectoren_OS_2017.txt';

mInv  = mTabel(:, 1);

% Grid voor m-waarden (zonder onzekerheid):
mMin  = min(mInv);
mSt   = 0.005;   %Moet heel klein (<= 0.01) zijn voor nauwkeurig uitintegreren.
mMax  = 9;
mGrid = [mMin : mSt: mMax]';

% Grid voor v-waarden (met onzekerheid):
vSt   = mSt;
vMin  = mMin;
vMax  = mMax;
vGrid = [vMin : vSt: vMax]';

rLab = {'NNO','NO','ONO','O','OZO','ZO','ZZO','Z','ZZW','ZW','WZW','W','WNW','NW','NNW','N'};


%% Analyse voor alle windrichtingen NNO t/m N

for r = 1 : 16 % NNO t/m N
    
    % Inlezen invoer bij richting r (laat zeespiegelstijging weg)
    
    % Inlezen overschrijdingskansen:
    mPovInv{r} = mTabel(:, r + 1);
    
    % Maak mPovInv strikt dalend, om latere interpolatieproblemen te voorkomen.
    mPovInv{r} = mPovInv{r} + [numel(mPovInv{r}) : -1 : 1]'* 1e-15/numel(mPovInv{r});
    mPovInv{r} = mPovInv{r}/mPovInv{r}(1);   %Maak maximum precies gelijk aan 1 (hier geloof ik onnodig)
    
    % Bepaal richtingskans:
    PrInv      = load(infile_Pr);
    Pr{r}      = PrInv(r, 2);
    
    
    % Uitintegreren onzekerheid (additief model)
    
    % Model (V = inclusief onzekerheid):
    % V = M + Y.
    % Y ~ N(mMu, mSig).
    
    % Bepaal mu en sigma als functie van m:
    [mMu, mSig] = bepaalOnzekerheidNormaal(mGrid,sNaam);
    %[mMu, mSig] = bepaalOnzekerheidNormaal(mGrid);
    
    % Bepaal ovkansen op mGrid:
    mPov{r}     = exp( interp1(mInv, log(mPovInv{r}), mGrid, 'linear', 'extrap') );
    
    % Bereken overschrijdingskansen van zeewaterstanden incl. onzekerheid:
    typeVerdeling = 'normaal';
    mEps          = 0;
    [vPov{r}]     = bepaalUitgeintegreerdeOvkansen(mGrid, mPov{r}, typeVerdeling, mMu, mSig, mEps, vGrid);
    
    % Maak nieuwe vPov{r} als maximum van mPov{r} en vPov{r}, om cond. kans bij 1 te laten beginnen:
    vPov{r} = max( vPov{r}, mPov{r} );
    
    
    
%     % Figuur overschrijdingskans, zonder en met onzekerheid:
%     figure
%     semilogy(mGrid, mPov{r},'b-','LineWidth',1.5);
%     grid on; hold on
%     semilogy(vGrid, vPov{r},'r-','LineWidth',1.5);
%     title(['Conditionele kans zeewaterstand ', sNaam, ', r = ', rLab{r}]);
%     xlabel('Zeewaterstand [m+NAP]');
%     ylabel('Overschrijdingskans [-]');
%     legend('Zonder onzekerheid', 'Incl. onzekerheid');
%     ylim([1e-12, 2]);
%     xlim([1,8])
%     %print(gcf,'-dpng',['Figuren\',sNaam,'_',rLab{r},'_12uur.png']);
    
    %    close all
    
        % Figuur overschrijdingsfrequentie/jaar, zonder en met onzekerheid:
        figure
        semilogx(1./(360*Pr{r}*mPov{r}), mGrid,'b-','LineWidth',1.5);
        grid on; hold on
        semilogx( 1./(360*Pr{r}*vPov{r}), vGrid, 'r-','LineWidth',1.5);
        title(['Overschrijdingsfrequentie zeewaterstand ', sNaam, ', r = ', rLab{r}]);
        ylabel('Zeewaterstand [m+NAP]');
        xlabel('Terugkeertijd [jaar]');
        legend('Zonder onzekerheid', 'Incl. onzekerheid','location', 'SouthEast');
        xlim([1, 1e10]);
        ylim([1, 8])
%     % %    print(gcf,'-dpng',['Figuren\',sNaam,'_',rLab{r},'_jaar.png']);
    
end





vPov = cell2mat(vPov);

%% Export data naar Hydra-NL format

for r = 1:16
    
    vPov_kort(:,r) = exp( interp1(mGrid, log(vPov(:,r)), mInv, 'linear', 'extrap') );
    
end

X = [mInv,vPov_kort];

%VB: CondPovOS11_12u_zichtjaar2017.txt
fid = fopen('CondPovOS11_16sectoren_12u_2017_metOnzHeid.txt','wt');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','* Conditionele overschrijdingskans zeewaterstand OS11, zichtjaar 2017, per windrichting, voor 12-uursperioden.');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','* Door:    Chris Geerse van HKV lijn in water');
fprintf(fid,'%s\n','* Project: PR3556.10');
fprintf(fid,'%s\n','* Datum:   augustus 2017');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','* m/m+NAP   NNO            NO             ONO            O              OZO            ZO             ZZO            Z              ZZW            ZW             WZW            W              WNW            NW             NNW            N');
fprintf(fid,['%6.2f',repmat('      %1.3e',1,16),' \n'],X');   %geeft wel lege regel aan het eind!

fclose all;

%close all

