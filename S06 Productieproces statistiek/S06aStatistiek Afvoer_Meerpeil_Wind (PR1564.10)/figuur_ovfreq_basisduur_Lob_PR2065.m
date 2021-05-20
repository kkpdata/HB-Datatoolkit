%Breidt ovprob uit tot aan de waarde 18000 m3/s
qrange         = [ovkanspiek_inv(:,1); 18000];
ov18000        = interp1(berek_trap.y, berek_trap.Gy_piek, 18000);
ovkans_qrange  = [ovkanspiek_inv(:,2); ov18000];


figure
semilogy(qrange,ovkans_qrange,'b')
grid on
title('Exceedance probability Rhine discharge Lobith');
xlabel('discharge Rhine, m^3/s');
ylabel('exceedance probability, [-]');
%axis([-0.4 1.1 10 1e-4]);
print -depsc -tiff -r300 P:\Pr\2065.10\Rapportage\Figuren\fig_ovprob_Lob