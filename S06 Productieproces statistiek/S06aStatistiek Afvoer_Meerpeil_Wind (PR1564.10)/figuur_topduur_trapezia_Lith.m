figure
plot(berek_trap.y,berek_trap.by, 'b')
grid on
hold on
ltxt  = []
ttxt  = 'Topduur trapezia Lith';
xtxt  = 'piekafvoer Lith, m3/s';
ytxt  = 'topduur, uur';
Xtick = 0:500:4000;
Ytick = 0:100:800;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
