%% Script om inzicht te krijgen in de lognormale verdeling
%==========================================================================
%
% Door: Chris Geerse
% PR3280.20
% Datum: augustus 2016
%
% Zie als toelichting par. 3.6.3 uit het rapport [Geerse, 2016]:
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

%% Parameters voor IJsselmeer T = 10^4 jaar.
sEps = -1.47; %minus de verschuiving van Y om W te krijgen
sSig = 0.231; %van Y, maar ook van W
sZonderOnz = 1.07;
% % Parameters voor IJsselmeer T = 10 jaar.
% sEps = -0.79; %minus de verschuiving van Y om W te krijgen
% sSig = 0.031; %van Y, maar ook van W

sSigNormaal  = sqrt( log(1 + sSig.^2./(-sEps).^2) )
sMuNormaal   = log( -sEps ) - 0.5 * sSigNormaal.^2



%% Lognormale verdeling W ~ ln N(muNorW,sigNorW).

typeParameters = 2;
% 1 = mu en sig van verdeling W (verdeling begint bij 0)
% 2 = mu en sig van ln(W), oftewel van de bijbehorende normale verdeling

muInv  = 0.3731;    %T = 10^4 jaar
sigInv = 0.1562;
% muInv  = -0.2365; % T = 10 jaar
% sigInv = 0.0392;

shiftW = -0.4;  %verschuiving naar rechts (in rapport eps genoemd)

switch typeParameters
    case 1  %Invoer voor W zelf
        tekst   = 'Invoer van W zelf';
        muW     = muInv;
        sigW    = sigInv;
        muNorW  = log(muW) - 0.5*log( 1 + (sigW/muW)^2);
        sigNorW = (log( 1 + (sigW/muW)^2))^0.5;
        
    case 2  %Invoer voor ln(W)
        tekst   = 'Invoer van ln(W)';
        muNorW  = muInv;
        sigNorW = sigInv;
        
        muW     = exp(muNorW + sigNorW^2/2);
        sigW    = ( (exp(sigNorW^2) - 1) * exp(2*muNorW + sigNorW^2) )^0.5;
end

disp(tekst)
disp(['parameters ln(W): mu = ', num2str(muNorW), ', sig = ', num2str(sigNorW)]);
disp(['parameters    W : mu = ', num2str(muW),    ', sig = ', num2str(sigW)]);

wSt   = 0.01;
wMin  = 1e-10;
wMax  = 3.0;
wGrid = [wMin : wSt: wMax]';

pdfW        = normpdf( log(wGrid), muNorW, sigNorW)./wGrid;

% Voor normale benadering:
muApproxN   = exp(muNorW);
sigApproxN  = sigNorW * exp(muNorW);
pdfWapproxN = normpdf( wGrid, muApproxN, sigApproxN);

% Cumulatieve versies
cdfW        = normcdf( log(wGrid), muNorW, sigNorW);
cdfWapproxN = normcdf( wGrid, muApproxN, sigApproxN);



%% Figuur met gegevens, inclusief normale benadering (die slecht kan zijn):
figure
plot(wGrid, pdfW, 'b-')
hold on; grid on
plot(wGrid,pdfWapproxN,'r--')
title('Lognormale verdeling')
xlabel('w')
ylabel('pdf')
legend('Lognormale verdeling', 'Normale benadering')

% Nu voor cumulatieve versie
figure
plot(wGrid, cdfW, 'b-')
hold on; grid on
plot(wGrid, cdfWapproxN,'r--')
title('Lognormale verdeling (cdf)')
xlabel('w')
ylabel('cdf')
legend('Lognormale verdeling', 'Normale benadering')


%% Verschuiving van W beschouwen

% Keuzes IJsselmeer T = 10000 jaar.
shift = -0.4;   %verschuiving positief is 'naar rechts'

wMnExt = -0.4;
wStExt  = 0.01;
wMxExt  = 2.6;
wGrExt  = [wMnExt : wStExt: wMxExt]';

pdfWsh        = normpdf( log(wGrExt - shift), muNorW,    sigNorW)./(wGrExt - shift);
pdfWapproxNsh = normpdf( wGrExt     - shift,  muApproxN, sigApproxN);
cdfWsh        = normcdf( log(wGrExt - shift), muNorW,    sigNorW);
cdfWapproxNsh = normcdf( wGrExt     - shift,  muApproxN, sigApproxN);

figure
plot(wGrExt, pdfWsh, 'b-')
hold on; grid on
plot(wGrExt,pdfWapproxNsh,'r--')
title('Lognormale verdeling met verschuiving')
xlabel('s')
ylabel('pdf')
legend('Lognormale verdeling', 'Normale benadering')

% cumulatief
figure
plot(wGrExt, cdfWsh, 'b-')
hold on; grid on
plot(wGrExt,cdfWapproxNsh,'r--')
title('Lognormale verdeling met verschuiving')
xlabel('s')
ylabel('cdf')
legend('Lognormale verdeling', 'Normale benadering')

close all

%% Boven normale benadering, met percentielen 0.025 en 0.975.
pOnder = 0.025;
zOnder = norminv(pOnder, 0, 1);
xOnder = shift + exp(muNorW + sigNorW .* zOnder)

pBoven = 0.975;
zBoven = norminv(pBoven, 0, 1);
xBoven = shift + exp(muNorW + sigNorW .* zBoven)

figure
plot(wGrExt, pdfWsh, 'b-', 'linewidth', 1.5)
hold on; grid on
plot( [sZonderOnz, sZonderOnz], [0, 2],'k-', 'linewidth', 1.5 )
plot( [xOnder, xOnder], [0,0.8],'k--', 'linewidth', 1.5 )
plot( [xBoven, xBoven], [0,0.8],'k--', 'linewidth', 1.5 )
title(['Lognormale verdeling onzekerheid voor s = ', num2str(sZonderOnz),' m+NAP'])
xlabel('Onzekerheid x')
ylabel('Kansdichtheid')
legend('Lognormale verdeling', 'Meerpeil s', 'Onder en bovengrens')
xlim([-0.5, 2])

% cumulatief
figure
plot(wGrExt, cdfWsh, 'b-')
hold on; grid on
plot( [xOnder, xOnder], [0,1],'k--', 'linewidth', 1.5 )
plot( [xBoven, xBoven], [0,1],'k--', 'linewidth', 1.5 )
title('Lognormale verdeling met verschuiving')
xlabel('Onzekerheid x')
ylabel('cdf')
legend('Lognormale verdeling', 'Normale benadering')
