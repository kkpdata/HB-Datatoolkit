function [x, fx, Gx] = momkansen_trap(stapx, xmax, B, topduur_inv, ovkanspiek_inv)
%
%Door Chris Geerse
%Berekening van momentane kansdichtheid en overschrijdingskans als functie
%van niveau x, resulterend volgens trapezia in de basisduur.
%
% Input:
% stapx is stapgrootte in x
% xmax is hoogste waarde van x
% B is basisduur in dagen
% topduur_inv is invoer middels puntenparen topduur
% ovkanspiek_inv is invoer middels puntenparen overschr.kansen piekwaarden
%
% Output:
% matrix met 3 kolommen: x, kansdichtheid fx, overschr.kans Gx
% NB: laagste x is gelijk aan topduur_inv(1,1) = ovkanspiek(1,1)
%
% Call naar:
% topduur
% piekkansen
%==========================================================================
%Invoerparameters
%==========================================================================
%{
stapx = 10;      %stapgrootte x
xmax = 1000;     %maximum voor x
B = 30;

topduur_inv = ...
    [0, 720;        %y moet toenemend zijn, voor b(y) geldt dat niet
    180, 48;
    1000, 48]

ovkanspiek_inv = ...
    [0, 1;
    180, 0.16667;
    550, 1.3333e-4]
%}
%==========================================================================

[y, by] = topduur(topduur_inv, stapx, xmax, 0); %tbv bepalen by
[y, fy, Gy] = piekkansen(ovkanspiek_inv, stapx, xmax);  %tbv bepalen fy

Gx =[];
x = y;
for i = 1:numel(x)
    groterdanxi = (y>=x(i));
    %overschrijdingsduur niveau x(i) in dagen binnen trapezium:
    Lxy = ((by + (B*24-by).*(y-x(i))./(y+eps)).*groterdanxi)/24;
    Gx(i) = stapx/B*sum(fy.*Lxy);   %berekening van de integraal
end

Gx = Gx';
fx = -diff(Gx)/stapx;             %bepalen van momentane kansdichtheid
fx = [fx; Gx(numel(Gx))];   %laatste klasse krijgt overblijvende kans
%display('x, fx, Gx')
%[x, fx, Gx]

%close
%plot(x, Gx*182);
