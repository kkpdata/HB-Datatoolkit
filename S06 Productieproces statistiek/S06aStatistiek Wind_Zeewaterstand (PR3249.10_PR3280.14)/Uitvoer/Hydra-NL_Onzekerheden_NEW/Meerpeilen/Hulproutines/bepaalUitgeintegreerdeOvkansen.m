function [vPov] = bepaalUitgeintegreerdeOvkansen(sGrid, sPov, typeVerdeling, sMu, sSig, sEps, vGrid);

% Volgende script wordt hier toegepast op piekmeerpeil ipv piekafvoer




% Bereken overschrijdingskansen van de (piek)afvoer incl. onzekerheid:
% Initialisatie:
vPov = zeros(length(vGrid), 1);

% Bapaal klassekansen: vector met waarden f(k)dk = P(K>k) - P(K>k+dk):
klassekansen      = sPov - circshift(sPov, -1);
klassekansen(end) = 0;  %maak laatste klasse 0


for i = 1 : length(vPov)

    % Bereken overschrijdingskans voor vGrid(i), incl. onzekerheid:
    if strcmp(typeVerdeling, 'normaal')
        PovHulp     = 1 - normcdf( vGrid(i) - sGrid, sMu, sSig);   %vector van formaat mGrid

    elseif strcmp(typeVerdeling, 'lognormaal')
        sSigNormaal  = sqrt( log(1 + sSig.^2./(-sEps).^2) );
        sMuNormaal   = log( -sEps ) - 0.5 * sSigNormaal.^2;
        
        %zorg dat er geen hele kleine negatieve getallen als argument
        %optreden; probleem lijkt te zijn dat kleine  onnauwkeurigheden
        %zorgen voor een drager van de lognormale verdeling die net links
        %van 0 uit komt.
        kleinGetal   = 1e-13;
        argument     = vGrid(i) - sGrid -sEps + kleinGetal;    
        PovHulp     = 1 - normcdf( log( argument ), sMuNormaal, sSigNormaal);   %vector van formaat mGrid
        
    end
    
    Som         = PovHulp' * klassekansen;                    % waarde van de integraal
    vPov(i)     = Som;
    
end

