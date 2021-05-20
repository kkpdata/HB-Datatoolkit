aantal_golven = max([golven.nr]);
v = standaardvorm.v;
figure
plot(standaardvorm.tvoor,v,'b',standaardvorm.tachter,v,'b');
hold on
grid on

%Toevoegen trapezium aan plot.
%bpiek = 1;  %topduur trapezium wordt hier tbv plaatje ingesteld.
bpiek = min(topduur_inv(:,2))/24;
x = [-B/2, -bpiek/2, bpiek/2, B/2]';
y = [0, 1, 1, 0]';
plot(x,y,'r');

ltxt  = [];
ttxt  = 'Standard normalised wave Lobith with trapezium';
xtxt  = 'time, days';
ytxt  = 'relatieve discharge v, [-]';
Xtick = -15:5:15;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
print -depsc -tiff -r300 P:\Pr\2065.10\Rapportage\Figuren\fig_norm_standard_trapezium