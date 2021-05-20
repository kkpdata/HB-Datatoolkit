figure
plot(ovkanspiek_inv(:,1),log(ovkanspiek_inv(:,2)),'r-')
grid on
hold on
plot(k_HB, log(kovfreq_HB/6),'k')
cltxt  = {'Hydra-Zoet','Hydra-B HR2006 (herschaald)'};
ltxt  = char(cltxt);
ttxt  = 'Overschrijdingkans piekafvoer trapezium Lobith';
xtxt  = 'Rijnafvoer Lobith, m3/s';
ytxt  = 'ln overschrijdingskans, [-]';
Xtick = 0:2000:16000;
Ytick = -10:1:3;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)