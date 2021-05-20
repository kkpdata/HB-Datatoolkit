topduurgem_trap = B*(berek_trap.Gy_mom)./berek_trap.Gy_piek;

figure
grid on
hold on
plot(berek_trap.y,topduurgem_trap,'b-.')
plot(m_HM, OD_HM./OF_HM,'k')
cltxt  = {'volgens P(S>s) en trapezia','Hydra-M HR2006'};
ltxt  = char(cltxt);
ttxt  = 'Overschrijdingsduur per top IJsselmeer';
xtxt  = 'meerpeil, m+NAP';
ytxt  = 'topduur, dagen';
Xtick = -0.4:0.2:1.1;
Ytick = 0:3:30;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
