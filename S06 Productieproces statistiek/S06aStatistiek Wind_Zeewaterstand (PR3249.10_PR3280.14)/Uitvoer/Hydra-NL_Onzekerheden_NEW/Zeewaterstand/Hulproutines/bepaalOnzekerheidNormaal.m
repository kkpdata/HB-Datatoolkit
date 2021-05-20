function [mMu, mSig] = bepaalOnzekerheidNormaal(mGrid,sNaam)

% m = zeewaterstand zonder onzekerheid

% OORSPRONKELIJKE BRON:
% Status data	Final: 27-08-15
% Directions:	Omnidirectional
% Type of uncertainty:	Additional
% Distribution type:	Normal
%
% Distribution parameters:
% Value	Mean	Standard deviation
% 2.83	0	0.02
% 2.93	0	0.02
% 3.57	0	0.065
% 4.26	0	0.1425
% 5.00	0	0.2575
% 5.78	0	0.4175

% Bepaal sigma

switch sNaam
    case 'Hoek_van_Holland'

        A = [...
            2.83	0.02
            2.93	0.02
            3.57	0.065
            4.26	0.1425
            5.00	0.2575
            5.78	0.4175];
        mSig = interp1(A(:,1), A(:,2), mGrid, 'linear', 'extrap');

        % Bepaal mu
        mMu = 0;

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

% % AANGEPASTE VERSIE
% % Bepaal sigma
% A = [...
% 0.8000	0.0002
% 2.5000  0.0002
% 2.93	0.02
% 3.57	0.065
% 4.26	0.1425
% 5.00	0.2575
% 5.78	0.4175];
% mSig = interp1(A(:,1), A(:,2), mGrid, 'linear', 'extrap');
%
% % Bepaal mu
% mMu = 0;
