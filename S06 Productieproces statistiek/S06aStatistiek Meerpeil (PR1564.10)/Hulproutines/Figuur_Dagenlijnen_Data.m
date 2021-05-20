fig_Dagenlijn = figure;
semilogx(182*mom_obs.Gy, mom_obs.y,'r.')        %data geturfd
hold on
grid on
plot(182*berek_trap.Gy_mom, berek_trap.y,'b-.') %integratie
plot(182*mom_ovkans_PROM, m_PROM, 'g')          %Promovera dagenlijn
title(['Dagenlijn ', stationsnaam]);
xlabel('Aantal overschrijdingsdagen, 1/jaar');
ylabel('Meerpeil, m+NAP');
xlim([1e-3 1e3]);
% ylim([-0.2 1.1]);
assenstelsel = get(fig_Dagenlijn,'children');
set(assenstelsel,'XDir','reverse')
legend('data','integratie','Promovera');
