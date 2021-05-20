%==========================================================================
% Script om getijverloop en stormopzet bij elkaar op te tellen.
% Bedoeld om programma van Rolf Waterman te checken.
% 
% Door: Chris Geerse
% Datum: 24 februari 2014.
% Project: PR2803.10
% 
%==========================================================================

clear
close all

addpath 'Hulproutines\' 'Invoer\' 'Uitvoer\' ;

%==========================================================================

% Inlezen tijdreeks getijverloop IJmuiden.
AA       = load('Getij_IJmuiden.txt');
% AA       = load('Getij_Harlingen.txt');
t        = AA(:,1);
ws_getij = AA(:,2);
clear AA

% Parameters voor stormopzetpatroon.
Stormduur   = 30;
fase        = 4;   %getijverloop moet veel eerde beginnen, en later eindigen, dan het feitelijke stormopzetpatroon.
A           = 0.1;    %voor bepalen patroon rond de top
B           = 0.5;    %voor start feitelijke opzet (zonder begin- en eindflank);
% hmax = 4.5728;    %maximum opzetpatroon (voor B = 0.5)
hmax        = 2.1; 

% B    = 0.0;    %voor start feitelijke opzet (zonder begin- en eindflank);
% hmax = 4.5928;    %maximum opzetpatroon

topduur = 4;


% Knikpunten van het opzetpatroon.
Stormopzetpatroon_knikpunten =...
    [min(t),                0
    -(Stormduur/2+12)-fase, eps
    -Stormduur/2-fase,      B
    -topduur/2-fase,                hmax - A
     0-fase,                hmax
     topduur/2-fase,                hmax - A
     Stormduur/2-fase,      B
     Stormduur/2+12-fase,   eps
     max(t),                0];

% % Tbv losse test Harlingen:
% fase = 6;
% A = 0.2;
% B= 0.75;
% hmax = 4.4;
% Stormopzetpatroon_knikpunten =...
% [-60, 0
% -45-fase, eps
% -20-fase, B
% -3-fase, hmax-A
% 0-fase, hmax
% 5-fase, hmax-A
% 25-fase, B
% 45-fase, eps
% 70, 0]
% Stormduur = 45;
%  
 
% Uitbreiding op fijner rooster van getijreeks:
Stormopzetpatroon = interp1(Stormopzetpatroon_knikpunten(:,1), Stormopzetpatroon_knikpunten(:,2), t, 'linear');
ws_verloop = ws_getij + Stormopzetpatroon;


% Figuur met waterstandsverloop en de onderdelen daarvan.
figure
plot(t, ws_getij, 'k--')
hold on
grid on
plot(t, Stormopzetpatroon,'r-','LineWidth',2)
plot(t, ws_verloop,'b','LineWidth',2)

hoogte = max(ws_verloop);
%title(['Ws-verloop, hoogte = ',num2str(hoogte),' m+NAP, t_s = ', num2str(Stormduur),' uur, h_s = ',num2str(hmax),' m, A = ',num2str(A),' m, B = ',num2str(B),' m, \phi = ',num2str(fase),' uur'])
% % title(['Ws-verloop, hoogte = ',num2str(hoogte),' m+NAP, t_s = ', num2str(Stormduur),' uur, h_s = ',num2str(hmax),' m, \phi = ',num2str(fase),' uur'])
title(['fase \phi = ',num2str(fase),' uur'])
xlim([-60, 60])
ylim([-1, 3])
xlabel('Tijd, uur')
ylabel('Waterstand, m+NAP')
legend('Astronomisch getij','Stormopzet','Stormopzet + getij')

