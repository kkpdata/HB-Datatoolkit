figure
plot(berek_trap.y,berek_trap.by, 'b')
grid on
hold on
title(['Topduur trapezia ', stationsnaam]);
xlabel('Meerpeil, m+NAP');
ylabel('Topduur, uur');
xlim([0 1.4]);
ylim([0 800]);

