figure
for i = 1:aantal_golven
    plot(golven_aanpas(i).tijd, golven_aanpas(i).data,'b-')
    hold on
    grid on
end

title(['Aangepaste golven ', stationsnaam]);
xlabel('Tijd, dagen');
ylabel('Meerpeil, m+NAP');
xlim([-floor(B/2) floor(B/2)]);
% ylim([-0.1 0.4]);
