%Lijst met belangrijkste functies/procedures

Door: Chris Geerse
%==========================================================================
%==========================================================================

function [golfkenmerken, golven] = golfselectie(drempel,z,jaar,maand,dag,data);
%
% Aanpassing door Chris Geerse van module van Vincent Beijk.
%
%==========================================================================
% Dit programma selecteert die waarden uit een reeks die boven de
% aangegeven drempel uitkomen en zoekt hier omheen de
% gemeten golfvorm met naar links en rechts één zichtduur.
% Het programma loopt met een venster (2*zichtduur + 1 voor de top)
% over de gehele reeks en zoekt de hoogste waarde binnnen het venster.
%
%Input:
%drempel is ondergrens in de selectie van de golven
%z is zichtduur
%jaar behorende bij waarneming
%maand behorende bij waarneming
%dag behorende bij waarneming
%data bijvoorbeeld afvoeren in m3/s
%
%Output:
%golfkenmerken is matrix met kolommen met: nr_golf, jaar waarin piek, maand waarin piek,
%dag waarin piek, piekwaarde. Lengte kolommen is aantal golven.
%
%golven is matrix met kolommen waarin golven als functie van de tijd staan, resp:
%tijd (van 0, 1,...,2*z), 1-ste golf, 2-de golf,...
%
function [beta_normgolfvorm, beta_normgolfduur] = beta_normgolf(a, b, nstapx_beta, nstapy_beta)

%Berekening van een genormeerde golfvorm als functie van x.
%De golfvorm is een op hoogte 1 geschaalde beta-verdeling op het interval
% 0<= x <=1. 
%
% Input:
% a, b zijn parameters beta-verdeling
% nstapx_beta, nstapy_beta geven het aantal klassen op de x en y as
% padnaam_uit is directory waarin uitvoer wordt weggeschreven
%
%Output:
% beta_golfvorm als functie van x.
% beta_golfduur: duur binnen golfvorm als functie van hoogte y (met 0<=y<=1).

function [] = plot_Vechtgolven(beta_normgolfvorm, golfkenmerken, golven);
%
% Aanpassing door Chris Geerse van module van Vincent Beijk.
%
%==========================================================================
%
% Plaatjes worden gemaakt van de geselecteerde golven versus de beta_golfvorm.
%
%Input:
%
%beta_normgolfvorm: matrix met 2 kolommen, nl x (0<=x<=1) en y (0<=y<=1)
%golfkenmerken (betreft geselecteerde golven)
%golven (betreft geselecteerde golven)
%
%Output:
%plaatjes
%
function [y, by, fy_piek, Gy_piek, fy_mom, Gy_mom] = grootheden_trap(stapy, ymax, B, topduur_inv, ovkanspiek_inv);
%
%Door Chris Geerse
%Berekening van diverse grootheden die aan trapezia met basisduur B zijn gerelateerd.
%
% Input:
% stapy is stapgrootte in y
% ymax is hoogste waarde van y
% B is basisduur in dagen
% topduur_inv is invoer middels puntenparen topduur
% ovkanspiek_inv is invoer middels puntenparen overschr.kansen piekwaarden
%
% Output:
% equidistante vector y
% topduur by, is n*2 matrix
% kansdichtheid fy_piek, is n*2 matrix
% overschr.kans Gy_piek, is n*2 matrix
% momentane kansdichtheid fy_mom, is n*2 matrix
% momentane overschr.kans Gy_mom, is n*2 matrix
% NB: laagste y is gelijk aan topduur_inv(1,1) = ovkanspiek(1,1)
%
% Waarden a en b uit exponentiële trajecten worden afgebeeld op scherm.
%
function [fy_mombeta, Gy_mombeta] = momkansen_beta(a, b, nstapx_beta, nstapy_beta, Gy_piek);
%
%Door Chris Geerse
%Berekening van momentane kansdichtheid en overschrijdingskans uitgaande
%van beta-golfvormen voor de afvoer en gegeven overschr.kansen.
%
% Input:
% a en b zijn parameters voor de beta-verdeling
% nstapx_beta is aantal klassen voor interval [0,1] op x-as van genormeerde
% beta-golf (piek 1)
% nstapy_beta is aantal klassen voor interval [0,1] op y-as van genormeerde
% beta-golf (piek 1)
% Gy_piek is n*2 matrix: k1 is vector met afvoerniveaus, k2 is overschr.kans
%
% Output:
% kansdichtheid fy_mombeta, is n*2 matrix
% overschr.kans Gy_mombeta, is n*2 matrix
%
% Calls naar:
% beta_normgolf(a, b, nstapx_beta, nstapy_beta)
%
function [y, fy_mom_obs, Gy_mom_obs] = turven_metingen(y, data);
%
%Door Chris Geerse
%Berekening van momentane kdf en ovkans door turven van waarnemingen.
%
% Input:
% equidistante vector y, die niveaus voor turven bevat
% datavector met waarnemingen
%
% Output:
% y
% kansdichtheid fy_mom_obs is n*2 matrix
% overschr.kans Gy_mom_obs, is n*2 matrix
%