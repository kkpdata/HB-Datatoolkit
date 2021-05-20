%==========================================================================
% Script uitintegreren onzekerheid wind
%
% Door: Chris Geerse en Karolina Wojciechowska
%
% Datum: feb. 2016.
%
%==========================================================================

%% Invoer

clc
clear
close all
addpath 'Hulproutines\' 'Invoer\' '..\';

% Windrichting:
% 1 = N
% 2 = NNO
% ...
% ...
% 16 = NNW

% N	NNO	NO	ONO	O	OZO	ZO	ZZO	Z	ZZW	ZW	WZW	W	WNW	NW	NNW
% 1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16

% Station
% 1 = Schiphol
% 2 = Deelen
% 3 = Vlissingen
% 4 = Schiphol Volker

keuzeStation = 3;

% Windbestand:
if keuzeStation==1
    
    sNaam = 'Schiphol';
    noR   = 16;
    indR  = [16,1:15]; %Noord eerst
    r_fig = {'N','NNO','NO','ONO','O','OZO','ZO','ZZO','Z','ZZW','ZW','WZW','W','WNW','NW','NNW'};
    
    load('Transform_12r_Naar_16r\Wind_Schiphol_2017_WFREQ.mat'); %begin is Noord
    
    ovkansenWind = [uDeltares',uPov(:,indR)];
    clear uPov
    
    infile_Pr           = 'Richtingskansen_Schiphol_2017beginN.txt';
    
    
    % Parameters Y:
    mu  = 1;
    sig = 0.047;
    
elseif keuzeStation==2
    
    sNaam  = 'Deelen';
    noR    = 16;
    indR  = [16,1:15]; %Noord eerst
    r_fig = {'N','NNO','NO','ONO','O','OZO','ZO','ZZO','Z','ZZW','ZW','WZW','W','WNW','NW','NNW'};
    
    load('Transform_12r_Naar_16r\Wind_Deelen_2017_WFREQ.mat'); %begin is Noord
    
    ovkansenWind = [uDeltares',uPov(:,indR)];
    clear uPov
    
    infile_Pr           = 'Wind directions Deelen 16 directionsBeginN.txt';
        
    % Parameters Y:
    mu  = 1;
    sig = 0.046;
    
elseif keuzeStation==3
    
    infileWindsnelheid  = 'Wind speed Vlissingen - wl VL.txt';
    sNaam               = 'Vlissingen';
    noR                 = 12;
    r_fig               = {'0','30','60','90','120','150','180','210','240','270','300','330'};
    
    ovkansenWind = load(infileWindsnelheid); %begin is Noord
    
    % Parameters Y:
    mu  = 1;
    sig = 0.043;
    
elseif keuzeStation==4
    
    sNaam = 'Schiphol (Volkerfac)'; %met Volkerfactor
    noR   = 16;
    indR  = [16,1:15]; %Noord eerst
    r_fig = {'N','NNO','NO','ONO','O','OZO','ZO','ZZO','Z','ZZW','ZW','WZW','W','WNW','NW','NNW'};
    
    load('Transform_12r_Naar_16r\Wind_Schiphol_2017_WFREQ.mat'); %begin is Noord
    
    ovkansenWind = [uDeltares',uPovV(:,indR)];
    clear uPov uPovV
    
    % Parameters Y:
    mu  = 1;
    sig = 0.047;
    
end

disp(['Analyse voor ',sNaam,': alle windrichtingen, sigma = ',num2str(sig)]);

% Correctie
if keuzeStation==3
    ovkansenWind(2,13) = 0.999;
end

% Grid voor u-waarden:
uSt    = 0.1;
uMin   = 0;
uMax   = 42;
uGrid  = [uMin:uSt:uMax]';

% Grid voor y-waarden:
ySt   = sig/100;
yMin  = mu-4*sig;
yMax  = mu+4*sig;
yGrid = [yMin:ySt:yMax]';

%% Analyse voor alle windrichtingen

for r = 1:noR
    
    % Inlezen overschrijdingskansen wind bij richting r
    uInv       = ovkansenWind(:,1);
    uPovInv{r} = ovkansenWind(:,r+1);
    
    % Uitintegreren onzekerheid (multiplicatief model, truncated)
    % Model:
    % V_incl = Vexcl * Y.
    % Y ~ N(1, sig).
    % NB. Verwaarloos de voorwaarde Y > 0
    
    % Bereken overschrijdingskansen van windsnelheden incl. onzekerheid
    
    % Initialisatie:
    uPovOnzeker{r} = zeros(length(uGrid),1);
    
    clear klassekans Som
    
    for i = 1:length(uGrid)
        
        % Bereken overschrijdingskans uGrid(i), incl. onzekerheid:
        PovHulp{r}        = exp( interp1(uInv, log(uPovInv{r}), uGrid(i)./yGrid, 'linear', 'extrap') );
        klassekans        = normpdf(yGrid, mu, sig) * ySt;  %kans uit normale verdeling voor Y
        Som               = PovHulp{r}' * klassekans;       % waarde van de integraal
        
        uPovOnzeker{r}(i) = Som;
        
    end
    
end

%% Export data naar Hydra-NL format

for i = 1:noR
    
    uPovInv_kort(:,i)     = exp(interp1(uInv,log(uPovInv{i}),uInv));
    uPovOnzeker_kort(:,i) = exp(interp1(uGrid,log(uPovOnzeker{i}),uInv));
    uPovOnzeker_kort(1,i) = 1;
    
end

if noR==12
    ind_exp = [2:12,1]; %Noord aan het eind
elseif noR==16
    ind_exp = [2:16,1]; %Noord aan het eind
end

X = [uInv,uPovInv_kort(:,ind_exp)];
wegschrijven_data('wind',[sNaam,'_2017'],sNaam,X,noR,0);

X = [uInv,uPovOnzeker_kort(:,ind_exp)];
wegschrijven_data('wind',[sNaam,'_2017_metOnzHeid'],sNaam,X,noR,1);

%% Figuren

for r = 1%1:noR
    
    % Figuur overschrijdingskans, zonder en met onzekerheid
    figure
    semilogy(uInv,uPovInv{r},'b-','LineWidth',1.5);
    grid on; hold on
    semilogy(uGrid,uPovOnzeker{r},'r-','LineWidth',1.5);
    hold on
    %title(['Conditionele overschrijdingskans windsnelheid ',sNaam,' (',num2str(noR),'), r = ', r_fig{r}],'interpret','none');
    title(['Conditionele overschrijdingskans windsnelheid ',sNaam,', r = ', r_fig{r}],'interpret','none');
    xlabel('Windsnelheid [m/s]');
    ylabel('Overschrijdingskans [1/12 uur]');
    legend('Zonder onzekerheid', 'Incl. onzekerheid');
    ylim([1e-6, 1])
    print(gcf,'-dpng',['Figuren\windsnelheid_',sNaam,'_r_',num2str(r),'_',r_fig{r},'.png']);
    
    
    %% Figuur overschrijdingsfrequentie, zonder en met onzekerheid:
    %
    Tkwantiel  = 1e4;
    
    PrInv   = load(infile_Pr);
    if r <= 16
        Pr      = PrInv(r, 2);
    elseif rKeuze == 17  %omni
        Pr = 1;
    end
    % Label windrichting:
    rLab = r_fig{r};
    
    X =  1./(360*Pr*uPovInv{r});
    X = X + 1e-13*[1: 1: numel(X)]';
    
    uTkwantiel = interp1( X, uInv, Tkwantiel, 'linear', 'extrap');
    
    figure
    semilogx(1./(360*Pr*uPovInv{r}), uInv, 'b-.','LineWidth',1.5);
    hold on
    semilogx(1./(360*Pr*uPovOnzeker{r}), uGrid, 'r-.','LineWidth',1.5);
    grid on
    %title(['Windsnelheid ',sNaam,', r = ', rLab, '; T = ', num2str(Tkwantiel),': u =  ', num2str(uTkwantiel),' m/s' ]);
    title(['Windsnelheid ',sNaam,', r = ', rLab]);
    ylabel('Windsnelheid [m/s]');
    xlabel('Terugkeertijd [jaar]');
    legend('Zonder onzekerheid', 'Incl. onzekerheid', 'location', 'southeast');
    xlim([1, 1e5])
    
    
end
