% Figuur overschrijdingsfrequentie, met en zonder overstroming
figure
semilogx( 1./(6*kPov)   , kGrid, 'b-','LineWidth',1.5);
grid on; hold on
semilogx( 1./(6*kTF_Pov), kGrid, 'b--','LineWidth',1.5);
title(['Overschrijdingsfrequentie ', sNaam]);
ylabel('Afvoer [m^3/s]')
xlabel('Terugkeertijd [jaar]')
legend('Zonder overstromen (HR2006)', 'Met overstromen Vecht+zijleidingen','Location', 'Southeast');
xlim([1, 1e5])

% Figuur overschrijdingskans,  met en zonder onzekerheid; met en zonder overstroming (incl. transformatie):
figure
semilogy(kGrid, kPov   ,'b-' ,'LineWidth',1.5);
grid on; hold on
semilogy(kGrid, kTF_Pov,'b-.','LineWidth',1.5);
semilogy(vGrid, vPov   ,'r-' ,'LineWidth',1.5);
semilogy(vGrid, vTF_Pov,'r-.','LineWidth',1.5);
title(['Overschrijdingskans basisduur ', sNaam]);
xlabel('Afvoer [m^3/s]');
ylabel('Overschrijdingskans [-]');
legend('Zonder onzekerheid', 'Zonder onz. met overstromen','Met onzekerheid', 'Met onz. met overstromen','Location', 'Southwest');
ylim([1e-7, 1]);


% Figuur overschrijdingsfrequentie, met en zonder onzekerheid:
figure
semilogx( 1./(6*kPov)   , kGrid, 'b-','LineWidth',1.5);
grid on; hold on
semilogx( 1./(6*vPov)   , vGrid, 'r-','LineWidth',1.5);
title(['Overschrijdingsfrequentie ', sNaam]);
ylabel('Afvoer [m^3/s]')
xlabel('Terugkeertijd [jaar]')
legend('Zonder onzekerheid', 'Met onzekerheid','Location', 'Southeast');
xlim([1, 1e5])

% Figuur overschrijdingsfrequentie, met en zonder onzekerheid; met en zonder overstroming (incl. transformatie):
figure
semilogx( 1./(6*kPov)   , kGrid, 'b-','LineWidth',1.5);
grid on; hold on
semilogx( 1./(6*kTF_Pov), kGrid, 'b--','LineWidth',1.5);
semilogx( 1./(6*vPov)   , vGrid, 'r-','LineWidth',1.5);
semilogx( 1./(6*vTF_Pov), vGrid, 'r--','LineWidth',1.5);
title(['Overschrijdingsfrequentie ', sNaam]);
ylabel('Afvoer [m^3/s]')
xlabel('Terugkeertijd [jaar]')
legend('HR2006 Zonder onzekerheid', 'Zonder onz. met overstromen Vecht+zijleidingen','HR2006 Met onzekerheid', 'Met onz. met overstromen Vecht+zijleidingen','Location', 'Southeast');
xlim([1, 1e5])
