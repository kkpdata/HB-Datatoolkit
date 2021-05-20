function [FYs_y] = FYs_svar(y, sinv, delta, xint_st, xint_mx);
%
%
% Door: Chris Geerse
% Betreft berekening van FYs(y), fomule 1 op p 10 van [Beijk en Geerse, 2004], versie
% normale verdeling, echter nu met s niet constant!
%
%==========================================================================

%{
%Invoer tbv testen
close all

s = 1.2;    %keuze standaarddeviatie

%y-rooster tbv getransformeerde ruimte
ymn = -15;
yst = 0.1;
ymx = 25;
y = (ymn:yst:ymx)';

%parameters voor integratie over x tbv berekening FYs(y)
xint_st = 0.01;
xint_mx = 30;

%invoeren verloop van s in getransformeerde ruimte, (x, s(x)). 
sinv = [0, 0.5;     %linksboven moet beginnen met x = 0; altijd minimaal 1 rij opgeven.
    2, 4;
    10, 5];          %getal rechtsonder wordt ook voor hogere x aangenomen als constante

%sinv = [0, 2.5];

delta = sinv(1,2);
%}

%==========================================================================
%Begin eigenlijke functie
%==========================================================================

x = (0:xint_st:xint_mx)';

%--------------------------------------------------------------------------
%Berekening van s = s(x)
Nx = length(x);
sinv_xmx = max(sinv(:,1));

if size(sinv,1) == 1    %slechts één rij, zodat s(x) = constant moet worden
    s = sinv(1,2)*ones(Nx,1);
elseif sinv_xmx < max(x)    %nu moet sinv eerst aangevuld worden tbv interpolaties
    L = size(sinv,1);
    sinv(L+1, 1) = max(x);
    sinv(L+1, 2) = sinv(L, 2);
    s = interp1(sinv(:,1), sinv(:,2), x);
else
    s = interp1(sinv(:,1), sinv(:,2), x);
end

%--------------------------------------------------------------------------
%Berekening FYs_y
FYs_y = y;    %init

%integraal berekenen
for i = 1:length(y)
    FYs_y(i) = sum(exp(-x).*normcdf((y(i)-x-delta)./s, 0, 1)).*xint_st;
end

%exacte normering op limietwaarde 1
FYs_y = FYs_y/max(FYs_y);

%plot(y, FYs_y)
%plot(y, log(1-FYs_y))
display('FYs_svar.m is gerund');