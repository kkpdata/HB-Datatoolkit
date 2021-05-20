%% Script om invoerbestanden Dalfsen te maken exclusief statistische onzekerheid

% Door:    Chris Geerse
% Project: PR3445.50
% Datum:   juni 2018


%==========================================================================
% Algemene zaken
%==========================================================================

clc;
clear;
close all
addpath 'Hulproutines\' 'Invoer\';

%% Lees Hydra-NL 2017 in
Ovkans_HNL2017 = load('Ovkans_Dalfsen_piekafvoer_2017.txt');
Ovkans_HNL2017_monz = load('Ovkans_Dalfsen_piekafvoer_2017_metOnzHeid.txt');


%% Invoer Dalfsen zonder onzekerheid
% Bron: P:\PR\3746.10\Toeleveringen\2018_02_15 OI2014-verdelingen afvoer zonder onzekerheid

% W2015, W2050, W2100
Invoer_zonder_onzHeid = [...
    2   	216	223	236
    5	    264	281	308
    10  	300	326	364
    20      336	371	422
    25  	347	385	437
    30  	356	398	450
    50      383	431	490
    100 	419	466	534
    200 	449	505	576
    250 	459	517	593
    300 	467	526	612
    500     489	558	631
    1000	520	576	639
    1250	530	589	648
    2000	551	613	657
    2500	561	618	661
    3000	569	621	664
    4000	582	627	670
    5000	589	632	674
    10000	609	647	687
    20000	623	661	700
    30000	629	670	707];

% Ga over op frequenties, met afvoer in eerste kolom
hulp_W2015 = [Invoer_zonder_onzHeid(:,2), 1./(6*Invoer_zonder_onzHeid(:,1))]
hulp_W2050 = [Invoer_zonder_onzHeid(:,3), 1./(6*Invoer_zonder_onzHeid(:,1))]
hulp_W2100 = [Invoer_zonder_onzHeid(:,4), 1./(6*Invoer_zonder_onzHeid(:,1))]


%% Uitbreiding naar beneden (zonder onzekerheid)
% Bepaal goede waarde voor 180 m3/s
Ovkans180_W2015 = exp( interp1(hulp_W2015(:,1), log(hulp_W2015(:,2)), 180, 'linear', 'extrap') )
Ovkans180_W2050 = exp( interp1(hulp_W2050(:,1), log(hulp_W2050(:,2)), 180, 'linear', 'extrap') )
Ovkans180_W2100 = exp( interp1(hulp_W2100(:,1), log(hulp_W2100(:,2)), 180, 'linear', 'extrap') )

% Uitbreiden met kans 1 bij afvoer 0 m3/s
Ovkans_W2015    = ...
    [0,  1
    180, Ovkans180_W2015
    hulp_W2015];

Ovkans_W2050    = ...
    [0,  1
    180, Ovkans180_W2050
    hulp_W2050];

Ovkans_W2100    = ...
    [0,  1
    180, Ovkans180_W2100
    hulp_W2100];


% Figuur met statistiek zonder onzekerheid, inclusief uitbreiding naar beneden:
figure
semilogy(Ovkans_HNL2017(:,1), Ovkans_HNL2017(:,2), 'k-', 'linewidth', 2)
grid on; hold on
semilogy(Ovkans_W2015(:,1), Ovkans_W2015(:,2), 'b--', 'linewidth', 2)
semilogy(Ovkans_W2050(:,1), Ovkans_W2050(:,2), 'r--', 'linewidth', 2)
semilogy(Ovkans_W2100(:,1), Ovkans_W2100(:,2), 'g--', 'linewidth', 2)

title('Ovkansen Dalfsen, basisduur')
xlabel('Afvoer, m^3/s')
ylabel('Overschrijdingskans, [-]')
ylim([1e-7, 1])
xlim([ 0, 800])
legend('Hydra NL 2017, zonz', 'W2015 zonz, PR3746.10', 'W2050 zonz, PR3746.10', 'W2100, zonz PR3746.10')

% Corrigeer rare hobbels voor 2050 en 2100
Ovkans_W2050_corr = ...
   [ 0   1.0000e+00
   1.8000e+02   1.6438e-01
   2.2300e+02   8.3333e-02
   2.8100e+02   3.3333e-02
   3.2600e+02   1.6667e-02
   3.7100e+02   8.3333e-03
   3.8500e+02   6.6667e-03
   3.9800e+02   5.5556e-03
   4.3100e+02   3.3333e-03
   4.6600e+02   1.6667e-03
   5.0500e+02   8.3333e-04
   5.1700e+02   6.6667e-04
   5.2600e+02   5.5556e-04
   %5.5800e+02   3.3333e-04
   %5.7600e+02   1.6667e-04
   5.8900e+02   1.5e-4    %1.3333e-04
   %6.1300e+02   8.3333e-05
   6.1800e+02   6.45e-5  %6.6667e-05
   6.2100e+02   5.5556e-05
   6.2700e+02   4.1667e-05
   6.3200e+02   3.3333e-05
   6.4700e+02   1.6667e-05
   6.6100e+02   8.3333e-06
   6.7000e+02   5.5556e-06];    
  
% Breidt bereik uit tot een extremere afveor:
Ovkans_W2050_corr = [Ovkans_W2050_corr; [695, 1e-6]];

figure
semilogy(Ovkans_W2050(:,1),       Ovkans_W2050(:,2),      'r-', 'linewidth', 2)
hold on; grid on
semilogy(Ovkans_W2050_corr(:,1),  Ovkans_W2050_corr(:,2),  'm-', 'linewidth', 2)
title(' Aanpassing W2050')

Ovkans_W2100_corr = ...
    [0   1.0000e+00
   1.8000e+02   1.6995e-01
   2.3600e+02   8.3333e-02
   3.0800e+02   3.3333e-02
   3.6400e+02   1.6667e-02
   4.2200e+02   8.3333e-03
   4.3700e+02   6.6667e-03
   4.5000e+02   5.5556e-03
   4.9000e+02   3.3333e-03
   5.3400e+02   1.6667e-03
   5.7600e+02   8.3333e-04
   %5.9300e+02   6.6667e-04
   6.1200e+02   3.8e-4  %5.5556e-04
   %6.3100e+02   3.3333e-04
   6.3900e+02   1.8e-4  %1.6667e-04
   6.4800e+02   1.25e-4  %1.3333e-04
   6.5700e+02   8.3333e-05
   6.6100e+02   6.6667e-05
   6.6400e+02   5.5556e-05
   6.7000e+02   4.1667e-05
   6.7400e+02   3.3333e-05
   6.8700e+02   1.6667e-05
   7.0000e+02   8.3333e-06
   7.0700e+02   5.5556e-06];

% Geen uitbreiding doen


figure
semilogy(Ovkans_W2100(:,1),       Ovkans_W2100(:,2),      'r-', 'linewidth', 2)
hold on; grid on
semilogy(Ovkans_W2100_corr(:,1),  Ovkans_W2100_corr(:,2),  'm-', 'linewidth', 2)
title(' Aanpassing W2100')


close all


%% Inlezen statistiek met onzekerheid voor W2050 en W2100

AA = load('Ovkans Dalfsen W2015_2050_2100_onzHeid.txt');

Ovkans_W2050_monz = [AA(:,1), AA(:,3)];
Ovkans_W2100_monz = [AA(:,1), AA(:,4)];

% Figuur met statistiek W2015 en W2100 met en zonder onzekerheid:
figure
semilogy(Ovkans_HNL2017(:,1),     Ovkans_HNL2017(:,2),    'k-', 'linewidth', 2)
grid on; hold on
semilogy(Ovkans_W2050_corr(:,1),  Ovkans_W2050_corr(:,2),      'r--', 'linewidth', 2)
semilogy(Ovkans_W2050_monz(:,1),  Ovkans_W2050_monz(:,2), 'r-', 'linewidth', 2)
semilogy(Ovkans_W2100_corr(:,1),       Ovkans_W2100_corr(:,2),      'g--', 'linewidth', 2)
semilogy(Ovkans_W2100_monz(:,1),  Ovkans_W2100_monz(:,2), 'g-', 'linewidth', 2)
title('Overschrijdingskansen Dalfsen, basisduur')
xlabel('Afvoer, m^3/s')
ylabel('Overschrijdingskans, [-]')
ylim([1e-7, 1])
xlim([ 0, 800])
legend('Hydra NL 2017, zonz', 'W2050 zonz, PR3746.10','W2050 monz PR3746.10',...
    'W2100 zonz, PR3746.10', 'W2100 monz, PR3746.10', 'location', 'SouthWest')
    
% Figuur met: Hydra-NL 2017, W2050 en W2100 met onzekerheid
figure
semilogy(Ovkans_HNL2017_monz(:,1),     Ovkans_HNL2017_monz(:,2),    'k-', 'linewidth', 2)
grid on; hold on
semilogy(Ovkans_W2050_monz(:,1),  Ovkans_W2050_monz(:,2), 'r-', 'linewidth', 2)
semilogy(Ovkans_W2100_monz(:,1),  Ovkans_W2100_monz(:,2), 'g-', 'linewidth', 2)
title('Overschrijdingskansen Dalfsen, basisduur')
xlabel('Afvoer, m^3/s')
ylabel('Overschrijdingskans, [-]')
ylim([1e-7, 1])
xlim([ 0, 800])
legend('Hydra NL 2017, met onz.heid', 'W2050 met onz.heid','W2100 met onz.heid', 'location', 'SouthWest')
    

% =========================================================================
% =========================================================================
% Figuren voor memo
% =========================================================================
% =========================================================================

% Figuur toelevering Deltares zonder bewerking, maar wel in basisduur
figure
semilogy(hulp_W2050(:,1), hulp_W2050(:,2), 'r--', 'linewidth', 2)
grid on; hold on
semilogy(hulp_W2100(:,1), hulp_W2100(:,2), 'g--', 'linewidth', 2)
title('Overschrijdingskansen Dalfsen, basisduur')
xlabel('Afvoer, m^3/s')
ylabel('Overschrijdingskans, [-]')
ylim([1e-7, 1])
xlim([ 0, 800])
legend('W2050 (Deltares)','W2100 (Deltares)' )

% Vergelijking zonder stat. onzheid met situatie inclusief onzekerheid (voor memo).
figure
semilogy(hulp_W2050(:,1), hulp_W2050(:,2), 'r--', 'linewidth', 3)
grid on; hold on
semilogy(hulp_W2100(:,1), hulp_W2100(:,2), 'g--', 'linewidth', 3)
semilogy(Ovkans_W2050_monz(:,1),  Ovkans_W2050_monz(:,2), 'r-', 'linewidth', 1)
semilogy(Ovkans_W2100_monz(:,1),  Ovkans_W2100_monz(:,2), 'g-', 'linewidth', 1)
title('Overschrijdingskansen Dalfsen, basisduur')
xlabel('Afvoer, m^3/s')
ylabel('Overschrijdingskans, [-]')
ylim([1e-7, 1])
xlim([ 0, 800])
legend('W2050 (Deltares)','W2100 (Deltares)', 'W2050 met onz.heid','W2100 met onz.heid', 'location', 'SouthWest')

% Vergelijking zonder en met bewerkingen (voor memo).
figure
semilogy(hulp_W2050(:,1), hulp_W2050(:,2), 'r-', 'linewidth', 1)
grid on; hold on
semilogy(hulp_W2100(:,1), hulp_W2100(:,2), 'g-', 'linewidth', 1)
semilogy(Ovkans_W2050_corr(:,1),  Ovkans_W2050_corr(:,2),      'r--', 'linewidth', 3)
semilogy(Ovkans_W2100_corr(:,1),       Ovkans_W2100_corr(:,2),      'g--', 'linewidth', 3)
title('Overschrijdingskansen Dalfsen, basisduur')
xlabel('Afvoer, m^3/s')
ylabel('Overschrijdingskans, [-]')
ylim([1e-7, 1])
xlim([ 0, 800])
legend('W2050 (Deltares)','W2100 (Deltares)', 'W2050 na bewerkingen','W2100 na bewerkingen', 'location', 'SouthWest')

% Alle relevante lijnen:
% Figuur met: Hydra-NL 2017, W2050 en W2100 met onzekerheid
figure
semilogy(Ovkans_W2100_monz(:,1),  Ovkans_W2100_monz(:,2),      'g-', 'linewidth',  2)
grid on; hold on
semilogy(Ovkans_W2100_corr(:,1),  Ovkans_W2100_corr(:,2),      'g--', 'linewidth', 2)
semilogy(Ovkans_W2050_monz(:,1),  Ovkans_W2050_monz(:,2),      'r-', 'linewidth',  2)
semilogy(Ovkans_W2050_corr(:,1),  Ovkans_W2050_corr(:,2),      'r--', 'linewidth', 2)
semilogy(Ovkans_HNL2017_monz(:,1), Ovkans_HNL2017_monz(:,2),    'k-', 'linewidth',  2)
semilogy(Ovkans_HNL2017(:,1),      Ovkans_HNL2017(:,2),         'k--', 'linewidth', 2)
title('Overschrijdingskansen Dalfsen, basisduur')
xlabel('Afvoer, m^3/s')
ylabel('Overschrijdingskans, [-]')
ylim([1e-7, 1])
xlim([ 0, 800])
legend('W2100 met onz.heid', 'W2100 zonder onz.heid','W2050 met onz.heid', 'W2050 zonder onz.heid',...
'Hydra NL 2017, met onz.heid','Hydra NL 2017, zonder onz.heid', 'location', 'SouthWest')

