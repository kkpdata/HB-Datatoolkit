figure
plot(berek_trap.y,berek_trap.Gy_mom,'b-.')
grid on
hold on
plot(m_HM, OD_HM/OD_HM(1),'g')
cltxt  = {'volgens P(S>s) en trapezia','Hydra-M HR2006'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen IJsselmeer';
xtxt  = 'meerpeil, m+NAP';
ytxt  = 'momentane overschrijdingskans, [-]';
Xtick = -0.5:0.1:0.8;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


figure
semilogy(berek_trap.y,berek_trap.Gy_mom,'b-.')
grid on
hold on
semilogy(m_HM, OD_HM/OD_HM(1),'g')
cltxt  = {'volgens P(S>s) en trapezia','Hydra-M HR2006'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen IJsselmeer';
xtxt  = 'meerpeil, m+NAP';
Xtick = -0.4:0.2:1.2;
Ytick = [];
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
