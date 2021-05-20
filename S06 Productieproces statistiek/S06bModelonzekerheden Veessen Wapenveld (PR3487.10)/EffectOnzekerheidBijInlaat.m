% Script om simpel plaatje te maken van Hydra-NL resultaten
%
% % Auteur: Chris Geerse
% % Maart 2017



%==========================================================================
% Algemene zaken
%==========================================================================

clc;
clear;
close all

%==========================================================================
% Invoerparameters.
%==========================================================================

UitvoerHydraNL_GroveDiscretisatie =[...
    4.9	8.7	8.1
    5	10.7	10.0
    5.1	13.6	12.6
    5.2	16.8	16.0
    5.3	24.2	21.4
    5.4	36.2	29.6
    5.5	52.8	41.5
    5.6	80.3	65.3
    5.7	4123.1	128.2
    5.8	5416.9	190.0
    5.9	6647.0	539.6
    6	9916.7	818.3
    6.1	17789.9	3473.4
    6.2	33335.7	19635.8
    6.3	61198.9	31173.0
    6.4	110195.9	54668.5];

UitvoerHydraNL_FijneDiscretisatie = load('Uitvoer_HydraNL_FijneDiscretisatie.txt');


% Kies DiscretisatieType
% 1 = grof
% 2 = fijn
DiscretisatieType = 1;

if DiscretisatieType == 1
    UitvoerHydraNL = UitvoerHydraNL_GroveDiscretisatie;
elseif DiscretisatieType == 2
    UitvoerHydraNL = UitvoerHydraNL_FijneDiscretisatie;
end



%==========================================================================
% Berekeningen
%==========================================================================

hReeks          = UitvoerHydraNL(:,1);
ThulpreeksZonz0 = UitvoerHydraNL(:,2);
ThulpreeksMonz0 = UitvoerHydraNL(:,3);

% Maak T-invoer  strikt stijgend:
n               = numel(ThulpreeksZonz0);
ThulpreeksZonz  = ThulpreeksZonz0 + 1e-10*[1:1:n]';
n               = numel(ThulpreeksMonz0);
ThulpreeksMonz  = ThulpreeksMonz0 + 1e-10*[1:1:n]';

% figure
% semilogx(ThulpreeksZonz, hReeks, 'b-','linewidth', 1.5)
% hold on; grid on
% semilogx(ThulpreeksMonz, hReeks, 'r-','linewidth', 1.5)
% title('Uitvoer Hydra-NL bij inlaat Veessen Wapenveld')
% xlabel('Terugkeertijd, Jaar')
% ylabel('Waterstand, m+NAP')
% legend('Zonder modelonzekerheid', 'Met modelonzekerheid','location', 'SouthEast')
% xlim([10, 2e5])
% ylim([4.9, 6.4])



Tgrid      = [10: 1: 1e5]';
%Tgrid      = [10:10:79, 80: 50: 1e5]';

HreeksZonz = interp1(log(ThulpreeksZonz), hReeks, log(Tgrid), 'linear', 'extrap');
HreeksMonz = interp1(log(ThulpreeksMonz), hReeks, log(Tgrid), 'linear', 'extrap');

figure
semilogx(Tgrid, HreeksZonz, 'b-','linewidth', 1.5)
hold on; grid on
semilogx(Tgrid, HreeksMonz, 'r-','linewidth', 1.5)
title('Frequentielijnen Hydra-NL bij inlaat Veessen Wapenveld')
xlabel('Terugkeertijd, Jaar')
ylabel('Waterstand, m+NAP')
legend('Zonder modelonzekerheid', 'Met modelonzekerheid','location', 'SouthEast')
xlim([10, 2e5])
ylim([4.9, 6.4])

figure
semilogx(Tgrid, HreeksMonz - HreeksZonz, 'k-','linewidth', 1.5)
hold on; grid on
title('Effect modelonzekerheid bij inlaat Veessen Wapenveld')
xlabel('Terugkeertijd, Jaar')
ylabel('Verschil in waterstand, m')
xlim([10, 2e4])
%ylim([4.9, 6.4])


