function [InvoerNL_geenOnzheid_overstromen, InvoerNL_Onzheid_overstromen] =...
    bepalenEnCheckenVanInvoerbestanden(kGrid, kPov, kTF_Pov, vGrid, vTF_Pov, sNaam);


InvoerNL_geenOnzheid_overstromen =...
    [0          1.0000e+00
   1.8000e+02   1.6667e-01
   4.0000e+02   2.4013e-03
   4.1000e+02   1.9804e-03
   4.2000e+02   1.6332e-03
   5.9000e+02   3.4714e-05
   6.0000e+02   2.5086e-05
   6.1000e+02   1.6273e-05
   6.2000e+02   9.9425e-06
   6.3000e+02   5.5564e-06
   6.4000e+02   2.2843e-06
   6.5000e+02   6.7960e-07
   7.0000e+02   1.5839e-09];

InvoerNL_Onzheid_overstromen =...
   [0          1.0000e+00
   1.8000e+02   1.6667e-01
   4.0000e+02   2.5496e-03
   5.0000e+02   4.5756e-04
   5.3000e+02   2.8811e-04
   5.9000e+02   1.2015e-04
   6.0000e+02   9.8163e-05
   6.1000e+02   7.5300e-05
   6.2000e+02   5.6015e-05
   6.3000e+02   3.9792e-05
   6.4000e+02   2.3952e-05
   6.5000e+02   1.2306e-05
   8.0000e+02   1.0406e-09];

% Figuur overschrijdingskans, zonder onzekerheid incl. transformatie:
figure
semilogy(kGrid, kPov   ,'b-' ,'LineWidth',1.5);
grid on; hold on
semilogy(kGrid, kTF_Pov,'b-.','LineWidth',1.5);
semilogy(InvoerNL_geenOnzheid_overstromen(:,1),InvoerNL_geenOnzheid_overstromen(:,2),'g*-','LineWidth',1.5);
semilogy(vGrid, vTF_Pov,'r-.','LineWidth',1.5);
semilogy(InvoerNL_Onzheid_overstromen(:,1),InvoerNL_Onzheid_overstromen(:,2),'k*-.','LineWidth',1.5);
title(['Overschrijdingskans basisduur ', sNaam]);
xlabel('Afvoer [m^3/s]');
ylabel('Overschrijdingskans [-]');
legend('Zonder onz.','Zonder onz. met overstromen','Invoer Hydra-NL','Invoer Hydra-NL onzHeid','Location', 'Southwest');
%legend('Zonder onzekerheid', 'Zonder onz. met overstromen','Met onzekerheid', 'Met onz. met overstromen','Location', 'Southwest');
ylim([1e-10, 1]);


% [kGrid, kTF_Pov]
% [vGrid, vTF_Pov]