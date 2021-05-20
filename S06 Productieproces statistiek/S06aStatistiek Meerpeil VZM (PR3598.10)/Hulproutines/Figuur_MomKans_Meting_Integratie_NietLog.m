figure
plot(mom_obs.y,mom_obs.Gy,'r.')
grid on
hold on
plot(berek_trap.y,berek_trap.Gy_mom,'b-.')
title(['Momentane kansen ', stationsnaam]);
xlabel('Meerpeil, m+NAP');
ylabel('Momentane overschrijdingskans, [-]');
xlim([-0.5 0.8]);
% ylim([-10 1])
legend('observatie','integratie (trapezia)');
