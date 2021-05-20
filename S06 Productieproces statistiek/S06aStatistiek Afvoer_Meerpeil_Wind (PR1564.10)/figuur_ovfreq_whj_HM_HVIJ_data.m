%werklijnen en data
figure
semilogx(plotpos,obs,'r*');
hold on
grid on
plot(wlijn(:,2),wlijn(:,1),'b');
plot(1./OF_HM, m_HM, 'k');
cltxt  = {'data','Hydra-VIJ','Hydra-M'};
ltxt  = char(cltxt);
ttxt  = ['werklijnen Hydra-M en Hydra-VIJ IJsselmeer'];
xtxt  = 'terugkeertijd, jaar';
ytxt  = 'meerpeil, m+NAP';
Xtick = [];
Ytick = -.4:0.1:1.1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
