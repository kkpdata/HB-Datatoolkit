figure
plot(mom_obs.y,mom_obs.Gy,'g-',berek_trap.y,berek_trap.Gy_mom,'b-.')
grid on
hold on
plot(m_HM, OD_HM/OD_HM(1),'k')
cltxt  = {'data','Hydra-VIJ','Hydra-M'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Hydra-M en Hydra-VIJ IJsselmeer';
xtxt  = 'meerpeil, m+NAP';
ytxt  = 'momentane overschrijdingskans, [-]';
Xtick = -0.5:0.1:0.8;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%close all
figure
plot(mom_obs.y,log(mom_obs.Gy),'g-',berek_trap.y,log(berek_trap.Gy_mom),'b-.')
grid on
hold on
plot(m_HM, log(OD_HM/OD_HM(1)),'k')
cltxt  = {'data','Hydra-VIJ','Hydra-M'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Hydra-M en Hydra-VIJ IJsselmeer';
xtxt  = 'meerpeil, m+NAP';
ytxt  = 'ln momentane overschrijdingskans, [-]';
Xtick = -0.5:0.2:1.2;
Ytick = -15:1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
