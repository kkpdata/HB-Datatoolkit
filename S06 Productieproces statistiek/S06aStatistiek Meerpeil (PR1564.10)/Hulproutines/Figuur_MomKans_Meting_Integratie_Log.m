figure
semilpgy(mom_obs.y,mom_obs.Gy,'r-')
grid on
hold on
semilogy(berek_trap.y,berek_trap.Gy_mom,'b-.')
title(['Momentane kansen ', stationsnaam]);
xlabel('Meerpeil, m+NAP');
ylabel('Momentane overschrijdingskans, [-]');
xlim([-0.5 0.8]);
ylim([0 1]);
legend('observatie','integratie (trapezia)');
