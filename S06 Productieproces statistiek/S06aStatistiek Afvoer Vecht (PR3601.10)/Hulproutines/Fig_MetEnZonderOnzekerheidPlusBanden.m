% Figuur overschrijdingskans,  met en zonder onzekerheid + banden
figure
semilogy(kGrid, kPov,'b-','LineWidth',1.5);
grid on; hold on
semilogy(vGrid, vPov,'r-','LineWidth',1.5);
semilogy(bandOnder, kPov,'k--','LineWidth',1.5);
semilogy(bandBoven, kPov,'k--','LineWidth',1.5);
semilogy(kEps +kGrid, kPov,'k--','LineWidth',1.5);  %als check dat de verdeling bij streefpeil begint
title(['Overschrijdingskans ', sNaam]);
ylabel('Afvoer [m^3/s]')
ylabel('Overschrijdingskans [-]');
legend('Zonder onzekerheid', 'Incl. onzekerheid',['Betrouwbaarheidsbanden ',num2str(100*pCI),'%'] );
ylim([1e-6, 1]);
xlim([0, 1100])

% Figuur overschrijdingsfrequentie,  met en zonder onzekerheid + banden
figure
semilogx(1./(Kans2Freq*kPov),kGrid,'b-','LineWidth',1.5);
grid on; hold on
semilogx(1./(Kans2Freq*vPov),vGrid,'r-','LineWidth',1.5);
semilogx(1./(Kans2Freq*kPov),bandOnder,'k--','LineWidth',1.5);
semilogx(1./(Kans2Freq*kPov),bandBoven,'k--','LineWidth',1.5);
title(['Overschrijdingsfrequentie ', sNaam]);
xlabel('Terugkeertijd [jaar]')
ylabel('Afvoer [m^3/s]')
legend('Zonder onzekerheid', 'Incl. onzekerheid',['Betrouwbaarheidsbanden ',num2str(100*pCI),'%'],'location', 'NorthWest');
xlim([1, 1e5]);
ylim([0, 1200])
