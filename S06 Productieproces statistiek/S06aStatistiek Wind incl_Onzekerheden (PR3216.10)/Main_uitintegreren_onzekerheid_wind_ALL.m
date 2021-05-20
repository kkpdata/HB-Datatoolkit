%==========================================================================
% Script uitintegreren onzekerheid wind
%
% Door: Chris Geerse en Karolina W
% PR...
% Datum: november 2015.
%
%
%==========================================================================

%% Invoer

clc
clear all
close all
addpath 'Hulproutines\' 'Invoer\';

% Windrichting:
% 1 = N
% 2 = NNO
% ...
% ...
% 16 = NNW

% N	NNO	NO	ONO	O	OZO	ZO	ZZO	Z	ZZW	ZW	WZW	W	WNW	NW	NNW
% 1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16

r_fig = {'N','NNO','NO','ONO','O','OZO','ZO','ZZO','Z','ZZW','ZW','WZW','W','WNW','NW','NNW'};

% Station
% 1 = Schiphol
% 2 = Deelen

keuzeStation = 2;

% Windbestand:
if keuzeStation==1
    
    % Kies juiste windbestand:   
    % infileWindsnelheid  = 'Wind speed Schiphol 16 directions.txt';
    infileWindsnelheid  = 'Ovkanswind_Schiphol_Volkerfactor_2017_beginIsNoord.txt';
    
    sNaam               = 'Schiphol';

    % Parameters Y:
    mu  = 1;
    sig = 0.047;
else
    
    infileWindsnelheid  = 'Wind speed Deelen 16 directions.txt';
    sNaam               = 'Deelen';

    % Parameters Y:
    mu  = 1;
    sig = 0.046;
    
end

disp(['Analyse voor ',sNaam,': alle windrichtingen, sigma = ',num2str(sig)]);

ovkansenWind = load(infileWindsnelheid);

% Grid voor u-waarden:
uSt    = 0.1;
uMin   = 0;
uMax   = 42;
uGrid  = [uMin : uSt: uMax]';

% Grid voor y-waarden:
ySt   = sig/100;
yMin  = mu - 4*sig;
yMax  = mu + 4*sig;
yGrid = [yMin : ySt: yMax]';





%% Analyse voor 16 windrichtingen

for r = 1:   16

    % Inlezen overschrijdingskansen wind bij richting r
    uInv       = ovkansenWind(:, 1);
    uPovInv{r} = ovkansenWind(:, r + 1);

    % Uitintegreren onzekerheid (multiplicatief model, truncated)
    % Model:
    % V_incl = Vexcl * Y.
    % Y ~ N(1, sig).
    % NB. Verwaarloos de voorwaarde Y > 0
    
    % Bereken overschrijdingskansen van windsnelheden incl. onzekerheid:

    % Initialisatie:
    uPovOnzeker{r} = zeros(length(uGrid), 1);

    clear klassekans Som
    
    for i = 1:length(uGrid)

        % Bereken overschrijdingskans uGrid(i), incl. onzekerheid:
        PovHulp{r}        = exp( interp1(uInv, log(uPovInv{r}), uGrid(i)./yGrid, 'linear', 'extrap') );
        klassekans        = normpdf(yGrid, mu, sig) * ySt;  %kans uit normale verdeling voor Y
        Som               = PovHulp{r}' * klassekans;       % waarde van de integraal

        uPovOnzeker{r}(i) = Som;
        
    end

    % Figuur overschrijdingskans, zonder en met onzekerheid:
    figure
    semilogy(uInv, uPovInv{r},'b-','LineWidth',1.5);
        semilogy(uInv, uPovInv{r},'g-','LineWidth',1.5);
    grid on; hold on
    semilogy(uGrid, uPovOnzeker{r},'r-','LineWidth',1.5);
    title(['Conditionele overschrijdingskans windsnelheid ',sNaam,' (16), r = ', r_fig{r}]);
    xlabel('Windsnelheid [m/s]');
    ylabel('Overschrijdingskans [-]');
    legend('Zonder onzekerheid', 'Incl. onzekerheid');
    ylim([1e-6, 1])
    print(gcf,'-dpng',['Figuren\windsnelheid_',sNaam,'_r_',num2str(r),'_',r_fig{r},'.png']);


end

uPovOnzeker = cell2mat(uPovOnzeker);


close all

%% Export data naar Hydra-NL format

for i = 1:16

    uPovOnzeker_kort(:,i) = exp(interp1(uGrid,log(uPovOnzeker(:,i)),uInv));

end

% X = [uInv,uPovOnzeker_kort];
% wegschrijven_data('wind',sNaam,X);
% 

