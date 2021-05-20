% Korte data-analyse VZM
% 
% Door:  Chris Geerse
% Datum: april 2015
% Betreft: PR3015


%==========================================================================
% Algemene zaken
%==========================================================================

clc; clear all; close all
% clc; close all
addpath 'Hulproutines\' 'Invoer'

%==========================================================================
% Algemene invoer(parameters)
%==========================================================================
%Invoerparameters
invoerpad               =   'Invoer\';
uitvoerpad              =   'Uitvoer\';
uitvoerpad_figuren      =   'Figuren\';

%Data bestanden
%infile_data_VZM         =   'data_KREEKRND_RAKZD_1998_2011.txt';
infile_data_VZM         =   'Wind_MeerpeilenRakN_KreekZ.txt';

% Opmerking: ik denk dat Kreekrak Noord feitelijk Rak Noord is, en Rak Zuid
% moet ziin Kreekrak Zuid.


%==========================================================================
%==========================================================================
% Volkerak Zoommeer (VZM)
%==========================================================================
%==========================================================================

%Inlezen data:
filenaam_data                            = fullfile(invoerpad, infile_data_VZM);
[jaar,maand,dag,uur, r, u, mp_uur_ND,mp_uur_ZD] = ...
    textread(filenaam_data,'%f %f %f %f %f %f %f %f','delimiter',' ','headerlines', 1 ,'commentstyle','matlab');

% Middel de meerpeilen van beide stations:
mp_uur_VZM  = (mp_uur_ND + mp_uur_ZD)/2;


%==========================================================================
% Ruwe checks op data
%==========================================================================

% Geef records een nummer:
ndata = numel(mp_uur_VZM);
uurnr = (1:ndata)';

figure
plot(uurnr/(365.25*24)+1998, mp_uur_VZM)
hold on; grid on

% figure
% plot(uurnr/24, mp_uur_VZM)

figure
plot(mp_uur_ND, mp_uur_ZD, '.')
hold on; grid on
plot([-40, 60],[-40, 60],'r-')
title('Uurmetingen Kreekrak Zuid versus Rak Noord (1998 - 2011)')
xlabel('Rak Noord, cm+NAP')
ylabel('Waterstand Kreekrak Zuid, cm+NAP')
xlim([-40, 60])
ylim([-40, 60])

figure
plot(mp_uur_ND, mp_uur_VZM, '.')
hold on; grid on
plot([-40, 60],[-40, 60],'r-')
title('Uurmetingen Rak Noord versus gemiddelde ZD en RN (1998 - 2011)')
xlabel('Rak Noord, cm+NAP')
ylabel('Waterstand gemiddelde, cm+NAP')
xlim([-40, 60])
ylim([-40, 60])

figure
plot(mp_uur_ZD, mp_uur_VZM, '.')
hold on; grid on
plot([-40, 60],[-40, 60],'r-')
title('Uurmetingen Kreekrak Zuid versus gemiddelde ZD en RN (1998 - 2011)')
xlabel('Kreekrak Zuid, cm+NAP')
ylabel('Waterstand gemiddelde, cm+NAP')
xlim([-40, 60])
ylim([-40, 60])

ii = find(mp_uur_ND < -20 & mp_uur_ZD >25)
[jaar(ii),maand(ii),dag(ii),uur(ii),mp_uur_ND(ii),mp_uur_ZD(ii)]


%==========================================================================
% Aggregeer van uur naar daggegevens, waarbij onder meer het dagmaximum wordt bepaald.
%==========================================================================

[daggegevens_VZM] = aggregeer_naar_dag(jaar, maand, dag, mp_uur_VZM);

% Deze variabele bevat (per dag): 
% jaar, maand, dag, min, max, mean, median, mode, std, aantal.

jaar_nw   = daggegevens_VZM(:,1);
maand_nw  = daggegevens_VZM(:,2);
dag_nw    = daggegevens_VZM(:,3);
mp_max    = daggegevens_VZM(:,5);

mp_mean   = daggegevens_VZM(:,6);


