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

%% Parameters lognormale verdeling en bijbehorende normale parameters:
m0_1       = -0.10;    %m+NAP
s1         = 0.58;
Sig1       = 0.107; %van Y, maar ook van W
Eps1       = -(s1 - m0_1) - 1e-10;

m0_2       = 0.05;    %m+NAP
s2         = 0.58;
Sig2       = 0.107; %van Y, maar ook van W
Eps2       = -(s2 - m0_2) - 1e-10;

% m0_1       = -0.10;    %m+NAP
% s1         = 0.4;
% Sig1       = 0.07; %van Y, maar ook van W
% Eps1       = -(s1 - m0_1) - 1e-10;
% 
% m0_2       = 0.15;    %m+NAP
% s2         = 0.4;
% Sig2       = 0.07; %van Y, maar ook van W
% Eps2       = -(s2 - m0_2) - 1e-10;

% m0_1       = -0.10;    %m+NAP
% s1         = 1.12;
% Sig1       = 0.33; %van Y, maar ook van W
% Eps1       = -(s1 - m0_1) - 1e-10;
% 
% m0_2       = 0.05;    %m+NAP
% s2         = 1.12;
% Sig2       = 0.33; %van Y, maar ook van W
% Eps2       = -(s2 - m0_2) - 1e-10;

% m0_2       = 0.05;    %m+NAP
% s2         = 0.94;
% Sig2       = 0.2311; %van Y, maar ook van W
% Eps2       = -(s2 - m0_2) - 1e-10;


SigNor1    = sqrt( log(1 + Sig1.^2./(-Eps1).^2) );
muNor1     = log( -Eps1 ) - 0.5 * SigNor1.^2;
SigNor2    = sqrt( log(1 + Sig2.^2./(-Eps2).^2) );
muNor2     = log( -Eps2 ) - 0.5 * SigNor2.^2;

% Medianen lognormale verdelingen:
median1    = exp(muNor1) + m0_1;
median2    = exp(muNor2) + m0_2;

disp(' ')
disp(['parameters lognormale verd. (X1): mu1    = ', num2str(s1),      ', sig1    = ', num2str(Sig1), ', median = ', num2str(median1)]);
disp(['parameters normale verd.  (lnX1): muNor1 = ', num2str(muNor1),  ', sigNor1 = ', num2str(SigNor1)]);

disp(' ')
disp(['parameters lognormale verd. (X2): mu2    = ', num2str(s2),      ', sig2    = ', num2str(Sig2), ', median = ', num2str(median2)]);
disp(['parameters normale verd.  (lnX2): muNor2 = ', num2str(muNor2),  ', sigNor2 = ', num2str(SigNor2)]);


xSt   = 0.01;
xMax  = 1.5;
xMin1 = m0_1 +1e-10;
xMin2 = m0_2 +1e-10;
xGrid1 = [xMin1 : xSt: xMax]';
xGrid2 = [xMin2 : xSt: xMax]';

pdfX1        = normpdf( log(xGrid1 - m0_1), muNor1, SigNor1)./(xGrid1 - m0_1);
pdfX2        = normpdf( log(xGrid2 - m0_2), muNor2, SigNor2)./(xGrid2 - m0_2);




%% Figuur met gegevens:
figure
plot(xGrid1, pdfX1, 'b--','linewidth', 2)
hold on; grid on
plot(xGrid2, pdfX2, 'r-','linewidth', 2)
plot([s1, s1], [0, 1.2*max(pdfX1)], 'k','linewidth', 2)
title('Lognormale verdeling')
xlabel('x')
ylabel('pdf')
legend('Lognormale verdeling X1', 'Lognormale verdeling X2','Meerpeil s','location', 'northwest')

