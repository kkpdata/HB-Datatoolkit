function [vPov] = bepaalUitgeintegreerdeOvkansen(kGrid, kPov, typeVerdeling, kMu, kSig, kEps, vGrid);


% Bereken overschrijdingskansen van de (piek)afvoer incl. onzekerheid:
% Initialisatie:
vPov = zeros(length(vGrid), 1);

% Bapaal klassekansen: vector met waarden f(k)dk = P(K>k) - P(K>k+dk):
klassekansen      = kPov - circshift(kPov, -1);
klassekansen(end) = 0;  %maak laatste klasse 0

for i = 1 : length(vPov)
    
    % Bereken overschrijdingskans voor vGrid(i), incl. onzekerheid:
    if strcmp(typeVerdeling, 'normaal')
        PovHulp     = 1 - normcdf( vGrid(i) - kGrid, kMu, kSig);   %vector van formaat mGrid
        
    elseif strcmp(typeVerdeling, 'lognormaal')
        kSigNormaal  = sqrt( log(1 + kSig.^2./(-kEps).^2) );
        kMuNormaal   = log( -kEps ) - 0.5 * kSigNormaal.^2;
        
        %Zorg dat er geen hele kleine negatieve getallen als argument
        %optreden; probleem lijkt te zijn dat kleine  onnauwkeurigheden
        %zorgen voor een drager van de lognormale verdeling die net links
        %van 0 uit komt.
        kleinGetal   = 1e-10;
        argument     = max(vGrid(i) - kGrid -kEps, kleinGetal);
        PovHulp      = 1 - normcdf( log( argument ), kMuNormaal, kSigNormaal);   %vector van formaat mGrid
    end
    
    Som         = PovHulp' * klassekansen;                    % waarde van de integraal
    vPov(i)     = Som;
    
end



