%% script om loop over programma ws-onzekerheden te maken

clc;
clear;
close all
addpath 'Hulproutines\' 'Invoer\';

%% Invoerparameters
hMu  = 0;    % m

%hDec = 0.1; % m
hDec = [0.1 : 0.1  : 0.8]'; % m
hSig = [0.1 : 0.05 : 0.4]';
Tkt  = 10000;

% Deze krijgen de nummers 1..23:
label_dec = {'d = 0.1 m','d = 0.2 m','d = 0.3 m','d = 0.4 m','d = 0.5 m','d = 0.6 m','d = 0.7 m','d = 0.8 m'};
label_std = {'s = 0.10 m','s = 0.15 m','s = 0.20 m','s = 0.25 m','s = 0.30 m','s = 0.35 m','s = 0.40 m'};

%% Feitelijke berekening
for i = 1 : length(hDec)
    for j = 1 : length(hSig)
    EffectOnz(i,j)= Functie_main_onzekerheden_bovenrivieren_versieHdecimering(hDec(i), hMu, hSig(j), Tkt);
    end
end

EffectOnzMetWaarden = [[hDec, EffectOnz]; [999, hSig']];

disp('Verticaal decimeringswaarden; horizontaal de sigmas')
EffectOnzMetWaarden

decimeringswaarden   = EffectOnzMetWaarden(1:end-1 , 1);
standaarddeviaties   = EffectOnzMetWaarden(end, 2:end)';

%% Figuren

% Figuur met effect als functie van decimeringswaarde
figure
for j = 1 : length(standaarddeviaties)
    
    effect = EffectOnzMetWaarden(1:end-1, j+1);
    plot(decimeringswaarden, effect, '-','linewidth', 1.5)   
    hold on; grid on
end
title('Effect als functie van h_{dec}')
xlabel('Decimeringswaarde, m')
ylabel('Effect, m')
legend(label_std, 'location', 'NorthEast')
ylim([0, 1.2])
xlim([0,0.8])

% Figuur met effect als functie van standaarddeviatie
figure
for i = 1 : length(decimeringswaarden)
    
    effect = EffectOnzMetWaarden(i, 2:end);
    plot(standaarddeviaties, effect, '-','linewidth', 1.5)   
    hold on; grid on
end
title('Effect als functie van \sigma_{ws}')
xlabel('Standaarddeviatie, m')
ylabel('Effect, m')
legend(label_dec, 'location', 'NorthWest')
ylim([0, 1.2])
xlim([0, 0.4])

% Figuur voor verificatievuistregel
figure
for j = 1 : length(standaarddeviaties)
    
    effect = EffectOnzMetWaarden(1:end-1, j+1);
    waarde = effect.*decimeringswaarden./standaarddeviaties(j).^2;
    plot(decimeringswaarden, waarde, '-','linewidth', 1.5)   
    hold on; grid on
end
title('Vuistregel voor verband effect, h_{dec} en \sigma_{ws}')
xlabel('Decimeringswaarde, m')
ylabel('Effect*h_{dec}/\sigma_{ws}^2')
legend(label_std, 'location', 'SouthEast')
ylim([0, 1.2])

