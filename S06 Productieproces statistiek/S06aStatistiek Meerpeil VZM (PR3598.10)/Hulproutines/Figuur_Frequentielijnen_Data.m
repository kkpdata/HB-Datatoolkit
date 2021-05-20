
fig_Toppenlijn = figure;
semilogx(1./plotpos, obs,'r.');
hold on
grid on
semilogx(OF_PROM, m_PROM,'g-')
semilogx(wlijn(:,2),wlijn(:,1),'b-');      %Hydra-Zoet keuze
title(['Frequentielijn ',stationsnaam]);
xlabel('Overschrijdingsfrequentie, 1/jaar');
ylabel('Meerpeil, m+NAP');

if strcmp(stationsnaam,  'Grevelingenmeer')
    xlim([1e-5 100]);
    ylim([-0.3 0.2]);
elseif strcmp(stationsnaam,  'Veerse Meer')
    xlim([1e-5 10]);
elseif strcmp(stationsnaam,  'Volkerak-Zoommeer')
    xlim([1e-5 10]);
end

assenstelsel = get(fig_Toppenlijn,'children');
set(assenstelsel,'XDir','reverse')
legend('data','Promovera','Hydra-Zoet')
