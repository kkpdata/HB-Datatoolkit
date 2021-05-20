%ovfreqs HVIJ en HM in basisduur
figure
%plot(ovkanspiek_inv(:,1), log(ovkanspiek_inv(:,2)));
semilogy(ovkanspiek_inv(:,1), ovkanspiek_inv(:,2),'r');
hold on
grid on
%plot( m_HM, log(1/6*OF_HM), 'k');
semilogy( m_HM, 1/6*OF_HM, 'k');
cltxt  = {'P(S>s)','Hydra-M HR2006 (herschaald)'};
ltxt  = char(cltxt);
ttxt  = ['Overschrijdingskans piekmeerpeil IJsselmeer'];
xtxt  = 'meerpeil, m+NAP';
ytxt  = 'overschrijdingskans, [-]';
Xtick = [-0.4:0.2:1.0];
Ytick = [];
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
