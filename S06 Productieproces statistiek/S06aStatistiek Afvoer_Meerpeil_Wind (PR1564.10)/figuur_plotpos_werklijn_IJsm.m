obs = golfkenmerken(:,5);   %piekwaarde
r = golfkenmerken(:,6);     %rang van piekwaarde
n = max(r);                 % aantal meegenomen extreme waarden
t_per = numel(data)/182; % aantal meetjaren, gebruikt in de formule voor de plotposities (werklijn)


figure
plotpos = zeros(n,1);      %initialisatie
for i = 1:n
plotpos(i) = ((n+c)*t_per)/((r(i)+c+d-1)*n);
end
semilogx(plotpos,obs,'r*');
hold on
grid on

%wlijn: k1 = afvoer, k2 = T
wlijn = [ovkanspiek_inv(:,1), 1./(6*ovkanspiek_inv(:,2))];
plot(wlijn(:,2),wlijn(:,1));
ltxt = [];
ttxt  = 'werklijn en data IJsselmeer';
ytxt  = 'meerpeil, m+NAP';
xtxt  = 'terugkeertijd, jaar';
Ytick = -0.4:0.1:1.1;
Xtick = [];
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
