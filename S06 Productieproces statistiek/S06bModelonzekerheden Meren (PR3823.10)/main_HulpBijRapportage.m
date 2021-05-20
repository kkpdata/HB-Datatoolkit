%==========================================================================
% Script voor snelle analyse
%
% Door: Chris Geerse
% PR3598.10
% Datum: mei 2017.
%
%
%==========================================================================
%==========================================================================
% Algemeen
%==========================================================================

clc
clear
close all
addpath 'Hulproutines\' 'invoer\';

hfreq_Marken = [...
    0.0000000E+00  0.2703180
    0.1000000      8.8177346E-02
    0.2000000      2.9414497E-02
    0.3000000      1.0529122E-02
    0.4000000      3.9429138E-03
    0.5000000      1.6105596E-03
    0.6000000      6.9404370E-04
    0.7000000      3.1585706E-04
    0.8000000      1.5146243E-04
    0.9000000      7.6161326E-05
    1.000000      3.9877821E-05
    1.100000      2.1614303E-05
    1.200000      1.2021612E-05
    1.300000      6.7961641E-06];

MM_stat_onz = [...
    -0.40         1.000
    -0.22         0.333300
    0.10         1.140E-02
    0.20         4.265E-03
    0.30         1.652E-03
    0.40         6.828E-04
    0.50         2.980E-04
    0.60         1.364E-04
    0.70         6.563E-05
    0.80         3.314E-05
    0.90         1.746E-05
    1.00         9.562E-06
    1.10         5.418E-06
    1.20         3.165E-06
    1.30         1.901E-06
    1.40         1.171E-06
    1.50         7.366E-07
    1.60         4.725E-07
    1.70         3.083E-07
    1.80         2.043E-07
    1.90         1.372E-07
    2.00         9.337E-08];

MM_stat_ws15_onz = [...
    0.2000000      0.1103530
    0.3000000      3.8586374E-02
    0.4000000      1.3156110E-02
    0.5000000      4.6603545E-03
    0.6000000      1.7599793E-03
    0.7000000      7.1448344E-04
    0.8000000      3.0929255E-04
    0.9000000      1.4250018E-04
    1.000000      6.9269154E-05
    1.100000      3.5298450E-05
    1.200000      1.8697141E-05
    1.300000      1.0198671E-05
    1.400000      5.6536646E-06];

MM_stat_ws5_onz = [...
  0.1000000      0.1033089    
  0.2000000      3.4344815E-02
  0.3000000      1.2047794E-02
  0.4000000      4.4739852E-03
  0.5000000      1.7919866E-03
  0.6000000      7.6347729E-04
  0.7000000      3.4365754E-04
  0.8000000      1.6316827E-04
  0.9000000      8.1336068E-05
   1.000000      4.2296819E-05
   1.100000      2.2791217E-05
   1.200000      1.2622205E-05
   1.300000      7.1086370E-06];


figure
semilogy(hfreq_Marken(:,1), hfreq_Marken(:,2), 'b-','linewidth', 2)
hold on; grid on
semilogy(MM_stat_onz(:,1), 3*MM_stat_onz(:,2), 'r-','linewidth', 2)
title('Vergelijking frequentielijnen waterstand en meerpeil')
xlabel('Waterstand of meerpeil, m+NAP')
ylabel('Overschrijdingsfrequentie, 1/jaar')
xlim([0.2, 1.0])
ylim([1e-5, 1e-1])
legend('Waterstand Hydra-NL', 'Frequentielijn meerpeil')

figure
semilogy(hfreq_Marken(:,1), hfreq_Marken(:,2), 'b-','linewidth', 2)
hold on; grid on
semilogy(MM_stat_ws15_onz(:,1), MM_stat_ws15_onz(:,2), 'k-','linewidth', 2)
title('Vergelijking frequentielijnen met en zonder modelonzekerheid')
xlabel('Waterstand, m+NAP')
ylabel('Overschrijdingsfrequentie, 1/jaar')
xlim([0.3, 1.1])
ylim([1e-5, 1e-2])
legend('Waterstand zonder onzekerheid', 'Waterstand met onzekerheid {\sigma} = 0.15 m')

figure
semilogy(hfreq_Marken(:,1), hfreq_Marken(:,2), 'b-','linewidth', 2)
hold on; grid on
semilogy(MM_stat_ws15_onz(:,1), MM_stat_ws15_onz(:,2), 'k-','linewidth', 2)
semilogy(MM_stat_ws5_onz(:,1), MM_stat_ws5_onz(:,2), 'g--','linewidth', 2)
title('Vergelijking frequentielijnen met en zonder modelonzekerheid')
xlabel('Waterstand, m+NAP')
ylabel('Overschrijdingsfrequentie, 1/jaar')
xlim([0.3, 1.1])
ylim([1e-5, 1e-2])
legend('Waterstand zonder onzekerheid', 'Waterstand met onzekerheid {\sigma} = 0.15 m', 'Waterstand met onzekerheid {\sigma} = 0.05 m')


