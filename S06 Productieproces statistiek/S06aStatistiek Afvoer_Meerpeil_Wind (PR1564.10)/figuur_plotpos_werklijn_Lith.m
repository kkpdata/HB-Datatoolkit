obs = golfkenmerken(:,5);   %piekwaarde
r = golfkenmerken(:,6);     %rang van piekwaarde
n = max(r);                 % aantal meegenomen extreme waarden
t_per = numel(data)/182; % aantal meetjaren, gebruikt in de formule voor de plotposities (werklijn)


%close all

labelHom = num2str(homogenisatieWaarde);

figure
plotpos = zeros(n,1);      %initialisatie
for i = 1:n
    plotpos(i) = ((n+c)*t_per)/((r(i)+c+d-1)*n);
end
p1 = semilogx(plotpos,obs,'r*');
hold on
grid on

%toevoegen wlijn: k1 = piekafvoer, k2 = T
wlijn = [ovkanspiek_inv(:,1), 1./(6*ovkanspiek_inv(:,2))];
plot(wlijn(:,2),wlijn(:,1)),'b';
cltxt  = {['data, homog: ',labelHom,' m^3/s'],'overschrijdingsfrequentie'};
ltxt  = char(cltxt);
ttxt  = ['Gegevens werklijn Lith'];
xtxt  = 'terugkeertijd, jaar';
ytxt  = 'Maasafvoer Lith, m3/s';
Xtick = []
Ytick = 0:500:3000;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
