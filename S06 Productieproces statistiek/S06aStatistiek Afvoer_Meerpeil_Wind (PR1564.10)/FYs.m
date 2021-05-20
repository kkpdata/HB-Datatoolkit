function [FYs_y] = FYs(y, s, delta, xst, xmx);
%
%
% Door: Chris Geerse
% Betreft berekening van FYs(y), fomule 1 op p 10 van [Beijk en Geerse, 2004], versie
% normale verdeling, met meestal de keuze delta = -s^2/s.
%
%==========================================================================
%{
%Invoer tbv testen
y = 2;
s = 1.2;
xst = 0.001;
xmx = 10;
%}

x = (0:xst:xmx)';
FYs_y = y;    %init

for i = 1:length(y)
    FYs_y(i) = sum(exp(-x).*normcdf(y(i)-x-delta, 0, s)).*xst;
end

%exacte normering op limietwaarde 1
FYs_y = FYs_y/max(FYs_y);

