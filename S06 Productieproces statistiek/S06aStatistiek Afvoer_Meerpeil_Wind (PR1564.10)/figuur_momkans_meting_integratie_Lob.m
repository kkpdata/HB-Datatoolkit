figure
plot(mom_obs.y,mom_obs.Gy,'g-',berek_trap.y,berek_trap.Gy_mom,'b-.')
grid on
hold on
cltxt  = {'observatie','integratie (trapezia)'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Lobith';
xtxt  = 'Rijnafvoer Lobith, m3/s';
ytxt  = 'momentane overschrijdingskans, [-]';
Xtick = 500:1000:13000;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


figure
plot(mom_obs.y,log(mom_obs.Gy),'g-',berek_trap.y,log(berek_trap.Gy_mom),'b-.')
grid on
hold off
cltxt  = {'observatie','integratie (trapezia)'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Lobith';
xtxt  = 'Rijnafvoer Lobith, m3/s';
ytxt  = 'ln momentane overschrijdingskans, [-]';
%Xtick = 500:1000:13000;
Xtick = 500:1000:17000;
Ytick = -10:1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
