% figure
% plot(mom_obs.y,mom_obs.Gy,'g-',berek_trap.y,berek_trap.Gy_mom,'b-.')
% grid on
% hold on
% cltxt  = {'observatie','integratie (trapezia)'};
% ltxt  = char(cltxt);
% ttxt  = 'Momentane kansen IJsselmeer';
% xtxt  = 'meerpeil, m+NAP';
% ytxt  = 'momentane overschrijdingskans, [-]';
% Xtick = -0.5:0.1:0.8;
% Ytick = 0:0.1:1;
% fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%close all
figure
%plot(mom_obs.y,log(mom_obs.Gy),'g-',berek_trap.y,log(berek_trap.Gy_mom),'b-.')
semilogy(mom_obs.y,mom_obs.Gy,'g-',berek_trap.y,berek_trap.Gy_mom,'b-.')
grid on
hold off
legend('from data','from calculation');
title('Momentaneous exceedance probability Lake IJssel');
xlabel('lake level, m+NAP');
ylabel('P(M>m), [-]');
xlim([-0.5 0.8])
ylim([1e-5 1])

% Xtick = -0.5:0.1:0.8;
% Ytick = -10:1:1;
%fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
print -depsc -tiff -r300 P:\Pr\2065.10\Rapportage\Figuren\fig_momprob_IJsm