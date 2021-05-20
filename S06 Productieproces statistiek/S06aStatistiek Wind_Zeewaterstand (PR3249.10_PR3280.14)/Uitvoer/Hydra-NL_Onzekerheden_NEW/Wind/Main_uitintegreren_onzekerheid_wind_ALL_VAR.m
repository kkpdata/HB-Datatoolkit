%==========================================================================
% Script uitintegreren onzekerheid wind (variabele verdelingsparameters)
%
% Door: Karolina Wojciechowska
% Datum: november 2015.
%
% Dit script moet nog gecheckt worden door Chris
%==========================================================================

%% Invoer

%testje Chris

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

sNaam = 'Schiphol';
disp(['Analyse voor ',sNaam,': alle windrichtingen, variabele onzekerheid']);

r_fig = {'N','NNO','NO','ONO','O','OZO','ZO','ZZO','Z','ZZW','ZW','WZW','W','WNW','NW','NNW'};
T     = [2,10,50,100,500,1000,10000,100000];
%volgens voorlopige gegevens Deltares:
%sigma = [0.015,0.024,0.031,0.034,0.039,0.041,0.047,0.052]; 

% definitief
sigma = 100*[0.047,0.047,0.047,0.047,0.047,0.047,0.047,0.047];

figure
semilogx(T,sigma,'LineWidth',1.5);
grid on
xlabel('Terugkeertijd [jaar]');
ylabel('\sigma [m]');
title('Onzekerheid windsnelheid Schiphol OMNI');

% Windbestand
infileWindsnelheid  = 'Wind speed Schiphol 16 directions.txt';
ovkansenWind        = load(infileWindsnelheid);
infileWindrichting  = 'Wind directions Schiphol 16 directions.txt';
kansenR             = load(infileWindrichting);

%% Ov.kans windsnelheid incl. kans op een windrichting

u = ovkansenWind(:,1);

for r = 1:16
    
    uPov{r}   = ovkansenWind(:,r+1);
    uPov_r{r} = 180*2*uPov{r}*kansenR(r,2);
    
end

col = colormap(hsv(16));

figure
for r = 1:16
    
    semilogy(u,uPov_r{r},'color',col(r,:),'LineWidth',1.5);
    hold on
    
end
grid on
xlabel('Windsnelheid [m/s]');
ylabel('Overschrijdingsfrequentie [1/jaar]');
legend(r_fig,'location','EastOutside');
xlim([min(u) max(u)]);
ylim([10^-8 10^2]);
title({'Overschrijdingsfrequentie windsnelheid Schiphol';'incl. kans op een windrichting'});

%% Onzekerheid per windrichting

for r = 1:16
   
    uRel(:,r) = interp1(log(1./uPov_r{r}),u,log(T));
    
end

figure
for r = 1:16

    plot([0,sigma],[0;uRel(:,r)],'color',col(r,:),'LineWidth',1.5);
    hold on
    
end
grid on
xlabel('\sigma [m]');
ylabel('Windsnelheid [m/s]');
legend(r_fig,'location','EastOutside');
title('Onzekerheid per windrichting voor Schiphol');

%% Uitintegreren onzekerheid

uSt   = 0.01;
uMin  = 0.01;
uMax  = 55;
uGrid = [uMin:uSt:uMax]';

for r = 1:16

    uPovGrid{r} = exp(interp1(u,log(uPov{r}),uGrid,'linear','extrap'));
    uRelGrid{r} = interp1([0;uRel(:,r)],[0,sigma],uGrid(1:end-1),'linear','extrap');
    uDicht{r}   = uPovGrid{r}(1:end-1)-uPovGrid{r}(2:end);

    for i = 1:length(u)
    
       clear vPov_help
        
       vPov_help  = (1-normcdf(u(i)./uGrid(1:end-1),ones(length(uGrid(1:end-1)),1),uRelGrid{r})).*uDicht{r};
%        vPov_help  = (1-normcdf(u(i)./uGrid(1:end-1),1,0.047)).*uDicht{r};
       vPov{r}(i) = sum(vPov_help);
        
    end
    
end

%% Figuren

figure
for r = 1:16
    
    figure
    semilogy(u,uPov{r},'b','LineWidth',1.5);
    hold on
    semilogy(u,vPov{r},'r','LineWidth',1.5);
    grid on
    xlabel('Windsnelheid [m/s]');
    ylabel('Overschrijdingskans [1/12 uur]');
    title(['Overschrijdingskans Schiphol gegeven windrichting r = ',r_fig{r}]);
    print(gcf,'-dpng',['Figuren\windsnelheid_Schiphol_r_',num2str(r),'_',r_fig{r},'_VAR.png']);
    
end

for r = 1:16
    vPov{r} = vPov{r}';
end

vPov = cell2mat(vPov);

% %% Export data naar Hydra-NL format
% 
% X = [u,vPov];
% 
% wegschrijven_data('wind',[sNaam,'_VAR'],X);