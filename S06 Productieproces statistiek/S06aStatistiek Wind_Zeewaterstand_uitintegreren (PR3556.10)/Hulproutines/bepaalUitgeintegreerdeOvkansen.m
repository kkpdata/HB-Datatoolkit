function [vPov] = bepaalUitgeintegreerdeOvkansen(kGrid, kPov, typeVerdeling, kMu, kSig, kEps, vGrid);

% N.B. Terminologie hier nog in termen van afvoer.
%
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
        PovHulp     = 1 - normcdf( log(vGrid(i) - kGrid -kEps ), kMuNormaal, kSigNormaal);   %vector van formaat mGrid
    end
    
    Som         = PovHulp' * klassekansen;                    % waarde van de integraal
    vPov(i)     = Som;
    
end

