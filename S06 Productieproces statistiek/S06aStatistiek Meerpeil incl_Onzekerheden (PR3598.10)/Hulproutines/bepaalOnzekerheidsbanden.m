function [bandOnder, bandBoven] = bepaalOnzekerheidsbanden(sGrid, typeVerdeling, sSig, sEps, pCI);




% Bepaal onzekerheidsbanden:
if strcmp(typeVerdeling, 'normaal')
        %bla bla
    
elseif strcmp(typeVerdeling, 'lognormaal')
    sSigNormaal  = sqrt( log(1 + sSig.^2./(-sEps).^2) );
    sMuNormaal   = log( -sEps ) - 0.5 * sSigNormaal.^2;
    
    bandOnderLN  = sMuNormaal + sSigNormaal .* norminv((1-pCI)/2, 0, 1);
    bandOnder    = exp(bandOnderLN) + sEps + sGrid;   %sEps + sGrid moet streefpeil zijn
    
    bandBovenLN  = sMuNormaal + sSigNormaal .* norminv(1-(1-pCI)/2, 0, 1);
    bandBoven    = exp(bandBovenLN) + sEps + sGrid;
    
end


