
% Figuur overschrijdingsKANS,  met onderdelen:
% - Zonder overstromen, zonder onzekerheid
% - Met overstromen, zonder onzekerheid
% - Zonder overstromen, met onzekerheid
% - Met overstromen, met onzekerheid
% - Banden zonder overstromen
% - Banden met overstromen
figure
semilogy(kGrid, kPov,'b-','LineWidth',1.5);
grid on; hold on
semilogy(kGrid, kTF_Pov,'b-.','LineWidth',1.5);
semilogy(vGrid, vPov   ,'r-' ,'LineWidth',1.5);
semilogy(vGrid, vTF_Pov,'r-.','LineWidth',1.5);
semilogy(bandOnder, kPov,'b--');
semilogy(bandOnderOS, kPov,'r-.')

semilogy(bandBoven, kPov,'b--');
semilogy(bandBovenOS, kPov,'r-.')
semilogy(kEps +kGrid, kPov,'k--','LineWidth',1.5);  %als check dat de verdeling bij streefpeil begint
title(['Overschrijdingskans ', sNaam]);
ylabel('Afvoer [m^3/s]')
ylabel('Overschrijdingskans [-]');
legend('Zonder overstromen, zonder onzekerheid', 'Met overstromen, zonder onzekerheid',...
    'Zonder overstromen, met onzekerheid', 'Met overstromen, met onzekerheid',...
    ['BI, zonder overstromen ', num2str(100*pCI),'%'],...
    ['BI, met overstromen',     num2str(100*pCI),'%']);
ylim([1e-7, 1]);
xlim([0, 1100])

% Figuur overschrijdingsFREQUENTIE,  met onderdelen:
% - Zonder overstromen, zonder onzekerheid
% - Met overstromen, zonder onzekerheid
% - Zonder overstromen, met onzekerheid
% - Met overstromen, met onzekerheid
% - Banden zonder overstromen
% - Banden met overstromen
figure
semilogx(1./(Kans2Freq*kPov),    kGrid,'b-','LineWidth',1.5);
grid on; hold on
semilogx(1./(Kans2Freq*kTF_Pov), kGrid, 'b-.','LineWidth',1.5);
semilogx(1./(Kans2Freq*vPov ),   vGrid, 'r-' ,'LineWidth',1.5);
semilogx(1./(Kans2Freq*vTF_Pov), vGrid, 'r-.','LineWidth',1.5);
semilogx(1./(Kans2Freq*kPov),    bandOnder,  'b--');
semilogx(1./(Kans2Freq*kPov),    bandOnderOS,'r-.');

semilogx(1./(Kans2Freq*kPov),    bandBoven,'b--');
semilogx(1./(Kans2Freq*kPov),    bandBovenOS,'r-.')

title(['Overschrijdingsfrequentie ', sNaam]);
ylabel('Afvoer [m^3/s]')
xlabel('Terugkeertijd [jaar]')
legend('Zonder overstromen, zonder onzekerheid', 'Met overstromen, zonder onzekerheid',...
    'Zonder overstromen, met onzekerheid', 'Met overstromen, met onzekerheid',...
    ['BI, zonder overstromen ', num2str(100*pCI),'%'],...
    ['BI, met overstromen',     num2str(100*pCI),'%']);
xlim([10, 1e6]);
ylim([200, 1100])

