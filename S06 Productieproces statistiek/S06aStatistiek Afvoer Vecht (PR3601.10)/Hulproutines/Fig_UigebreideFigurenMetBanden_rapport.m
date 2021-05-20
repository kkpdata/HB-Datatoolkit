
figure
semilogx(1./(Kans2Freq*kPov),    kGrid,'b-','LineWidth',1.5);
grid on; hold on
%semilogx(1./(Kans2Freq*kTF_Pov), kGrid, 'b-.','LineWidth',1.5);
% semilogx(1./(Kans2Freq*vPov ),   vGrid, 'r-' ,'LineWidth',1.5);
% semilogx(1./(Kans2Freq*vTF_Pov), vGrid, 'r-.','LineWidth',1.5);
semilogx(1./(Kans2Freq*kPov),    bandOnder,  'b--');
%semilogx(1./(Kans2Freq*kPov),    bandOnderOS,'r-.');

semilogx(1./(Kans2Freq*kPov),    bandBoven,'b--');
%semilogx(1./(Kans2Freq*kPov),    bandBovenOS,'r-.')

title(['Overschrijdingsfrequentie ', sNaam]);
ylabel('Afvoer [m^3/s]')
xlabel('Terugkeertijd [jaar]')
legend('Zonder overstromen, zonder onzekerheid', ...
        ['BI, zonder overstromen ', num2str(100*pCI),'%'], 'location', 'SouthEast');
xlim([10, 1e6]);
ylim([200, 1100])



% Figuur overschrijdingsFREQUENTIE,  met onderdelen:
% - Met overstromen, zonder onzekerheid
% - Met overstromen, met onzekerheid
% - Banden met overstromen
figure
semilogx(1./(Kans2Freq*kTF_Pov), kGrid, 'b--','LineWidth',2);
grid on; hold on
semilogx(1./(Kans2Freq*vTF_Pov), vGrid, 'r--','LineWidth',2);
semilogx(1./(Kans2Freq*kPov),    bandOnderOS,'b-.');
semilogx(1./(Kans2Freq*kPov),    bandBovenOS,'b-.')

title(['Overschrijdingsfrequentie ', sNaam]);
ylabel('Afvoer [m^3/s]')
xlabel('Terugkeertijd [jaar]')
legend('Met overstromen, zonder onzekerheid',...
        'Met overstromen, met onzekerheid',...
       ['BI, met overstromen',     num2str(100*pCI),'%'], 'location', 'SouthEast');
xlim([10, 1e6]);
ylim([200, 800])

