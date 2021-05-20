function [Stormopzetpatroon_knikpunten, Stormopzetpatroon, ws_verloop, opzet] = ...
    bepaalOpzetverloopBijOpgegevenMaximumwaterstand(hMax, opzGrid,...
    t, ws_getij, A, B, stormduur, topduur, fase);



% Bepaal voor elke waarde uit het opzetgrid de bijbehorende hoogte 
% (= opzet + getij):
for ii = 1 : length(opzGrid)
    
    % Knikpunten van het opzetpatroon.
    opzMax = opzGrid(ii);
    Stormopzetpatroon_knikpunten =...
        [min(t),                0
        -(stormduur/2+12)-fase, eps
        -stormduur/2-fase,      B
        -topduur/2-fase,        opzMax - A
         0-fase,                opzMax
         topduur/2-fase,        opzMax - A
         stormduur/2-fase,      B
         stormduur/2+12-fase,   eps
         max(t),                0];
    
    % Uitbreiding op fijner rooster van getijreeks:
    Stormopzetpatroon = interp1(Stormopzetpatroon_knikpunten(:,1), Stormopzetpatroon_knikpunten(:,2), t, 'linear');
    ws_verloop        = ws_getij + Stormopzetpatroon;
    hoogte(ii,1)      = max(ws_verloop);
end

figure
plot(opzGrid, hoogte)
%[opzGrid, hoogte]

% De opzet waarvoor de hoogte gelijk wordt aan hMax:
opzet = interp1(hoogte, opzGrid, hMax, 'linear', 'extrap');

% Bepaal uiteindelijke opzetverloop:
Stormopzetpatroon_knikpunten =...
    [min(t),                0
    -(stormduur/2+12)-fase, eps
    -stormduur/2-fase,      B
    -topduur/2-fase,        opzet - A
    0-fase,                 opzet
    topduur/2-fase,         opzet - A
    stormduur/2-fase,       B
    stormduur/2+12-fase,    eps
    max(t),                 0];

% Uitbreiding op fijner rooster van getijreeks:
Stormopzetpatroon = interp1(Stormopzetpatroon_knikpunten(:,1), Stormopzetpatroon_knikpunten(:,2), t, 'linear');
ws_verloop        = ws_getij + Stormopzetpatroon;

