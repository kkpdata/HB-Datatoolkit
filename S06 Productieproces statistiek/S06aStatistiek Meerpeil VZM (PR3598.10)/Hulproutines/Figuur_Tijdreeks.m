figure

plot(datum,data,'.');
grid on
hold on
title(['Metingen als functie van de tijd ', stationsnaam]);
xlabel('Tijd, jaren');
ylabel('Meerpeil, m+NAP');
datetick('x',10)
%datetick('x','keeplimits')
% ylim([-0.2 0.5]);

