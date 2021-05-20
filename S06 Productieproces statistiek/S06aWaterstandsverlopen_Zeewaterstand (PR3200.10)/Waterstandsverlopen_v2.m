%==========================================================================
% Script om waterstandsverlopen te checken.
%
%
% Door:     Chris Geerse
% Project:  PR3200.10
% Datum:    september 2016.
%==========================================================================

clc
clear
close all
addpath 'Hulproutines\' 'Invoer\';


%% Kies station voor specifieke analyse:
%
% NR        = 1;
% hMax      = 6.632;   %Delfzijl

% NR        = 2;
% hMax      = 5.641;   %Eemshaven m+NAP
% 
% NR        = 4;
% hMax      = 4.915;   %Harlingen
% 
% NR        = 7;
% hMax      = 5.642;   %Den Helder
% 
% NR        = 14;
% hMax      = 5.544;   %HvH
%
% NR        = 16;
% hMax      = 4.980;   %Kop van Goeree
% 
% NR        = 18;
% hMax      = 6.044;   %getij Westerscheldetunnel
% 

NR        = 14;
hMax      = 5.5;   



% Stationslabels:
%  1 = 'Delfzijl'
%  2 = 'Eemshaven'
%  3 = 'Lauwersoog'
%  4 = 'Harlingen'
%  5 = 'getijverloop 6_4'
%  6 = 'afsluitdijk'
%  7 = 'Den Helder Wadden'
%  8 = 'Den Helder Hol.Kust'
%  9 = 'getijverloop 13_2'
% 10 = 'getijverloop 13_3'
% 11 = 'IJmuiden'
% 12 = 'getijverloop 14_9'
% 13 = 'getijverloop 14_6'
% 14 = 'getijverloop HvH'
% 15 = 'getijverloop 211'
% 16 = 'getijverloop 25_1'
% 17 = 'Vlissingen'
% 18 = 'Westerscheldetunnel'
% 19 = 'Hansweert'

%% Invoer

% Inlezen alle getijverlopen.
infileGetijverlopen = 'Verzamelde getijverlopen_matlabInvoer.xlsx';
naamSheet           = 'Verzameld';
[num,txt,~]         = xlsread(infileGetijverlopen, naamSheet);

% Aantal stations:
N = numel(txt)/2;

% Bepaal stationslabels
for i = 1 : 19
    statLab{i,1} = txt{2*i};
end

% bepaal gegevens van de stations
tijdReeksen  = num(:,(1:2:end));
zeewsReeksen = num(:,(2:2:end));

%% Figuur van gekozen station:
figure
plot(tijdReeksen(:,NR), zeewsReeksen(:,NR),'b')
hold on; grid on
tekst = statLab(NR);
title(['Getijverloop ', tekst])
xlabel('Tijd, uur')
ylabel('Waterstand, m+NAP')

%% Alle getijreeksen tezamen
figure
for i = 1: N
    plot(tijdReeksen(:,i), zeewsReeksen(:,i))
    hold on; grid on
end
title(['Getijverloop '])
xlabel('Tijd, uur')
ylabel('Waterstand, m+NAP')
legend(statLab)
xlim([-6, 6])




%% Bepaal opzetparameters per station (hier HvH dus 2.5 uur, en geen -4.5 uur)
% Opmerking: dit zijn volgens mij de keuzes volgens het memo van Houcine!!

% NB. Negatieve fase is opzetmax later dan HW.
faseAll             = zeros(N,1);
faseAll(1:7)        = 5.5;      % uur, Waddenzee
faseAll(8:N)        = 2.5;      % uur, Hollandse en Zeeuwse kust
stormduurAll(1:7)   = 45;  % uur, Waddenzee
stormduurAll(8:N)   = 44;  % uur, Hollandse en Zeeuwse kust

% Parameters voor stormopzetpatroon bij beschouwd station:
stormduur   = stormduurAll(NR);
fase        = faseAll(NR);   %getijverloop moet veel eerde beginnen, en later eindigen, dan het feitelijke stormopzetpatroon.

% Gemeenschappelijke parameters:
A           = 0.1;    %voor bepalen patroon rond de top
%B           = 0.5;    %voor start feitelijke opzet (zonder begin- en eindflank);
B           = 0.0;    %voor start feitelijke opzet (zonder begin- en eindflank);

topduur     = 2;      % DUS GEEN 4 UUR GEKOZEN HIER



%% Bepaal opzet- en waterstandsverloop voor bereiken gewenste opzMax
t           = tijdReeksen (:,NR);
ws_getij    = zeewsReeksen(:,NR);
opzGrid     = [A+B+0.1 : 0.01: 10]';

[Stormopzetpatroon_knikpunten, Stormopzetpatroon, ws_verloop, opzet] = ...
    bepaalOpzetverloopBijOpgegevenMaximumwaterstand(hMax, opzGrid,...
    t, ws_getij, A, B, stormduur, topduur, fase);

close all

% Figuur met waterstandsverloop en de onderdelen daarvan.
figure
plot(t, ws_getij, 'k--')
hold on
grid on
plot(t, Stormopzetpatroon,'r-')
plot(t, ws_verloop,'b','LineWidth',2)
title({[statLab{NR},', h = ',num2str(hMax, '%0.3f'),' m+NAP, duur = ',...
    num2str(stormduur, '%0.0f'),' uur, opzet = ',num2str(opzet, '%0.3f'),' m,'],...
    ['A = ',num2str(A, '%0.1f'),' m, B = ',num2str(B, '%0.1f'),' m, fase = ',num2str(fase),' uur']}, 'interpreter', 'none')
xlim([-40, 20])
% ylim([-1, 6])
xlabel('Tijd, uur')
ylabel('Waterstand, m+NAP')
legend('Astronomisch getij','Stormopzet','Stormopzet + getij','location', 'NorthWest')


close all

% Figuur met waterstandsverloop en de onderdelen daarvan.
figure
plot(t, ws_getij, 'k--')
hold on
grid on
plot(t, Stormopzetpatroon,'r-')
plot(t, ws_verloop,'b','LineWidth',2)
title({[statLab{NR},', h = ',num2str(hMax, '%0.3f'),' m+NAP, duur = ',...
    num2str(stormduur, '%0.0f'),' uur, opzet = ',num2str(opzet, '%0.3f'),' m,'],...
    ['A = ',num2str(A, '%0.1f'),' m, B = ',num2str(B, '%0.1f'),' m, fase = ',num2str(fase),' uur, topduur = ', num2str(topduur),' uur' ]}, 'interpreter', 'none')
xlim([-65, 55])
% ylim([-1, 6])
xlabel('Tijd, uur')
ylabel('Waterstand, m+NAP')
legend('Astronomisch getij','Stormopzet','Stormopzet + getij','location', 'NorthWest')



