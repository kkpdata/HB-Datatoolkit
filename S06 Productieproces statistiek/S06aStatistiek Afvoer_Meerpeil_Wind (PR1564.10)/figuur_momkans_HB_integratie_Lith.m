figure
plot(q_HB,qmom_HB,'g-',berek_trap.y,berek_trap.Gy_mom,'b-.')
grid on
hold on
cltxt  = {'Hydra-B HR2006','volgens P(K>k) en trapezia'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Lith';
xtxt  = 'Maasafvoer Lith, m3/s';
ytxt  = 'momentane overschrijdingskans, [-]';
Xtick = 0:200:800;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


figure
plot(q_HB,log(qmom_HB),'g-',berek_trap.y,log(berek_trap.Gy_mom),'b-.')
grid on
hold off
cltxt  = {'Hydra-B HR2006','volgens P(K>k) en trapezia'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Lith';
xtxt  = 'Maasafvoer Lith, m3/s';
ytxt  = 'ln momentane overschrijdingskans, [-]';
Xtick = 0:500:4000;
Ytick = -12:1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
