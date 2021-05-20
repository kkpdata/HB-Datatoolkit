%==========================================================================
% Script interpoleren correlaties zeewaterstand OS en wind Vlissingen
%
% Door: Chris Geerse
%
% Datum: aug 2017
% Project: PR3556.10
%
%==========================================================================

%% Invoer

clc
clear
close all

%% Bepalen correlatiesterkte voor 22.5-sectoren
%
% Huidige waarden Hydra-NL v2.3.0 voor de Westerschelde (neem deze voor
% OS, zelfde als gegevens Prespeil die worden gebruikt door Krijn Saman:
% * m \ r  30      60      90      120     150     180     210      240      270      300      330      360
% 0.0      -99.0   -99.0   -99.0   -99.0   -99.0   -99.0   -99.0    1.683    1.655    1.620    1.651    1.846
% 6.5      -99.0   -99.0   -99.0   -99.0   -99.0   -99.0   -99.0    1.683    1.655    1.620    1.651    1.846% Aangepaste waarden Hydra-NL v2.3.0


corrOrig = [...
          240      270      300      330      360
          1.683    1.655    1.620    1.651    1.846];


rReeks    = [225 : 22.5 : 360];
corrNieuw = interp1(corrOrig(1,:), corrOrig(2,:), rReeks, 'linear', 'extrap');

figure
plot(corrOrig(1,:), corrOrig(2,:),'bo-','linewidth', 2)
hold on; grid on
plot(rReeks, corrNieuw,'r*--','linewidth', 2)
title('Correlaties per richting')
xlabel('Windrichting, graden')
ylabel('Correlaties, [-]');
ylim([1.6, 1.9])
xlim([220, 360])
legend('30-sectoren','22.5-sectoren');

Tabel = [[999; 0; 6.5],[rReeks; corrNieuw; corrNieuw]]

% Tekstbestand verder handmatig in orde maken!
