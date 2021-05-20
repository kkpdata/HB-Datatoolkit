% Routine om tijdreeks naar dagwaarden te converteren.
% 
% Door:  Chris Geerse
% Datum: april 2012


%==========================================================================
% Algemene zaken
%==========================================================================

clc; clear all; close all
% clc; close all
addpath 'Hulproutines\'

%==========================================================================
% Algemene invoer(parameters)
%==========================================================================
%Invoerparameters
invoerpad               =   'Invoer\';
uitvoerpad              =   'Uitvoer\';
uitvoerpad_figuren      =   'Figuren\';

%Data bestanden
% infile_data_VZM         =   'data_KREEKRND_RAKZD_1998_2011_TEST.txt';
infile_data_VZM         =   'data_KREEKRND_RAKZD_1998_2011.txt';

infile_data_VM          =   'meerpeilen_10minuten__vm3_vm4_1987_maart2008_TEST.txt';
% infile_data_VM          =   'meerpeilen_10minuten__vm3_vm4_1987_maart2008.txt';

% infile_data_GR          =   'meerpeilen_10minuten_BOM1_1987okt20_2007_TEST.txt';
infile_data_GR          =   'meerpeilen_10minuten_BOM1_1987okt20_2007.txt';



%==========================================================================
%==========================================================================
% Volkerak Zoommeer (VZM)
%==========================================================================
%==========================================================================

%Inlezen data:
filenaam_data                            = fullfile(invoerpad, infile_data_VZM);
[jaar,maand,dag,uur,mp_uur_ND,mp_uur_ZD] = ...
    textread(filenaam_data,'%f %f %f %f %f %f','delimiter',' ','headerlines', 5 ,'commentstyle','matlab');

% Middel de meerpeilen van beide stations:
mp_uur_VZM  = (mp_uur_ND + mp_uur_ZD)/2;


%==========================================================================
% Ruwe checks op data
%==========================================================================

% Geef records een nummer:
ndata = numel(mp_uur_VZM);
uurnr = (1:ndata)';

% figure
% plot(uurnr/(365.25*24)+1998, mp_uur)
%  figure
% plot(uurnr/24, mp_uur)


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

% inhoud_tabel_VZM  = [jaar_nw, maand_nw, dag_nw, mp_max];
% save([uitvoerpad,'mp_dagmaxima_VZM_1998_2011.txt'],'inhoud_tabel_VZM','-ascii')

% inhoud_tabel_VZM  = [jaar_nw, maand_nw, dag_nw, mp_mean];
% save([uitvoerpad,'mp_daggemiddelde_VZM_1998_2011.txt'],'inhoud_tabel_VZM','-ascii')


% % %==========================================================================
% % %==========================================================================
% % % Veerse Meer (VM)
% % %==========================================================================
% % %==========================================================================
% 
% % Inlezen data:
% filenaam_data                            = fullfile(invoerpad, infile_data_VM);
% [jaar,maand,dag,uur,minuut, mp_10min_VM3, mp_10min_VM4] = ...
%     textread(filenaam_data,'%f %f %f %f %f %f %f','delimiter',' ','headerlines', 5 ,'commentstyle','matlab');
% 
% % Middel de meerpeilen van beide stations:
% mp_10min_VM  = (mp_10min_VM3 + mp_10min_VM4)/2;
% 
% 
% % %==========================================================================
% % % Ruwe checks op data
% % %==========================================================================
% % 
% % % Geef records een nummer:
% % ndata = numel(mp_10min_VM);
% % min10_nr = (1:ndata)';
% % 
% % % figure
% % plot(min10_nr/(365.25*24*6)+1998, mp_10min_VM)
% % figure
% % plot(min10_nr/(24*6), mp_10min_VM)
% % 
% 
% % %==========================================================================
% % % Aggregeer van 10-minuten waarden naar daggegevens.
% % %==========================================================================
% 
% [daggegevens_VM] = aggregeer_naar_dag(jaar, maand, dag, mp_10min_VM);
% 
% % Deze variabele bevat (per dag): 
% % jaar, maand, dag, min, max, mean, median, mode, std, aantal.
% 
% jaar_nw   = daggegevens_VM(:,1);
% maand_nw  = daggegevens_VM(:,2);
% dag_nw    = daggegevens_VM(:,3);
% mp_max    = daggegevens_VM(:,5);
% 
% % inhoud_tabel_VM  = [jaar_nw, maand_nw, dag_nw, mp_max];
% % save([uitvoerpad,'mp_dagmaxima_VM_1987_maart2008.txt'],'inhoud_tabel_VM','-ascii')
% 
% % Checks.
% % mp_max_valid  = mp_max(mp_max>-100);
% % jaar_nw_valid = jaar_nw(mp_max>-100);
% % 
% % figure
% % plot(jaar_nw_valid , mp_max_valid,'.')


% %==========================================================================
% %==========================================================================
% % Grevelingen (GR)
% %==========================================================================
% %==========================================================================

% % Inlezen data:
% filenaam_data                            = fullfile(invoerpad, infile_data_GR);
% [dag, maand, jaar, uur, minuut, mp_10min_GR] = ...
%     textread(filenaam_data,'%f %f %f %f %f %f','delimiter',' ','headerlines', 10 ,'commentstyle','matlab');


% %==========================================================================
% % Ruwe checks op data
% %==========================================================================
% 
% % Geef records een nummer:
% ndata = numel(mp_10min_GR);
% min10_nr = (1:ndata)';
% 
% figure
% plot(min10_nr/(365.25*24*6)+1987, mp_10min_GR)
% 
% figure
% plot(min10_nr/(24*6), mp_10min_GR)
% 

% %==========================================================================
% % Aggregeer van 10-minuten waarden naar daggegevens.
% %==========================================================================

% [daggegevens_GR] = aggregeer_naar_dag(jaar, maand, dag, mp_10min_GR);

% Deze variabele bevat (per dag): 
% jaar, maand, dag, min, max, mean, median, mode, std, aantal.

% jaar_nw   = daggegevens_GR(:,1);
% maand_nw  = daggegevens_GR(:,2);
% dag_nw    = daggegevens_GR(:,3);
% mp_max    = daggegevens_GR(:,5);

% inhoud_tabel_GR  = [jaar_nw, maand_nw, dag_nw, mp_max];
% save([uitvoerpad,'mp_dagmaxima_GR_1987okt20_2007.txt'],'inhoud_tabel_GR','-ascii')








