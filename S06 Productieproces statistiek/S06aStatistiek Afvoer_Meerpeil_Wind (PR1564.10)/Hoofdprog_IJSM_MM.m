%==========================================================================
% Hoofdprogramma verband tussen IJssel- en Markermeer
% Door: Chris Geerse
%==========================================================================
clear
close all

clc;
addpath 'Hulproutines\' 'Invoer\';

%==========================================================================
% % Uitvoer wegschrijven in
% padnaam_uit = '\\tsclient\D\Users\geerse\Matlab\PR2894.10_Afleiden_IJsselmeergebied_statistiek\Dalfsen\Uitvoer\';





%Inlezen data
% [dag, maand, jaar, dataIJsm, dataMm] = textread('IJsselmeer_en_Markermeer_1976_2004.txt','%f %f %f %f','delimiter',' ','commentstyle','matlab');


AA = load('IJsselmeer_en_Markermeer_1976_2004.txt');

datum                                = datenum(jaar,maand,dag); 
