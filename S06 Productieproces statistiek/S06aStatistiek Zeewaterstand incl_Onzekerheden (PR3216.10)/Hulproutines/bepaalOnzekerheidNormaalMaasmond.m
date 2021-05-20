function [mMu, mSig] = bepaalOnzekerheidNormaalMaasmond(mGrid);

% m = zeewaterstand zonder onzekerheid

A = [...
2.815	0.02
2.915	0.02
3.549	0.065
4.237	0.1425
4.975	0.2575
5.764	0.4175];
mSig = interp1(A(:,1), A(:,2), mGrid, 'linear', 'extrap');

% Bepaal mu
mMu = 0;

