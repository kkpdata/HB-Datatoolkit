% Figuur overschrijdingskans, zonder en met onzekerheid:
figure
semilogy(kGrid, kPov,'b-','LineWidth',1.5);
grid on; hold on
semilogy(vGrid, vPov,'r-','LineWidth',1.5);
title(['Overschrijdingskans basisduur ', sNaam]);
xlabel('Afvoer [m^3/s]');
ylabel('Overschrijdingskans [-]');
legend('Zonder onzekerheid', 'Incl. onzekerheid','Location', 'Southwest');
ylim([1e-7, 1]);

% Figuur overschrijdingsfrequentie, zonder en met onzekerheid:
figure
semilogx( 1./(6*kPov), kGrid,'b-','LineWidth',1.5);
grid on; hold on
semilogx(1./(6*vPov),vGrid, 'r-','LineWidth',1.5);
title(['Overschrijdingsfrequentie ', sNaam]);
ylabel('Afvoer [m^3/s]')
xlabel('Terugkeertijd [jaar]')
legend('Zonder onzekerheid', 'Incl. onzekerheid','Location', 'Southeast')
xlim([1, 1e5])
%ylim([0, 25000])
