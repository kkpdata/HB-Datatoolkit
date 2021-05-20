fig_Dagenlijn = figure;
semilogx(180*mom_obs.Gy, mom_obs.y,'r.')        %data geturfd
hold on
grid on
plot(180/182*DagenlijnInv_HZ(:,2), DagenlijnInv_HZ(:,1), 'g','LineWidth',1.5);          %Promovera dagenlijn
plot(180*berek_trap.Gy_mom, berek_trap.y,'b-.','LineWidth',1.5); %integratie
title(['Dagenlijn ', stationsnaam]);
xlabel('Aantal overschrijdingsdagen, 1/jaar');
ylabel('Meerpeil, m+NAP');
xlim([1e-3 2e2]);
ylim([-0.4 1]);
assenstelsel = get(fig_Dagenlijn,'children');
set(assenstelsel,'XDir','reverse')
legend('data','Hydra-Zoet PR1564','BER-VZM nieuw','location', 'southeast');


fig_Dagenlijn = figure;
semilogx(180*mom_obs.Gy, mom_obs.y,'r.')        %data geturfd
hold on
grid on
plot(180/182*DagenlijnInv_HZ(:,2), DagenlijnInv_HZ(:,1), 'g', 'LineWidth',1.5);         %Promovera dagenlijn
title(['Dagenlijn ', stationsnaam]);
xlabel('Aantal overschrijdingsdagen, 1/jaar');
ylabel('Meerpeil, m+NAP');
xlim([1e-3 2e2]);
ylim([-0.4 1]);
assenstelsel = get(fig_Dagenlijn,'children');
set(assenstelsel,'XDir','reverse')
legend('data','Hydra-Zoet PR1564','location', 'southeast');
