%==========================================================================
% Script uitintegreren onzekerheid wind
%
% Door: Chris Geerse en Karolina Wojciechowska
% 
% Datum: feb. 2016.
% Aangepast: aug 2017, voor PR3556.10
%
%==========================================================================

%% Invoer

clc
clear
close all
addpath 'Hulproutines\' 'Invoer\' '..\';

% Windrichting:
% 1 = NNO
% ...
% ...
% 16 = N

% NNO NO ONO O	OZO	ZO	ZZO	Z	ZZW	ZW	WZW	W	WNW	NW	NNW N
% 1	  2	 3	 4	5	6	7	8	9	10	11	12	13	14	15	16

% Station
% 1 = Vlissingen (zonder winddrag)
% 2 = Vlissingen (winddrag)

keuzeStation = 1;

% Windbestand:
if keuzeStation == 1
    
    sNaam = 'Vlissingen';
    noR   = 16;
    indR  = [1:16]; %NNO als begin
    r_fig = {'NNO','NO','ONO','O','OZO','ZO','ZZO','Z','ZZW','ZW','WZW','W','WNW','NW','NNW','N'};
    
    ovkansenWind = load('Ovkanswind_Vlissingen_16sectoren_2017.txt'); %begin is NNO
            
    % Parameters Y:
    mu  = 1;
    sig = 0.043;
    
elseif keuzeStation==2
    
    sNaam = 'Vlissingen met winddrag';
    noR   = 16;
    indR  = [1:16]; %NNO als begin
    r_fig = {'NNO','NO','ONO','O','OZO','ZO','ZZO','Z','ZZW','ZW','WZW','W','WNW','NW','NNW','N'};
    
    ovkansenWind = load('Ovkanswind_Vlissingen_16sectoren_2017_metWindDrag.txt'); %begin is NNO


    % Parameters Y:
    mu  = 1;
    sig = 0.043;
    
end

disp(['Analyse voor ',sNaam,': alle windrichtingen, sigma = ',num2str(sig)]);


% Grid voor u-waarden:
uSt    = 0.1;
uMin   = 0;
uMax   = 55;
uGrid  = [uMin:uSt:uMax]';

% Grid voor y-waarden:
ySt   = sig/100;
yMin  = mu-5*sig;
yMax  = mu+5*sig;
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

ind_exp = [1:16]; %begin is NNO

% % Ter controle nog eens het invoerbestand wegschrijven:
% X = [uInv,uPovInv_kort(:,ind_exp)];
% wegschrijven_data('wind',[sNaam,'_2017'],sNaam,X,noR,0);

% Nu wegschrijven met onzekerheid
X = [uInv,uPovOnzeker_kort(:,ind_exp)];
wegschrijven_data('wind',[sNaam,'_16sectoren_2017_metOnzHeid'],sNaam,X,noR,1);

%% Figuren

for r = 1:noR
    
    % Figuur overschrijdingskans, zonder en met onzekerheid
    figure
    semilogy(uInv,uPovInv{r},'b-','LineWidth',1.5);
    grid on; hold on
    semilogy(uGrid,uPovOnzeker{r},'r-','LineWidth',1.5);
    hold on
%     semilogy(uInv,uPovInv_kort(:,r),'bo');
    hold on
%     semilogy(uInv,uPovOnzeker_kort(:,r),'ro');
    title(['Conditionele kansen windsnelheid ',sNaam,', r = ', r_fig{r}],'interpret','none');
    xlabel('Windsnelheid [m/s]');
    ylabel('Overschrijdingskans [-]');
    legend('Zonder onzekerheid', 'Incl. onzekerheid');
    ylim([1e-8, 1])
    xlim([0,42])
%    print(gcf,'-dpng',['Figuren\windsnelheid_',sNaam,'_r_',num2str(r),'_',r_fig{r},'.png']);

end

