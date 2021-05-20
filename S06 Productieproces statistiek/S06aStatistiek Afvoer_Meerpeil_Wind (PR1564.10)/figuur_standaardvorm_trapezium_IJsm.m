aantal_golven = max([golven.nr]);
v = standaardvorm.v;

figure
plot(standaardvorm.tvoor,v,'b',standaardvorm.tachter,v,'b');
hold on
grid on
%ook versie met dicreet geturfde overschr.uren:
%plot(standaardvorm_discreet.tvoor,v,'k',standaardvorm_discreet.tachter,v,'k');  
x = [-B/2, -bpiek/2, bpiek/2, B/2]';
y = [0, 1, 1, 0]';
plot(x,y,'r');
ltxt  = [];
ttxt  = 'Gemiddelde golf IJsselmeer met trapezium';
xtxt  = 'tijd, dagen';
ytxt  = 'relatief meerpeil, [-]';
Xtick = -15:5:15;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
