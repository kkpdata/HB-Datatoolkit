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
%{
nstapx_beta = 10;
nstapy_beta = 10;
%==========================================================================
%Parameters beta-verdeling
%==========================================================================
%defaultwaarden
a = 4.1;
b = 3.95;
%}
%==========================================================================
%Bepalen beta_golfvorm met hoogte 1 en wegschrijven
%==========================================================================

%interval [0,1] opvullen met nstapx_beta deelintervallen met lengte stapx
x = linspace(0,1,nstapx_beta+1)';   
stapx = 1/(nstapx_beta);

y_beta = x;     %initialisatie
y_beta = (x.^(a-1)).*((1-x).^(b-1));
y_beta1 = y_beta/max(y_beta);    %piekwaarde op 1 stellen

beta_normgolfvorm = [x, y_beta1];
%save([padnaam_uit,'beta_normgolfvorm.txt'],'beta_normgolfvorm','-ascii')

%==========================================================================
% Bepalen duur binnen beta-golf op relatieve hoogte y (y tussen 0 en 1) en
% wegschrijven
%==========================================================================

% Bepalen op- en neergaande trajecten beta-kansdichtheid op x-as

[max_y_beta1, i_piek] = max(y_beta1);
x_piek= x(i_piek);              %x-coordinaat van de piek

x_op = (0:stapx:x_piek);
if x_op(end)< x_piek 
    x_op(end+1)= x_piek;        %evt. toevoegen x_piek aan array x_op
end
x_neer = (x_piek:stapx:1);
if x_neer(end)< 1
    x_neer(end+1)= 1;           %evt. toevoegen 1 aan array x_neer
end
x_op = x_op';
x_neer = x_neer';
%==========================================================================

%interval [0,1] opvullen met nstapy_beta deelintervallen met lengte stapy
y = linspace(0,1,nstapy_beta+1)';   
stapy = 1/(nstapy_beta);

%bepalen x-coordinaat waarvoor golf = y in opgaande tak
y_beta1_op = (x_op.^(a-1)).*((1-x_op).^(b-1))/max(y_beta);
x_begin = interp1(y_beta1_op, x_op, y,'lineair');

%bepalen x-coordinaat waarvoor golf = y in neergaande tak
y_beta1_neer = (x_neer.^(a-1)).*((1-x_neer).^(b-1))/max(y_beta);
x_eind = interp1(y_beta1_neer, x_neer, y,'lineair');

beta_normgolfduur = [y, x_eind-x_begin];
%save([padnaam_uit,'beta_normgolfduur.txt'],'beta_normgolfduur','-ascii')


%==========================================================================
% Check dat Beijk's berekening nagenoeg zelfde oplevert als die door Chris 
%{
plot(beta_golfduur(:,2)', beta_golfduur(:,1)')
xlabel('duur op niveau y'); 
ylabel('relatief niveau y');
golfduur_Beijk = load('golfduur_Beijk.txt');
hold on;
plot(golfduur_Beijk(:,2)', golfduur_Beijk(:,1)')
%}

%==========================================================================
% Check dat Beijk's berekening nagenoeg zelfde oplevert als die door Chris 
%
%{
plot(beta_golfvorm(:,1)', beta_golfvorm(:,2)')
xlabel('relatieve tijd'); 
ylabel('genormeerde afvoer');
golfvorm_Beijk = load('golfvorm_Beijk.txt');
hold on;
plot(golfvorm_Beijk(:,1)', golfvorm_Beijk(:,2)')

gerund = 'functie beta_normgolf'
%}