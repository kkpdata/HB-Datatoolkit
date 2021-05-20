figure
plot(mom_obs.y,mom_obs.Gy,'g-',berek_trap.y,berek_trap.Gy_mom,'b-.')
grid on
hold on
cltxt  = {['data, homog: ',labelHom,' m^3/s'],'integratie (trapezia)'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Lith';
xtxt  = 'Maasafvoer Lith, m3/s';
ytxt  = 'momentane overschrijdingskans, [-]';
Xtick = 0:500:3000;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


figure
plot(mom_obs.y,log(mom_obs.Gy),'g-',berek_trap.y,log(berek_trap.Gy_mom),'b-.')
grid on
hold off
cltxt  = {['data, homog: ',labelHom,' m^3/s'],'integratie (trapezia)'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Lith';
xtxt  = 'Maasafvoer Lith, m3/s';
ytxt  = 'ln momentane overschrijdingskans, [-]';
Xtick = 0:500:3000;
Ytick = -10:1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
