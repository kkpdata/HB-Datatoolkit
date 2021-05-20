topduurgem_PROM = 182*mom_ovkans_PROM./OF_PROM;
topduurgem_trap = B*(berek_trap.Gy_mom)./berek_trap.Gy_piek;    %integratie


figure
plot(OvduurPerTop_HZ(:,1),OvduurPerTop_HZ(:,2),'g-')
grid on
hold on
plot(berek_trap.y,topduurgem_trap,'b-.')
title(['Overschrijdingsduur per top ',stationsnaam]);
xlabel('Meerpeil, m+NAP');
ylabel('Topduur, dagen');

if strcmp(stationsnaam, 'Grevelingenmeer')
    xlim([-0.25 0.4]);
elseif strcmp(stationsnaam, 'Veerse Meer')
    xlim([-0.7 0.4]);
elseif strcmp(stationsnaam,  'Volkerak-Zoommeer')
    xlim([-0.2 1.0]);
end

legend('Hydra-Zoet PR1564','BER-VZM nieuw')
