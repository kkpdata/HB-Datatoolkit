figure
semilogx(plotpos, obs,'r.','linewidth', 2);
hold on
grid on

semilogx(1./(9*OvkansPiekInv_HZ(:,2)),OvkansPiekInv_HZ(:,1),'g-','linewidth', 2)    %oude gegevens PR1564

semilogx(1./wlijn(:,2),wlijn(:,1),'b--','linewidth', 2);      %Hydra-NL nieuwe keuze
title(['Frequentielijn ',stationsnaam]);
xlabel('Terugkeertijd, 1/jaar');
ylabel('Meerpeil, m+NAP');

if strcmp(stationsnaam,  'Grevelingenmeer')
    xlim([1e-5 100]);
    ylim([-0.3 0.2]);
elseif strcmp(stationsnaam,  'Veerse Meer')
    xlim([1e-5 10]);
elseif strcmp(stationsnaam,  'Volkerak-Zoommeer')
    xlim([0.1 1e4]);
end

% assenstelsel = get(fig_Toppenlijn,'children');
% set(assenstelsel,'XDir','reverse')
legend('data','Hydra-Zoet PR1564','BER-VZM nieuw', 'location', 'southEast')

OvkansPiekInv_HZ = load('Ovkans_Volkerakzoommeer_piekmeerpeil_2017.txt');
DagenlijnInv_HZ  = load('Dagenlijn VZM uit PR1564.10.txt');
OvduurPerTop_HZ  = load('OvduurPerTop VZM uit PR1564.10.txt');

figure
semilogx(plotpos, obs,'r.');
hold on
grid on
semilogx(1./(9*OvkansPiekInv_HZ(:,2)),OvkansPiekInv_HZ(:,1),'g-','linewidth', 2)    %oude gegevens PR1564
title(['Frequentielijn ',stationsnaam]);
xlabel('Terugkeertijd, 1/jaar');
ylabel('Meerpeil, m+NAP');
if strcmp(stationsnaam,  'Grevelingenmeer')
    xlim([1e-5 100]);
    ylim([-0.3 0.2]);
elseif strcmp(stationsnaam,  'Veerse Meer')
    xlim([1e-5 10]);
elseif strcmp(stationsnaam,  'Volkerak-Zoommeer')
    xlim([0.1 1e4]);
end

% assenstelsel = get(fig_Toppenlijn,'children');
% set(assenstelsel,'XDir','reverse')
legend('data','Hydra-Zoet PR1564', 'location', 'southEast')
