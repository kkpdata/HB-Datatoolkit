function [Cz] = Cz_Charnock(z,Uz,alfa)
%
% ----- Toelichting -----------------------------------
% z    = hoogte van windsnelheid, doorgaans: z=10 (m)
% Uz   = windsnelheid op hoogte z (m/s)
% alfa = Charnock-constante, doorgaans: alfa=0.0185 (-)
%                            ook wel:   alfa=0.0144 (-)
%                            ook wel:   alfa=0.032  (-)
% Achtergronden: zie REF01 H6
%
% Referenties
% REF01 = (De Waal, 2003) = 
% -----------------------------------------------------

% constante(n)
g     = 9.81;
kappa = 0.4;

% rekeninstelling(en)
tol   = 1e-4;

% ----- Berekening ------

% doe voor iedere windsnelheid
for iU=1:length(Uz)
  % initialisatie
  Cza  = 1;
  Czb  = 0.001;
  % itereer naar een voldoende nauwkeurige Cz
  while abs(Czb/Cza-1)>tol
    Cza = Czb;
    z0  = alfa*Cza*(Uz(iU)^2)/g;    % REF01 vgl (6.12)&(6.4)
    Czb = (kappa/log(z/z0))^2;      % REF01 vgl (6.5)
  end;
  Cz(iU) = Czb;
end
