figure
plot(berek_trap.y,berek_trap.by, 'b')
grid on
hold on
title('Peak duration Lake IJssel');
xlabel('lake level, m+NAP');
ylabel('peak duration, hour');
axis([-0.4 1.2 0 800]);
print -depsc -tiff -r300 P:\Pr\2065.10\Rapportage\Figuren\fig_peak_duration_IJsm