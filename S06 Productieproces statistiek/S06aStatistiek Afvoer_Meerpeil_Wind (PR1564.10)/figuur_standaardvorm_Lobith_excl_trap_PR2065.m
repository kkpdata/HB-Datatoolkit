aantal_golven = max([golven.nr]);
v = standaardvorm.v;
figure
plot(standaardvorm.tvoor,v,'b',standaardvorm.tachter,v,'b');
hold on
grid on


ltxt  = [];
ttxt  = 'Normalised standard wave Lobith';
xtxt  = 'time, days';
ytxt  = 'relatieve discharge v, [-]';
Xtick = -15:5:15;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
print -depsc -tiff -r300 P:\Pr\2065.10\Rapportage\Figuren\fig_norm_standard