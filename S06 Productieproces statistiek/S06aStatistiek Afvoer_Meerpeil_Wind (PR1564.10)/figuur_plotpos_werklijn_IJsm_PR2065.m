obs = golfkenmerken(:,5);   %piekwaarde
r = golfkenmerken(:,6);     %rang van piekwaarde
n = max(r);                 % aantal meegenomen extreme waarden
t_per = numel(data)/182; % aantal meetjaren, gebruikt in de formule voor de plotposities (werklijn)


figure
plotpos = zeros(n,1);      %initialisatie
for i = 1:n
plotpos(i) = ((r(i)+c+d-1)*n)/((n+c)*t_per);
end
semilogy(obs,plotpos,'r*');
hold on
grid on

%wlijn: k1 = afvoer, k2 = 1/T
wlijn = [ovkanspiek_inv(:,1), 6*ovkanspiek_inv(:,2)];
plot(wlijn(:,1),wlijn(:,2));
title('Exceedance frequency Lake IJssel');
xlabel('Water level Lake IJssel, m+NAP');
ylabel('Exceedance frequency, 1/year');
%axis([-0.4 1.1 10 1e-4]);
print -depsc -tiff -r300 P:\Pr\2065.10\Rapportage\Figuren\fig_ovfreq_IJsm
