figure
for i = 1:aantal_golven
    plot(golven_aanpas(i).tijd, (golven_aanpas(i).data-ref_niv)./(max(golven_aanpas(i).data)-ref_niv),'b-')
    hold on
    grid on
end
ltxt  = [];
title(['Aangepaste golven ',stationsnaam,' na normering op 1']);
xlabel('Tijd, dagen');
ylabel('Relatief Meerpeil, [-]');
xlim([-floor(B/2) floor(B/2)]);
ylim([0 1]);
