%function windstatistiek
clear;
close all;

%==========================================================================
% Deze routine selecteert stormen binnen een opgegeven criterium en
% genereert hieruit een relatief stormverloop
%==========================================================================
zichtduur = 25; %zichtduur in uren
v_max     = 200; %maximale snelheid van de te selecteren stormen
stapgrootte = 0.0005; %stapgrootte voor de discretisatie proces
piek_duur = 0.9995; % topduur
theta     = 1E-10; % constante om te voorkomen dat er horizontale lijnstukken berekend worden
b = 1; % begin van het venster waarbinnen de storm opgezocht moet worden
e = (zichtduur*2)+1; % einde van het venster waarbinnen de storm opgezocht moet worden
f_v = [0:stapgrootte:1-stapgrootte]'; % stapgrootte voor het berekenen van de relatieve stormduur 


%==========================================================================
stormselectie
aanpassing_stormverloop
fv_plot