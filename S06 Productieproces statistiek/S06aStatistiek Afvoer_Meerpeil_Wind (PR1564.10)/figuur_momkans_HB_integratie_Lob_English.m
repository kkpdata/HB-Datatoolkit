% figure
% plot(q_HB,qmom_HB,'g-',berek_trap.y,berek_trap.Gy_mom,'b-.')
% grid on
% hold on
% cltxt  = {'Hydra-B HR2006','according to integration formula'};
% ltxt  = char(cltxt);
% ttxt  = 'Momentaneous probability Lobith';
% xtxt  = 'Rhine discharge Lobith, m^3/s';
% ytxt  = 'momentaneous probability, [-]';
% Xtick = 0:2000:16000;
% Ytick = 0:0.1:1;
% legend('Location','NorthEastOutside')
% fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% 
% 
% figure
% plot(q_HB,log(qmom_HB),'g-',berek_trap.y,log(berek_trap.Gy_mom),'b-.')
% grid on
% hold off
% cltxt  = {'Hydra-B HR2006','according to integration formula'};
% ltxt  = char(cltxt);
% ttxt  = 'Momentaneous probability Lobith';
% xtxt  = 'Rhine discharge Lobith, m^3/s';
% ytxt  = 'ln momentaneous probability, [-], [-]';
% Xtick = 0:2000:16000;
% Ytick = -12:1:1;
% legend('Location','NorthEastOutside')
% fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


% Zonder format Hans de Waal
figure
semilogy(q_HB,qmom_HB,'g-')
grid on
hold on
semilogy(berek_trap.y, berek_trap.Gy_mom,'b-.')
title('Momentaneous probability Lobith');
xlabel('Rhine discharge Lobith, m^3/s');
ylabel('momentaneous probability, [-]');
xlim([0,18000]);
% Ytick = -12:1:1;
legend('Hydra-B HR2006','according to integration formula');
% legend('Location','NorthEastOutside')

