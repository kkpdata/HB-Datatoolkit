% Script om modelonzekerheden waterstand uit te integreren.
%
% Aanname: volledige afhankelijkheid opeenvolgende blokken.
%
% Als voor de ovfreq van de afvoer een uitgeintegreerde versie wordt
% genomen, zit de onzekerheid van de afvoer ook in de resultaten. Zie
% aantekeningen bij 21 november 2015.

% % Auteur: Chris Geerse
% % November 2015



%==========================================================================
% Algemene zaken
%==========================================================================

clc;
clear;
close all
addpath 'Hulproutines\' 'Invoer\';

%==========================================================================
% Invoerparameters.
%==========================================================================

% Ovkans afvoer in basisduur (kan versie met of zonder onzekerheden in de
% afvoer zijn)
% Oude lijn HR2006
kOvkansInv1 = [...
    800, 1
    6000, 1/6
    16000, 1/6*(1/1250)
    21900, 1/6*(1e-5)];

% uitgeintegreerde lijn uit Grade
kOvkansInv2 = [...
    800, 1
    6000, 1/6
    14000, 1/6*(1/300)
    14500, 1/6*(1/500)
    15050, 1/6*(1/1000)
    18600, 1/6*(1e-5)];

% uit Grade
kOvkansInv3 = [...
    800, 1
    6000, 1/6
    14000, 1/6*(1/300)
    14400, 1/6*(1/500)
    14950, 1/6*(1/1000)
    17700, 1/6*(1e-5)];


% Werklijnen afvoer
figure
semilogx(1./(6*kOvkansInv1(:,2)), kOvkansInv1(:,1), 'b-')
hold on; grid on
semilogx(1./(6*kOvkansInv2(:,2)), kOvkansInv2(:,1), 'k-')
semilogx(1./(6*kOvkansInv3(:,2)), kOvkansInv3(:,1), 'r-')
title('Werklijnen afvoer')
xlabel('Terugkeertijd, [jaar]')
ylabel('Afvoer')
%legend('Zonder modelonzekerheid ws', 'Met modelonzekerheid ws')
xlim([10, 1e5])

% Keuze werklijn met afbuiging (incl. onzekerheid afvoer)
kOvkansInv = kOvkansInv1;
    
%kOvkansInv = kOvkansInv3;



% QH-relatie zonder knikken
QH_relatie1 =[...
    750, 7.5
    24000, 8.9];
% QH-relatie met knikken
QH_relatie2 =[...
    750, 4
    6000, 5.1
    8000, 5.55
    10000, 6.05, 
    13000, 6.5
    16000, 6.95
    16500, 7.3
    24000, 8.9];

% even trucen
% QH-relatie met knikken
QH_relatie3 =[...
    750, 4
    6000, 5.95
    8000, 6.0
    10000, 6.05, 
    13000, 6.5
    16000, 7.2
    16500, 7.3
    24000, 8.9];


figure
plot(QH_relatie1(:,1),QH_relatie1(:,2), 'k-')
hold on; grid on
plot(QH_relatie2(:,1),QH_relatie2(:,2), 'b-')
title('QH-relatie')
xlabel('Afvoer')
ylabel('Waterstand, [m+NAP]')
xlim([6000, 24000])

%===============================
%===============================
% Keuze
QH_relatie = QH_relatie3;


% Onzekerheid waterstand, normaal verdeel met mu en sigma
hMu  = 0;       %m
hSig = 0.45;     %m


%==========================================================================
%==========================================================================
% Berekeningen
%==========================================================================
%==========================================================================

% Maak k-grid
kMin = 800;
kSt  = 50;
kMax = 20000;

% Ovkansen op kGrid
kGrid = [kMin : kSt : kMax]';
kPov = exp( interp1(kOvkansInv(:,1), log(kOvkansInv(:,2)), kGrid, 'linear', 'extrap') );

figure
semilogy(kGrid, kPov, 'b-')
hold on; grid on
title('Ovkans afvoer')
xlabel('Afvoer')
ylabel('Overschrijdingskans, [-]')



%==========================================================================
% Ovkansen waterstand zonder modelonzekerheid waterstand
%==========================================================================

% grid van waterstande
hMin = min(QH_relatie(:,2));
hSt  = 0.001;
hMax = max(QH_relatie(:,2));
hGrid = [hMin : hSt : hMax]';

for i = 1 : length(hGrid)
    hPov(i)  = exp( interp1( kGrid, log(kPov),  bepaalQbijH( hGrid(i), QH_relatie) , 'linear', 'extrap') );
end


figure
semilogy(hGrid, hPov, 'b-')
hold on; grid on
title('Ovkans waterstand')
xlabel('Waterstand')
ylabel('Overschrijdingskans, [-]')



%==========================================================================
% Ovkansen waterstand met modelonzekerheid waterstand
%==========================================================================

% Maak y-grid voor verwerken onzekerheid waterstand
% yMin  = hMu - 4*hSig;
% ySt   = hSig/10;
% yMax  = hMu + 4*hSig;

yMin  = hMu - 4*hSig;
ySt   = hSig/10;
yMax  = hMu + 4*hSig;

yGrid = [yMin : ySt : yMax]';


% Bereken integraal P_B(H>h) inclusief onzekerheid y voor ws in basisduur B.
% Doe dit op h-grid van waterstanden.

for i = 1 : length(hGrid)
    
    PovAfvoer    = exp( interp1( kGrid, log(kPov),  bepaalQbijH( hGrid(i) - yGrid, QH_relatie) , 'linear', 'extrap') );
    klassekansen = normpdf(yGrid, hMu, hSig)*ySt;
    
    % bereken integraal
    hPovOnz(i)   = klassekansen' * PovAfvoer;
    
end

% %==========================================================================
% % Figuren
% %==========================================================================


QH_uitgebreid(:,1) = kGrid;
QH_uitgebreid(:,2) = interp1(QH_relatie(:,1), QH_relatie(:,2), kGrid, 'linear', 'extrap');


figure
plot(QH_uitgebreid(:,1),QH_uitgebreid(:,2), 'k-')
hold on; grid on
title('QH-relatie')
xlabel('Afvoer')
ylabel('Waterstand, [m+NAP]')




% Kansen in basisduur
figure
semilogy(hGrid, hPov, 'b-')
hold on; grid on
semilogy(hGrid, hPovOnz, 'r-')
title('Uitintegratie onzekerheid waterstand')
xlabel('Waterstand')
ylabel('Overschrijdingskans, [-]')
legend('Zonder modelonzekerheid ws', 'Met modelonzekerheid ws')


close all

% Frequentielijnen
figure
semilogx(1./(6*hPov), hGrid, 'b-')
hold on; grid on
semilogx( 1./(6*hPovOnz), hGrid, 'r-')
title('Uitintegratie onzekerheid waterstand')
xlabel('Terugkeertijd, [jaar]')
ylabel('Waterstand')
legend('Zonder modelonzekerheid ws', 'Met modelonzekerheid ws')
xlim([10, 1e5])

    


