% Checken dat invoerbestand met overstromingen en zonder onzekerheid uit
% Hydra-NL v2.2.1 hetzelfde is als dat uit PR3257.10.

clc
clear
close all
addpath 'Hulproutines\' 'Invoer\';

% Uit Hydra-NL v2.2.1:
Ovkans_Dalfsen_piekafvoer_2017=[...
      0.0           1.000E+00
      180.0           1.667E-01
      216.0           8.333E-02
      264.0           3.333E-02
      300.0           1.667E-02
      335.0           8.333E-03
      383.0           3.333E-03
      419.0           1.667E-03
      459.0           6.667E-04
      490.0           3.333E-04
      530.0           1.333E-04
      551.0           8.333E-05
      582.0           4.167E-05
      609.0           1.667E-05
      623.0           8.333E-06
      637.0           3.333E-06
      643.0           1.667E-06
      662.0           1.667E-07];
  
  
Ovkans_PR3257_10 =[...  
     0              1.000E+00
     180              1.667E-01
     400              2.401E-03
     410              1.980E-03
     420              1.633E-03
     590              3.471E-05
     600              2.509E-05
     610              1.627E-05
     620              9.943E-06
     630              5.556E-06
     640              2.284E-06
     650              6.796E-07
     700              1.584E-09];
 
 
 
 figure
 semilogy(Ovkans_Dalfsen_piekafvoer_2017(:,1), Ovkans_Dalfsen_piekafvoer_2017(:,2),'b')
 hold on; grid on
 semilogy(Ovkans_PR3257_10(:,1), Ovkans_PR3257_10(:,2),'r--')
 
 % Conclusie: ze zijn vrijwel exact gelijk.
 
