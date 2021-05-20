function [mMu, mSig] = bepaalOnzekerheidNormaal(mGrid,sNaam)

% m = zeewaterstand zonder onzekerheid

% Bepaal sigma
switch sNaam
    
    case 'OS11'

        A = [...
            3.19	0.0225
            3.29	0.0225
            3.86	0.075
            4.43	0.1475
            5.00	0.25
            5.57	0.3825];
        
        mSig = interp1(A(:,1), A(:,2), mGrid, 'linear', 'extrap');

        % Bepaal mu
        mMu = 0;
end

