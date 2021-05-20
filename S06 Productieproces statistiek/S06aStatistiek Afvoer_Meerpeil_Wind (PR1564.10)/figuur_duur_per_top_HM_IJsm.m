topduurgem_trap = B*(berek_trap.Gy_mom)./berek_trap.Gy_piek;
figure
plot(berek_trap.y,topduurgem_trap)
grid on
hold on
ltxt = [];
ttxt  = 'Overschrijdingsduur per top IJsselmeer';
xtxt  = 'IJsselmeerpeil, m+NAP';
ytxt  = 'topduur, dagen';
Xtick = -0.4:0.2:1.8;
Ytick = 0:2:32;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
