clc
clear all
close all

%% Afvoer

pwd;
cd([pwd,'\Afvoer']);
run Main_uitintegreren_onzekerheid_Afvoer

%% Meerpeilen

pwd;
cd([fileparts(pwd),'\Meerpeilen']);
run Main_uitintegreren_onzekerheid_meerpeil_TabelInput

%% Wind

pwd;
cd([fileparts(pwd),'\Wind']);
run Main_uitintegreren_onzekerheid_wind_ALL
run Main_uitintegreren_onzekerheid_wind_ALL_VAR

%% Zeewaterstand Maasmond

pwd;
cd([fileparts(pwd),'\Zeewaterstand']);
run Main_uitintegreren_onzekerheid_sea_level_TabelInput_ALL

%% Zeewaterstand Hoek van Holland

pwd;
cd([fileparts(pwd),'\Zeewaterstand']);
run Main_uitintegreren_onzekerheid_sea_level_WeibullInput_ALL

cd(fileparts(pwd));