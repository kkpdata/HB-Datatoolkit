figure
plot(berek_trap.y,berek_trap.by, 'b')
grid on
hold on
ltxt  = []
ttxt  = 'Topduur trapezia IJsselmeer';
xtxt  = 'meerpeil, m+NAP';
ytxt  = 'topduur, uur';
Xtick = -0.4:0.2:1.2;
Ytick = 0:100:800;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
