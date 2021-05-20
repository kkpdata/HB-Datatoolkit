function [bandOnder, bandMidden, bandBoven] = bepaalOnzekerheidsbanden(sGrid, typeVerdeling, sSig, sEps, pCI);




% Bepaal onzekerheidsbanden:
if strcmp(typeVerdeling, 'normaal')
        % In deze routine valt dit niet goed te doen voor de normale
        % verdeling!
    
elseif strcmp(typeVerdeling, 'lognormaal')
    sSigNormaal  = sqrt( log(1 + sSig.^2./(-sEps).^2) );
    sMuNormaal   = log( -sEps ) - 0.5 * sSigNormaal.^2;
    
    bandOnderLN  = sMuNormaal + sSigNormaal .* norminv((1-pCI)/2, 0, 1);
    bandOnder    = exp(bandOnderLN) + sEps + sGrid;   %sEps + sGrid moet streefpeil zijn
    
    bandMiddenLN = sMuNormaal + sSigNormaal .* norminv(0.50, 0, 1);
    bandMidden   = exp(bandMiddenLN) + sEps + sGrid;   
        
    bandBovenLN  = sMuNormaal + sSigNormaal .* norminv(1-(1-pCI)/2, 0, 1);
    bandBoven    = exp(bandBovenLN) + sEps + sGrid;
    
end


