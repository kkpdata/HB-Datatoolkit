function [EffectOnz]= Functie_main_onzekerheden_bovenrivieren_versieHdecimering(hDec, hMu, hSig, Tkt);

% % Voer hier de decimeringswaarde van de waterstand in:
% hDec  = 0.2;    % m
% 
% % Onzekerheid waterstand, normaal verdeel met mu en sigma
% hMu  = 0;        %m
% hSig = 0.4;     %m

%Tkt = 1000; %

%==========================================================================
% Invoerparameters.
%==========================================================================

% Ovkans afvoer in basisduur. Neem gewoon de afvoer en de waterstand gelijk
% aan elkaar.
hBegin     = 3.0;   %m+NAP
% kOvkansInv = [...
%     hBegin,        1/6               %T = 1 jaar
%     hBegin+5*hDec, 1/6*(1/100000)];  %T = 10^5 jaar
hMin = hBegin + hDec*log10(1/6);
kOvkansInv = [...
    hMin-2,        1
    hMin,          1-0.00001
    hBegin,        1/6               %T = 1 jaar
    hBegin+5*hDec, 1/6*(1/100000)];  %T = 10^5 jaar
    
% Werklijn afvoer
figure
semilogx(1./(6*kOvkansInv(:,2)), kOvkansInv(:,1), 'b-')
hold on; grid on
title('Werklijn afvoer')
xlabel('Terugkeertijd, [jaar]')
ylabel('Afvoer')
%legend('Zonder modelonzekerheid ws', 'Met modelonzekerheid ws')
xlim([10, 1e5])

% QH-relatie (zelfde als afvoer)
QH_relatie =[...
    1,   1
    100, 100];

figure
plot(QH_relatie(:,1),QH_relatie(:,2), 'k-')
hold on; grid on
title('QH-relatie')
xlabel('Afvoer')
ylabel('Waterstand, [m+NAP]')
%xlim([6000, 24000])





%==========================================================================
%==========================================================================
% Berekeningen
%==========================================================================
%==========================================================================

% Maak k-grid (hier gewoon in meters)
kMin = hBegin;
kSt  = 0.01;    
kMax = hBegin + 30*hDec + 4*hSig;




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
hGrid = kGrid;

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
yMin  = hMu - 4*hSig;   %factor 4 niet verkleinen!
ySt   = hSig/10;
yMax  = hMu + 4*hSig;

yGrid = [yMin : ySt : yMax]';


% Bereken integraal P_B(H>h) inclusief onzekerheid y voor ws in basisduur B.
% Doe dit op h-grid van waterstanden.

for i = 1 : length(hGrid)
    
    PovAfvoer    = exp( interp1( kGrid, log(kPov),  bepaalQbijH( hGrid(i) - yGrid, QH_relatie) , 'linear', 'extrap') );
    PovAfvoer(PovAfvoer>=1) = 1;    %zorg dat kansen niet groter dan 1 kunnen worden
    
    klassekansen = normpdf(yGrid, hMu, hSig)*ySt;
    
    % bereken integraal
    hPovOnz(i)   = klassekansen' * PovAfvoer;
    
end

% Effect onzekerheid:
hZonderOnz  = interp1( log(hPov),    hGrid, log( (1/Tkt)/6 ), 'linear', 'extrap');
hMetOnz     = interp1( log(hPovOnz), hGrid, log( (1/Tkt)/6 ), 'linear', 'extrap');
EffectOnz   = hMetOnz - hZonderOnz;

% %==========================================================================
% % Figuren
% %==========================================================================

% 
% QH_uitgebreid(:,1) = kGrid;
% QH_uitgebreid(:,2) = interp1(QH_relatie(:,1), QH_relatie(:,2), kGrid, 'linear', 'extrap');
% 
% 
% figure
% plot(QH_uitgebreid(:,1),QH_uitgebreid(:,2), 'k-')
% hold on; grid on
% title('QH-relatie')
% xlabel('Afvoer')
% ylabel('Waterstand, [m+NAP]')
% 
% 


% Kansen in basisduur
figure
semilogy(hGrid, hPov, 'b-')
hold on; grid on
semilogy(hGrid, hPovOnz, 'r-')
title(['Uitintegratie onzekerheid waterstand, effect = ', num2str(100*EffectOnz),' cm'])
xlabel('Waterstand')
ylabel('Overschrijdingskans, [-]')
legend('Zonder modelonzekerheid ws', 'Met modelonzekerheid ws')


close all

% Frequentielijnen
figure
semilogx(1./(6*hPov), hGrid, 'b-')
hold on; grid on
semilogx( 1./(6*hPovOnz), hGrid, 'r-')
title(['Uitintegratie onzekerheid waterstand, effect = ', num2str(100*EffectOnz),' cm'])
xlabel('Terugkeertijd, [jaar]')
ylabel('Waterstand')
legend('Zonder modelonzekerheid ws', 'Met modelonzekerheid ws')
xlim([10, 1e5])

close all

disp(['Decimeringswaarde      = ', num2str(100*hDec),' cm'])
%disp(['Gemiddelde onz.heid    = ', num2str(100*hMu),'  cm'])
disp(['Standaarddev. onz.heid = ', num2str(100*hSig),' cm'])
disp(['Effect onz.heid        = ', num2str(100*EffectOnz),' cm'])
  


